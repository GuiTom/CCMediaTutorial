//
//  GpuCameraCaptureVC.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/26.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "GpuCameraCaptureVC.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import "GPUImageView.h"
#import "GPUImageVideoCamera.h"
#import "GPUImageOutput.h"
#import "GPUImageFilter.h"
#import "GPUImageBilateralFilter.h"
#import "GPUImageGaussianBlurFilter.h"
@interface GpuCameraCaptureVC ()

@end

@implementation GpuCameraCaptureVC
{
    
GPUImageVideoCamera *videoCamera;
GPUImageOutput<GPUImageInput> *filter;
          
}
-(void)loadView{
    self.view = [GPUImageView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
     videoCamera.horizontallyMirrorFrontFacingCamera = NO;
     videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
     filter = [[GPUImageGaussianBlurFilter alloc] init];
    [filter addTarget:(GPUImageView*)self.view];
    [videoCamera addTarget:filter];
    [videoCamera startCameraCapture];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
