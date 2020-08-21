//
//  CCGLView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/11.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "CCGLView.h"

@implementation CCGLView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews{
   
    NSLog(@"%s",__FUNCTION__);
    [self setupContext];
    
    [self setUpLayer];

    [self resetRenderAndFrameBuffer];
    
    [self setupColorRenderBuffer];
    
    [self setupFrameRenderBuffer];
    
    //检查FrameBuffer
    NSError *error;
    NSAssert1([self checkFramebuffer:&error], @"%@",error.userInfo[@"ErrorMessage"]);
    
    
    [self setupViewPort];
    
   
}

-(void)setUpLayer{
     self.eaglLayer =  (CAEAGLLayer*)self.layer;
     //设置放大倍数
     [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    
     self.eaglLayer.opaque = YES;
     
     self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}
/**
 创建上下文
 */
-(void)setupContext{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.context) {
        NSLog(@"Create context failed!");
        return;
    }
    //设置为当前的图形上下文
    if (![EAGLContext setCurrentContext:self.context]) {
       NSLog(@"setCurrentContext failed!");
       return;
   }
    
    
}
/**
 重置缓冲区
 */
-(void)resetRenderAndFrameBuffer{
    glDeleteBuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    glDeleteBuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}
/**
 初始化一个渲染缓冲区
 */
-(void)setupColorRenderBuffer{
   
    glGenRenderbuffers(1, &_colorRenderBuffer);
    //绑定renderBuffer到当前状态机
    glBindRenderbuffer(GL_RENDERBUFFER, self.colorRenderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];

}
/**
 初始化一个帧缓冲区
 */
-(void)setupFrameRenderBuffer{
    glGenFramebuffers(1,&_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
}



-(void)setupViewPort{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    glViewport(0, 0, self.frame.size.width*scale, self.frame.size.height*scale);
    
}
- (BOOL)checkFramebuffer:(NSError *__autoreleasing *)error {
    
    // 检查 framebuffer 是否创建成功
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSString *errorMessage = nil;
    BOOL result = NO;
    switch (status)
    {
        case GL_FRAMEBUFFER_UNSUPPORTED:
            errorMessage = @"framebuffer不支持该格式";
            result = NO;
            break;
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"framebuffer 创建成功");
            result = YES;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
            errorMessage = @"Framebuffer不完整 缺失组件";
            result = NO;
            break;
        case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
            errorMessage = @"Framebuffer 不完整, 附加图片必须要指定大小";
            result = NO;
            break;
        default:
            // 一般是超出GL纹理的最大限制
            errorMessage = @"未知错误 error !!!!";
            result = NO;
            break;
    }
    NSLog(@"%@",errorMessage ? errorMessage : @"");
    *error = errorMessage ? [NSError errorWithDomain:@"com.Yue.error"
                                                code:status
                                            userInfo:@{@"ErrorMessage" : errorMessage}] : nil;
    return result;
}
-(void)complileShader:(NSString*)shaderrv shaderrf:(NSString*)shaderrf{
    //2.读取顶点着色程序、片元着色程序
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:shaderrv ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:shaderrf ofType:@"fsh"];
    
//    NSLog(@"vertFile:%@",vertFile);
//    NSLog(@"fragFile:%@",fragFile);
    
    //3.加载shader
    self.shaderProgram = [self loadShaders:vertFile Withfrag:fragFile];
    
    //4.链接
    glLinkProgram(self.shaderProgram);
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.shaderProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.shaderProgram, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    NSLog(@"Program Link Success!");
    //5.使用program
    glUseProgram(self.shaderProgram);
    

}
-(GLuint)loadShaders:(NSString *)vert Withfrag:(NSString *)frag
{
    //定义2个零时着色器对象
    GLuint verShader, fragShader;
    //创建program
    GLint program = glCreateProgram();
    
    //编译顶点着色程序、片元着色器程序
    //参数1：编译完存储的底层地址
    //参数2：编译的类型，GL_VERTEX_SHADER（顶点）、GL_FRAGMENT_SHADER(片元)
    //参数3：文件路径
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vert];
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:frag];
    

    
    //创建最终的程序
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    //释放不需要的shader
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}
//链接shader
- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file{
    
    //读取文件路径字符串
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    //创建一个shader（根据type类型）
    *shader = glCreateShader(type);
    
    //将顶点着色器源码附加到着色器对象上。
    //参数1：shader,要编译的着色器对象 *shader
    //参数2：numOfStrings,传递的源码字符串数量 1个
    //参数3：strings,着色器程序的源码（真正的着色器程序源码）
    //参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(*shader, 1, &source,NULL);
    //把着色器源代码编译成目标代码
    glCompileShader(*shader);
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
@end
