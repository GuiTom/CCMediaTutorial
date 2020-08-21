//
//  ParticleView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/8/16.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "ParticleView.h"
#define NUM_PARTICLES 1000
typedef struct {
    GLfloat x,y,z;
} Vertex;
@interface ParticleView()
@property(nonatomic,assign)GLuint textureIdSlot;
@property(nonatomic,assign)GLuint frameCount;
@end
@implementation ParticleView

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self complileShader:@"particle" shaderrf:@"particle"];

    self.textureIdSlot = glGetUniformLocation(self.shaderProgram, "s_texture");
    [self setupTexture:@"particle.png"];
    
    srand ( 0 );
    [self renderLayer];
}
- (void)renderLayer {
    self.frameCount++;
    glClearColor(0.0f,0.0f, 1.0, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    Vertex *vetexs = (Vertex*)calloc(NUM_PARTICLES, sizeof(Vertex));
   
    for (int i=0; i<NUM_PARTICLES; i++) {
        GLfloat x = ( float ) ( rand() % NUM_PARTICLES )/NUM_PARTICLES - 0.5f;
        GLfloat y = ( float ) ( rand() % NUM_PARTICLES )/NUM_PARTICLES - 0.5f;
        Vertex v = {x,y,0};
        vetexs[i] = v;
    }
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), vetexs);
    glUniform1i(self.textureIdSlot, 0);
    glDrawArrays(GL_POINTS, 0, NUM_PARTICLES);
    free(vetexs);
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
  
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
 
    //5、在CGContextRef上绘图

    CGRect rect = CGRectMake(0, 0, width, height);
    //使用默认方式绘制，发现图片是倒的。
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);

    //6、画图完毕就释放上下文
    CGContextRelease(spriteContext);
    
    //5、绑定纹理到默认的纹理ID（这里只有一张图片，故而相当于默认于片元着色器里面的colorMap，如果有多张图不可以这么做）
    glBindTexture(GL_TEXTURE_2D, 0);
    
    //设置纹理属性
 
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    float fw = width, fh = height;
    //载入纹理2D数据

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
@end
