//
//  RectangleView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/12.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "RectangleView.h"

@implementation RectangleView

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self complileShader:@"triangle" shaderrf:@"triangle"];
    [self renderLayer];
}
- (void)renderLayer {

    glClearColor(0, 0.5f, 0.0, 1.0);

    glClear(GL_COLOR_BUFFER_BIT);

    GLuint position = glGetAttribLocation(self.shaderPrograme, "position");

    GLuint textCoor = glGetAttribLocation(self.shaderPrograme, "sourceColor");

    const GLfloat Vertices[] = {
        -0.5f,-0.5f,0,0,0,0,// 左下，黑色
        0.5f,-0.5f,0,1,0,0, // 右下，红色
        0.5f,0.5f,0,0,1,0,  // 右上，绿色
        -0.5f,0.5f,0,0,0,1, // 左上，蓝色
    };

    // 索引数组，指定好了绘制三角形的方式
    // 与glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);一样。
    const GLubyte Indices[] = {
        0,1,2, // 三角形0
        0,2,3  // 三角形1
    };

    GLuint vertexBuffer;

    glGenBuffers(1, &vertexBuffer);
    // 绑定vertexBuffer到GL_ARRAY_BUFFER目标
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    // 为VBO申请空间，初始化并传递数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);

    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);

    glEnableVertexAttribArray(position);

    // 取出Colors数组中的每个坐标点的颜色值，赋给_colorSlot
    glVertexAttribPointer(textCoor, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);

    glEnableVertexAttribArray(textCoor);
    //GL_LINE_STRIP 的含义 参看:https://blog.csdn.net/vblegend_2013/article/details/85345102

    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, Indices);
  
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
