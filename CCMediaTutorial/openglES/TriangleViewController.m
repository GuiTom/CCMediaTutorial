//
//  TriangleViewController.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/11.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "TriangleViewController.h"
#import <OpenGLES/ES2/gl.h>
#import "CCGLView.h"
@interface TriangleViewController ()
@property(nonatomic,strong)EAGLContext *context;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;
@property(nonatomic,assign)GLuint shaderPrograme;
@end

@implementation TriangleViewController
-(void)loadView{
    self.view = [CCGLView new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [(CCGLView*)self.view setUpLayer];
    
    [self setupContext];
    

    [self resetRenderAndFrameBuffer];
    
    [self setupColorRenderBuffer];
    
    [self setupFrameRenderBuffer];
    
    [self setupViewPort];
    
//    [self complileShader];
    
    [self renderLayer];
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
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.view.layer];

}
/**
 初始化一个帧缓冲区
 */
-(void)setupFrameRenderBuffer{
    glGenRenderbuffers(1,&_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.colorRenderBuffer);
}
-(void)renderLayer{
//    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
//    GLfloat vertexs[] =
//    {
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
//        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
//        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
//        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
//    };
//    GLuint attrBuffer;
//
//    glGenBuffers(1, &attrBuffer);
//
//    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
//
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_DYNAMIC_DRAW);
//
//    GLuint position = glGetAttribLocation(self.shaderPrograme, "position");
//
//    glEnableVertexAttribArray(position);
//    //设置顶点数据的读取方式
//    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
//
//
//    GLuint textCoor = glGetAttribLocation(self.shaderPrograme, "textCoordinate");
//
//    glEnableVertexAttribArray(textCoor);
//
//    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
//
//    [self setupTexture:@"1.jpg"];
//
//
//
//    GLuint rotate = glGetUniformLocation(self.shaderPrograme, "rotateMatrix");
//
//
//    float radians = 10 * 3.14159f / 180.0f;
//
//    float s = sin(radians);
//    float c = cos(radians);
//
//
//    GLfloat zRotation[16] = {
//        c, -s, 0, 0,
//        s, c, 0, 0,
//        0, 0, 1.0, 0,
//        0.0, 0, 0, 1.0
//    };
//    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat*)&zRotation);
//    glDrawArrays(GL_TRIANGLES, 0, 6);
//
//    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    //设置清屏颜色
    glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    //清除屏幕
    glClear(GL_COLOR_BUFFER_BIT);
    
    //1.设置视口大小
    CGFloat scale = [[UIScreen mainScreen]scale];
    glViewport(self.view.frame.origin.x * scale, self.view.frame.origin.y * scale, self.view.frame.size.width * scale, self.view.frame.size.height * scale);
    
    //2.读取顶点着色程序、片元着色程序
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertFile);
    NSLog(@"fragFile:%@",fragFile);
    
    //3.加载shader
    self.shaderPrograme = [self loadShaders:vertFile Withfrag:fragFile];
    
    //4.链接
    glLinkProgram(self.shaderPrograme);
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.shaderPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.shaderPrograme, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    
    NSLog(@"Program Link Success!");
    //5.使用program
    glUseProgram(self.shaderPrograme);
    
    //6.设置顶点、纹理坐标
    //前3个是顶点坐标，后2个是纹理坐标
    GLfloat attrArr[] =
    {
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        -0.5f, -0.5f, -1.0f,    0.0f, 0.0f,
        0.5f, 0.5f, -1.0f,      1.0f, 1.0f,
        -0.5f, 0.5f, -1.0f,     0.0f, 1.0f,
        0.5f, -0.5f, -1.0f,     1.0f, 0.0f,
    };
    
    /*
     1.解决渲染图片倒置问题：
     GLfloat attrArr[] =
     {
     0.5f, -0.5f, 0.0f,        1.0f, 1.0f, //右下
     -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
     -0.5f, -0.5f, 0.0f,       0.0f, 1.0f, // 左下
     0.5f, 0.5f, 0.0f,         1.0f, 0.0f, // 右上
     -0.5f, 0.5f, 0.0f,        0.0f, 0.0f, // 左上
     0.5f, -0.5f, 0.0f,        1.0f, 1.0f, // 右下
     };
     */
    
    //-----处理顶点数据--------
    //顶点缓存区
    GLuint attrBuffer;
    //申请一个缓存区标识符
    glGenBuffers(1, &attrBuffer);
    //将attrBuffer绑定到GL_ARRAY_BUFFER标识符上
    glBindBuffer(GL_ARRAY_BUFFER, attrBuffer);
    //把顶点数据从CPU内存复制到GPU上
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);

    //将顶点数据通过myPrograme中的传递到顶点着色程序的position
    //1.glGetAttribLocation,用来获取vertex attribute的入口的.2.告诉OpenGL ES,通过glEnableVertexAttribArray，3.最后数据是通过glVertexAttribPointer传递过去的。
    //注意：第二参数字符串必须和shaderv.vsh中的输入变量：position保持一致
    GLuint position = glGetAttribLocation(self.shaderPrograme, "position");
    
    //2.设置合适的格式从buffer里面读取数据
    glEnableVertexAttribArray(position);
    
    //3.设置读取方式
    //参数1：index,顶点数据的索引
    //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
    //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    //参数5：stride,连续顶点属性之间的偏移量，默认为0；
    //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, NULL);
    
    
    //----处理纹理数据-------
    //1.glGetAttribLocation,用来获取vertex attribute的入口的.
    //注意：第二参数字符串必须和shaderv.vsh中的输入变量：textCoordinate保持一致
    GLuint textCoor = glGetAttribLocation(self.shaderPrograme, "textCoordinate");
    
    //2.设置合适的格式从buffer里面读取数据
    glEnableVertexAttribArray(textCoor);
    
    //3.设置读取方式
    //参数1：index,顶点数据的索引
    //参数2：size,每个顶点属性的组件数量，1，2，3，或者4.默认初始值是4.
    //参数3：type,数据中的每个组件的类型，常用的有GL_FLOAT,GL_BYTE,GL_SHORT。默认初始值为GL_FLOAT
    //参数4：normalized,固定点数据值是否应该归一化，或者直接转换为固定值。（GL_FALSE）
    //参数5：stride,连续顶点属性之间的偏移量，默认为0；
    //参数6：指定一个指针，指向数组中的第一个顶点属性的第一个组件。默认为0
    glVertexAttribPointer(textCoor, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, (float *)NULL + 3);
    
    
    //加载纹理
    [self setupTexture:@"1.jpg"];
    
    //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    /*
     一个一致变量在一个图元的绘制过程中是不会改变的，所以其值不能在glBegin/glEnd中设置。一致变量适合描述在一个图元中、一帧中甚至一个场景中都不变的值。一致变量在顶点shader和片断shader中都是只读的。首先你需要获得变量在内存中的位置，这个信息只有在连接程序之后才可获得
     */
    //rotate等于shaderv.vsh中的uniform属性，rotateMatrix
    GLuint rotate = glGetUniformLocation(self.shaderPrograme, "rotateMatrix");
    
    //获取渲染的弧度
    float radians = 10 * 3.14159f / 180.0f;
    //求得弧度对于的sin\cos值
    float s = sin(radians);
    float c = cos(radians);
    
    //z轴旋转矩阵 参考3D数学第二节课的围绕z轴渲染矩阵公式
    //为什么和公司不一样？因为在3D课程中用的是横向量，在OpenGL ES用的是列向量
    GLfloat zRotation[16] = {
        c, -s, 0, 0,
        s, c, 0, 0,
        0, 0, 1.0, 0,
        0.0, 0, 0, 1.0
    };
    
    //设置旋转矩阵
    glUniformMatrix4fv(rotate, 1, GL_FALSE, (GLfloat *)&zRotation[0]);
    
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
//设置纹理
- (GLuint)setupTexture:(NSString *)fileName {
    //1、获取图片的CGImageRef
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    
    //判断图片是否获取成功
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    //2、读取图片的大小，宽和高
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    //3.获取图片字节数 宽*高*4（RGBA）
    GLubyte * spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
    
    //4.创建上下文
    /*
     参数1：data,指向要渲染的绘制图像的内存地址
     参数2：width,bitmap的宽度，单位为像素
     参数3：height,bitmap的高度，单位为像素
     参数4：bitPerComponent,内存中像素的每个组件的位数，比如32位RGBA，就设置为8
     参数5：bytesPerRow,bitmap的没一行的内存所占的比特数
     参数6：colorSpace,bitmap上使用的颜色空间  kCGImageAlphaPremultipliedLast：RGBA
     */
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
 
    //5、在CGContextRef上绘图
    /*
     CGContextDrawImage 使用的是Core Graphics框架，坐标系与UIKit 不一样。UIKit框架的原点在屏幕的左上角，Core Graphics框架的原点在屏幕的左下角。
     CGContextDrawImage
     参数1：绘图上下文
     参数2：rect坐标
     参数3：绘制的图片
     */
    CGRect rect = CGRectMake(0, 0, width, height);
    //使用默认方式绘制，发现图片是倒的。
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    /*
     解决图片倒置的方法(2):
     CGContextTranslateCTM(spriteContext, rect.origin.x, rect.origin.y);
     CGContextTranslateCTM(spriteContext, 0, rect.size.height);
     CGContextScaleCTM(spriteContext, 1.0, -1.0);
     CGContextTranslateCTM(spriteContext, -rect.origin.x, -rect.origin.y);
     CGContextDrawImage(spriteContext, rect, spriteImage);
     */
   
    //6、画图完毕就释放上下文
    CGContextRelease(spriteContext);
    
    //5、绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //设置纹理属性
    /*
     参数1：纹理维度
     参数2：线性过滤、为s,t坐标设置模式
     参数3：wrapMode,环绕模式
     */
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    //载入纹理2D数据
    /*
     参数1：纹理模式，GL_TEXTURE_1D、GL_TEXTURE_2D、GL_TEXTURE_3D
     参数2：加载的层次，一般设置为0
     参数3：纹理的颜色值GL_RGBA
     参数4：宽
     参数5：高
     参数6：border，边界宽度
     参数7：format
     参数8：type
     参数9：纹理数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, fw, fh, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //绑定纹理
    /*
     参数1：纹理维度
     参数2：纹理ID,因为只有一个纹理，给0就可以了。
     */
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //释放spriteData
    free(spriteData);
    
    return 0;
}

-(void)setupViewPort{
    CGFloat scale = [UIScreen mainScreen].scale;
    
    glViewport(0, 0, self.view.frame.size.width*scale, self.view.frame.size.height*scale);
    
}

-(void)complileShader{
    //2.读取顶点着色程序、片元着色程序
    NSString *vertFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertFile);
    NSLog(@"fragFile:%@",fragFile);
    
    //3.加载shader
    self.shaderPrograme = [self loadShaders:vertFile Withfrag:fragFile];
    
    //4.链接
    glLinkProgram(self.shaderPrograme);
    GLint linkStatus;
    //获取链接状态
    glGetProgramiv(self.shaderPrograme, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[512];
        glGetProgramInfoLog(self.shaderPrograme, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    NSLog(@"Program Link Success!");
    //5.使用program
    glUseProgram(self.shaderPrograme);
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
@end