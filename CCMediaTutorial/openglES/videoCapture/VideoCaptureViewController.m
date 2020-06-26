//
//  VideoCaptureViewController.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/16.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "VideoCaptureViewController.h"
#import "VideoCaptureView.h"
#import "WCLRecordEncoder.h"
#import <AVFoundation/AVFoundation.h>
@interface VideoCaptureViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (strong, nonatomic) AVCaptureSession *session;
@property (copy,nonatomic) dispatch_queue_t captureQueue;//录制的队列
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;
@property (strong, nonatomic) AVCaptureAudioDataOutput *audioOutput;
@property (strong, nonatomic) NSString *outputFilePath;
@property(strong,nonatomic)AVCaptureConnection *captureConnection;
@property (strong, nonatomic) WCLRecordEncoder  *recordEncoder;//录制编码
@property(assign,nonatomic)BOOL needCapture;
@end
@implementation VideoCaptureViewController
{
    BOOL _captureAudio;
    CMFormatDescriptionRef audioFmt;
}
-(void)loadView{
    self.view = [VideoCaptureView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    // Do any additional setup after loading the view.
    
    UIButton *buttonA = [UIButton new];
    buttonA.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:buttonA];
    
    [buttonA addTarget:self action:@selector(onClickButtonA:) forControlEvents:UIControlEventTouchUpInside];
    [buttonA setTitle:@"开始" forState:UIControlStateNormal];
    [self setupCaptureSession];
}
-(void)onClickButtonA:(UIButton*)sender{
    if(self.needCapture){
        self.needCapture = NO;
        [self.recordEncoder cancelWriting];
        __weak typeof(self)weakSelf = self;
        [self.recordEncoder finishWithCompletionHandler:^{
        
            weakSelf.recordEncoder = nil;
            
        }];
        NSLog(@"结束录制");
    }else {
        self.needCapture = YES;
        
        NSLog(@"开始录制");
    }
}
- (void)setupCaptureSession
{
   
    
    // Create the session
    self.session = [[AVCaptureSession alloc] init];
    _captureQueue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_SERIAL);
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    __weak typeof (self)weakSelf=self;
    switch ( [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] )
    {
        case AVAuthorizationStatusAuthorized:
        {
            // The user has previously granted access to the camera.
            [self continueSetUpSession];
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            dispatch_suspend( self.captureQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( granted ) {
                    [weakSelf continueSetUpSession];
                }else {
                 
                }
                dispatch_resume( self.captureQueue );
            }];
            break;
        }
        default:
        {
            // The user has previously denied access.
            //doNotion
            dispatch_suspend( self.captureQueue );
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if ( granted ) {
                    [weakSelf continueSetUpSession];
                }else {
                    
                }
                dispatch_resume( self.captureQueue );
            }];
            break;
        }
    }


}
-(void)continueSetUpSession{
     NSError *error = nil;
    self.session.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *videoDevice = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [videoDevice lockForConfiguration:&error];
    if([videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        videoDevice.focusMode=AVCaptureFocusModeContinuousAutoFocus;
    }
    videoDevice.activeVideoMinFrameDuration=CMTimeMake(1, 20);
    
    if ( [videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ) {
        videoDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        NSLog(@"已经设置为自动曝光");
    }
    [videoDevice unlockForConfiguration];
    
    // Create a device input with the device and add it to the session.
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
                                                       error:&error];
    if([self.session canAddInput:self.input]){
        [self.session addInput:self.input];
    }
    if(_captureAudio){
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
   
        self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    if([self.session canAddInput:self.audioInput]){
        [self.session addInput:self.audioInput];
    }
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    
    [self.session addOutput:output];
    
    self.captureConnection=[output connectionWithMediaType:AVMediaTypeVideo];

    self.captureConnection.videoOrientation=AVCaptureVideoOrientationLandscapeRight;
    // Configure your output.`
    
    [output setSampleBufferDelegate:self queue:_captureQueue];
    if(_captureAudio){
    self.audioOutput = [[AVCaptureAudioDataOutput alloc] init];
       
        [self.audioOutput setSampleBufferDelegate:self queue:_captureQueue];
        [self.session addOutput:self.audioOutput];
    }
    
    // Specify the pixel format
    output.videoSettings =
    [NSDictionary dictionaryWithObject:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.session startRunning];
  
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CFRetain(sampleBuffer);
    BOOL isVideo = YES;
    if(self.audioOutput == captureOutput){
        if(self.recordEncoder==nil&&!audioFmt){
            audioFmt = CMSampleBufferGetFormatDescription(sampleBuffer);
        }
        CFRelease(sampleBuffer);
    }else {
        __weak typeof(self)weakSelf = self;
        
        size_t width = 0,height = 0;
        if(self.needCapture&&!width&&!height){
            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
            width = CVPixelBufferGetWidth(imageBuffer);
            height = CVPixelBufferGetHeight(imageBuffer);
        }
        if(!_recordEncoder&&self.needCapture&&audioFmt){
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(audioFmt);
            
            _recordEncoder = [[WCLRecordEncoder alloc] initPath:self.outputFilePath Height:width width:height channels:asbd->mChannelsPerFrame samples:asbd->mSampleRate];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
                [((VideoCaptureView*)weakSelf.view) laodTextureFormSampleBuffer:sampleBuffer];
                CFRelease(sampleBuffer);
                [((VideoCaptureView*)weakSelf.view) draw];
        });
    }
    if(_recordEncoder&&self.needCapture&&audioFmt){
        [_recordEncoder encodeFrame:sampleBuffer isVideo:isVideo];
    }else {
        
    }
    
}

-(NSString*)outputFilePath{
    if(!_outputFilePath){
        _outputFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _outputFilePath = [NSString stringWithFormat:@"%@/1.mp4",_outputFilePath];
    }
    return _outputFilePath;
}

@end
