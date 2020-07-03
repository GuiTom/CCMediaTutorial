//
//  FilterChainView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/30.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "FilterChainView.h"



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
typedef struct
{
    float position[4];//顶点x,y,z,w
    float textureCoordinate[2];//纹理 s,t
} CustomVertex;
//属性枚举
enum
{
    ATTRIBUTE_POSITION = 0,//属性_顶点
    ATTRIBUTE_POSITION2,//属性_顶点
    ATTRIBUTE_SATURATION_INPUT_TEXTURE_COORDINATE,//属性_输入纹理坐标
    ATTRIBUTE_TEMPERATURE_INPUT_TEXTURE_COORDINATE,//属性_输入纹理坐标
    NUM_ATTRIBUTES//属性个数
};


enum
{
    UNIFORM_SATURATION_INPUT_IMAGE_TEXTURE = 0,//输入纹理
    UNIFORM_TEMPRATURE_INPUT_IMAGE_TEXTURE,//输入纹理
    UNIFORM_SATURATION,//饱和度
    UNIFORM_TEMPERATURE,//饱和度
    NUM_UNIFORMS//Uniforms个数
};
//属性数组
GLint glViewAttributes2[NUM_ATTRIBUTES];
GLint glViewUniforms2[NUM_UNIFORMS];
@implementation FilterChainView
{
    GLuint       _texture;//纹理
    GLuint saurationFrameBuffer;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.sauration = 1.0f;
    [self complileShader:@"CCVertexShader" shaderrf:@"CCSaturation"];
    self.saurationShaderProgram = self.shaderProgram;
    [self getLocationOfSaturation];
    [self complileShader:@"CCVertexShader" shaderrf:@"CCTemperature"];
    self.temperatureShaderProgram = self.shaderProgram;
    [self getLocationOfTempreature];
 
    [self setUpSaurationFrameBuffer];
    
    //检查FrameBuffer
    NSError *error;
    NSAssert1([self checkFramebuffer:&error], @"%@",error.userInfo[@"ErrorMessage"]);
    
    [self setupTextureWithImage:[UIImage imageNamed:@"1.jpg"]];
    [self setupVBOs];

    [self renderLayer];
}
/**
 创建一个渲染到纹理的buffer
 */
-(void)setUpSaurationFrameBuffer{
   
    glGenFramebuffers(1, &saurationFrameBuffer);
  
    glActiveTexture(GL_TEXTURE0);//调完亮度之后的图像存在这个纹理里面
    

    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.frame.size.width * self.contentScaleFactor, self.frame.size.height * self.contentScaleFactor, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    //设置纹理参数
    //放大\缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glBindFramebuffer(GL_FRAMEBUFFER, saurationFrameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0);
    

    
}
-(void)renderLayer{
    [self renderFirstLayer];
    [self renderSecondLayer];
}
-(void)getLocationOfSaturation{
    
    //顶点坐标
    glViewAttributes2[ATTRIBUTE_POSITION] = glGetAttribLocation(self.saurationShaderProgram, "position");
    
    // //输入的纹理坐标
    glViewAttributes2[ATTRIBUTE_SATURATION_INPUT_TEXTURE_COORDINATE]  = glGetAttribLocation(self.saurationShaderProgram, "inputTextureCoordinate");
    
    /**
      返回值:变量的位置
     */
    glViewUniforms2[UNIFORM_SATURATION_INPUT_IMAGE_TEXTURE] = glGetUniformLocation(self.saurationShaderProgram, "inputImageTexture");
    
    //饱和度值
    glViewUniforms2[UNIFORM_SATURATION] = glGetUniformLocation(self.saurationShaderProgram, "saturation");
    
    glEnableVertexAttribArray(glViewAttributes2[ATTRIBUTE_POSITION]);
    glEnableVertexAttribArray(glViewAttributes2[ATTRIBUTE_SATURATION_INPUT_TEXTURE_COORDINATE]);
}

-(void)getLocationOfTempreature{
    
    //顶点坐标
    glViewAttributes2[ATTRIBUTE_POSITION2] = glGetAttribLocation(self.temperatureShaderProgram, "position");
    
    // //输入的纹理坐标
    glViewAttributes2[ATTRIBUTE_TEMPERATURE_INPUT_TEXTURE_COORDINATE]  = glGetAttribLocation(self.temperatureShaderProgram, "inputTextureCoordinate");
    
    /**
      返回值:变量的位置
     */
    glViewUniforms2[UNIFORM_TEMPRATURE_INPUT_IMAGE_TEXTURE] = glGetUniformLocation(self.temperatureShaderProgram, "inputImageTexture");
    
    //饱和度值
    glViewUniforms2[UNIFORM_TEMPERATURE] = glGetUniformLocation(self.temperatureShaderProgram, "temperature");
    
    glEnableVertexAttribArray(glViewAttributes2[ATTRIBUTE_POSITION2]);
    glEnableVertexAttribArray(glViewAttributes2[ATTRIBUTE_TEMPERATURE_INPUT_TEXTURE_COORDINATE]);
}

- (void)setupVBOs {
   
    //顶点坐标和纹理坐标
    static const CustomVertex vertices[] =
    {
        { .position = { -1.0, -1.0, 0, 1 }, .textureCoordinate = { 0.0, 0.0 } },
        { .position = {  1.0, -1.0, 0, 1 }, .textureCoordinate = { 1.0, 0.0 } },
        { .position = { -1.0,  1.0, 0, 1 }, .textureCoordinate = { 0.0, 1.0 } },
        { .position = {  1.0,  1.0, 0, 1 }, .textureCoordinate = { 1.0, 1.0 } }
    };
    
    //初始化缓存区
    //创建VBO的3个步骤
    //1.生成新缓存对象glGenBuffers
    //2.绑定缓存对象glBindBuffer
    //3.将顶点数据拷贝到缓存对象中glBufferData

    GLuint vertexBuffer;
    
    // STEP 1 创建缓存对象并返回缓存对象的标识符
    glGenBuffers(1, &vertexBuffer);

    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

-(void)renderFirstLayer{
    //绘制第一个滤镜
    //使用program
    glUseProgram(self.saurationShaderProgram);
    
    glBindFramebuffer(GL_FRAMEBUFFER, saurationFrameBuffer);
    //设置清屏颜色
    glClearColor(0, 1, 0, 1);
    
    //清理屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    //为当前的program指定uniform值
    /*
     glUniform1i (GLint location, GLint x)
     参数列表:
     1.location,位置
     2.value,值
     */
    //纹理
    glUniform1i(glViewUniforms2[UNIFORM_SATURATION_INPUT_IMAGE_TEXTURE], 1);//注意这个地方最后的1 对应前面绑定的GL_TEXTURE1，如果是0就对应 GL_TEXTURE0，
    //饱和度
    glUniform1f(glViewUniforms2[UNIFORM_SATURATION], self.sauration);
    
    //顶点数据
    glVertexAttribPointer(glViewAttributes2[ATTRIBUTE_POSITION], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    //纹理数据
    glVertexAttribPointer(glViewAttributes2[ATTRIBUTE_SATURATION_INPUT_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
 
}
-(void)renderSecondLayer{
    //绘制第一个滤镜
    //使用program
    glUseProgram(self.temperatureShaderProgram);

    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    //设置清屏颜色
    glClearColor(0, 1, 0, 1);

    //清理屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    //为当前的program指定uniform值
    /*
     glUniform1i (GLint location, GLint x)
     参数列表:
     1.location,位置
     2.value,值
     */
    //纹理
    glUniform1i(glViewUniforms2[ATTRIBUTE_TEMPERATURE_INPUT_TEXTURE_COORDINATE], 0);//注意这个地方最后的0 对应前面绑定的GL_TEXTURE0，如果是1就对应 GL_TEXTURE1，
    //饱和度
    glUniform1f(glViewUniforms2[UNIFORM_TEMPERATURE], self.temperature);
    
    //顶点数据
    glVertexAttribPointer(glViewAttributes2[ATTRIBUTE_POSITION2], 4, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), 0);
    //纹理数据
    glVertexAttribPointer(glViewAttributes2[ATTRIBUTE_TEMPERATURE_INPUT_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, sizeof(CustomVertex), (GLvoid *)(sizeof(float) * 4));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
//设置纹理从图片
- (void)setupTextureWithImage:(UIImage *)image {
    
    //1.获取图片宽\高
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    
    
    //2.获取颜色组件
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //3.计算图片数据大小->开辟空间
    void *imageData = malloc( height * width * 4 );
    //CG开头的方法都是来自于CoreGraphics这个框架
    //了解CoreGraphics 框架
    
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 8,
                                                 4 * width,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //创建完context,可以释放颜色空间colorSpace
    CGColorSpaceRelease( colorSpace );
    
    /*
     绘制透明矩形。如果所提供的上下文是窗口或位图上下文，则核心图形将清除矩形。对于其他上下文类型，核心图形以设备依赖的方式填充矩形。但是，不应在窗口或位图上下文以外的上下文中使用此函数
     CGContextClearRect(CGContextRef cg_nullable c, CGRect rect)
     参数:
     1.C,绘制矩形的图形上下文。
     2.rect,矩形，在用户空间坐标中。
     */
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    //CTM--从用户空间和设备空间存在一个转换矩阵CTM
    /*
     CGContextTranslateCTM(CGContextRef cg_nullable c,
     CGFloat tx, CGFloat ty)
     参数1:上下文
     参数2:X轴上移动距离
     参数3:Y轴上移动距离
     */
    CGContextTranslateCTM(context, 0, height);
    //缩小
    CGContextScaleCTM (context, 1.0,-1.0);
    
    //绘制图片
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    //释放context
    CGContextRelease(context);
    //在绑定纹理之前,激活纹理单元 glActiveTexture
    glActiveTexture(GL_TEXTURE1);
    
    //生成纹理标记
    glGenTextures(1, &_texture);
    
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    //设置纹理参数
    //环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    //放大\缩小过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    //将图片载入纹理
    /*
     glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels)
     参数列表:
     1.target,目标纹理
     2.level,一般设置为0
     3.internalformat,纹理中颜色组件
     4.width,纹理图像的宽度
     5.height,纹理图像的高度
     6.border,边框的宽度
     7.format,像素数据的颜色格式
     8.type,像素数据数据类型
     9.pixels,内存中指向图像数据的指针
     */
    glTexImage2D(GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 (GLint)width,
                 (GLint)height,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 imageData);
    
    //释放imageData
    free(imageData);
    
}
@end
