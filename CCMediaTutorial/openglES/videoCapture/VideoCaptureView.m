//
//  VideoCaptureView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/16.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "VideoCaptureView.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
// Uniform index.
enum
{
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];

enum
{
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};
GLint attribute[NUM_ATTRIBUTES];
@interface VideoCaptureView ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *mCaptureSession; //负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *mCaptureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureVideoDataOutput *mCaptureDeviceOutput; //output
@end
@implementation VideoCaptureView
{
    dispatch_queue_t mProcessQueue;
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    
    GLuint _frameBufferHandle;
    GLuint _colorBufferHandle;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self complileShader:@"shaderImageView" shaderrf:@"shaderImageView"];
    [self setupCordinate];
    self.ready = YES;
}
-(void)setupCordinate{
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    GLfloat vertexs[] =
    {
        1.0f, 1, -1.0f,     1.0f, 0.0f,
        -1.0f, -1, -1.0f,     0.0f, 1.0f,
        -1.0f, 1, -1.0f,    0.0f, 0.0f,
        1.0f, -1, -1.0f,      1.0f, 1.0f,
        -1.0f, -1, -1.0f,     0.0f, 1.0f,
        1.0f, 1, -1.0f,     1.0f, 0.0f,
    };
    GLuint attrBuffer;
    
    glGenBuffers(1, &attrBuffer);
 
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
    
    GLuint position = glGetAttribLocation(self.shaderProgram, "position");
    
    glEnableVertexAttribArray(position);
    //设置顶点数据的读取方式
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    
    
    GLuint textCoor = glGetAttribLocation(self.shaderProgram, "textCoordinate");
    
    glEnableVertexAttribArray(textCoor);
    
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
    
  
    GLuint rotate = glGetUniformLocation(self.shaderProgram, "rotateMatrix");
    
    
    float radians = 270 * M_PI / 180.0f;

    float s = sin(radians);
    float c = cos(radians);
    
   
    GLfloat zRotation[16] = {
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat*)&zRotation);

}
-(void)laodTextureFormSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
//    NSLog(@"width:%d height:%d",width,height);
    GLubyte * spriteData = (GLubyte *) calloc(bytesPerRow*height, sizeof(GLubyte));
    
    memmove(spriteData, baseAddress, bytesPerRow*height);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (float)width,(float)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    free(spriteData);
    
}
-(void)draw{
    glDrawArrays(GL_TRIANGLES, 0, 6);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
