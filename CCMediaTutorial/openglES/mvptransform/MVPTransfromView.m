//
//  MVPTransfromView.m
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/13.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "MVPTransfromView.h"
#import "GLESUtils.h"
#import "GLESMath.h"
@interface MVPTransfromView()
@property (nonatomic , assign) GLuint myVertices;
@end

@implementation MVPTransfromView

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self complileShader:@"shaderMVP" shaderrf:@"shaderMVP"];
    [self renderLayer];
}
- (void)renderLayer {
        glClearColor(0, 0.0, 0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);

        GLuint indices[] =
        {
            0, 3, 2,
            0, 1, 3,
            0, 2, 4,
            0, 4, 1,
            2, 3, 4,
            1, 4, 3,
        };

        if (self.myVertices == 0) {
            glGenBuffers(1, &_myVertices);
        }
        GLfloat attrArr[] =
        {
            -0.5f, 0.5f, 0.0f,      1.0f, 0.0f, 1.0f, //左上
            0.5f, 0.5f, 0.0f,       1.0f, 0.0f, 1.0f, //右上
            -0.5f, -0.5f, 0.0f,     1.0f, 1.0f, 1.0f, //左下
            0.5f, -0.5f, 0.0f,      1.0f, 1.0f, 1.0f, //右下
            0.0f, 0.0f, 3.0f,       0.0f, 1.0f, 0.0f, //顶点
        };
        glBindBuffer(GL_ARRAY_BUFFER, _myVertices);
        glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, _myVertices);

        GLuint position = glGetAttribLocation(self.shaderProgram, "position");
        glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, NULL);
        glEnableVertexAttribArray(position);

        GLuint positionColor = glGetAttribLocation(self.shaderProgram, "positionColor");
        glVertexAttribPointer(positionColor, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (float *)NULL + 3);
        glEnableVertexAttribArray(positionColor);

        GLuint projectionMatrixSlot = glGetUniformLocation(self.shaderProgram, "projectionMatrix");
        GLuint modelViewMatrixSlot = glGetUniformLocation(self.shaderProgram, "modelViewMatrix");

        float width = self.frame.size.width;
        float height = self.frame.size.height;


        KSMatrix4 _projectionMatrix;
        ksMatrixLoadIdentity(&_projectionMatrix);
        float aspect = width / height; //长宽比


        ksPerspective(&_projectionMatrix, 30.0, aspect, 5.0f, 20.0f); //透视变换，视角30°

        glEnable(GL_CULL_FACE);


        KSMatrix4 _modelViewMatrix;
        ksMatrixLoadIdentity(&_modelViewMatrix);

        //平移
        ksTranslate(&_projectionMatrix, 0.0, 0.0, -7);
        KSMatrix4 _rotationMatrix;
        ksMatrixLoadIdentity(&_rotationMatrix);

        //旋转
//        ksRotate(&_rotationMatrix, degree, 1.0, 0.0, 0.0); //绕X轴
//        ksRotate(&_rotationMatrix, yDegree, 0.0, 1.0, 0.0); //绕Y轴

        //把变换矩阵相乘，注意先后顺序
    //    ksMatrixMultiply(&_projectionMatrix, &_rotationMatrix, &_projectionMatrix);
        ksMatrixMultiply(&_modelViewMatrix, &_modelViewMatrix, &_rotationMatrix);



        //设置glsl里面的投影矩阵
        glUniformMatrix4fv(projectionMatrixSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);

        // Load the model-view matrix
        glUniformMatrix4fv(modelViewMatrixSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);



        glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(indices[0]), GL_UNSIGNED_INT, indices);

        [self.context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
