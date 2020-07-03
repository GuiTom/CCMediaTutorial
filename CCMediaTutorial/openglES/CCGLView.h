//
//  CCGLView.h
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/11.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
NS_ASSUME_NONNULL_BEGIN

@interface CCGLView : UIView
@property(nonatomic,strong)CAEAGLLayer *eaglLayer;
@property(nonatomic,strong)EAGLContext *context;
@property(nonatomic,assign)GLuint colorRenderBuffer;
@property(nonatomic,assign)GLuint frameBuffer;
@property(nonatomic,assign)GLuint shaderProgram;
-(void)setUpLayer;
- (BOOL)checkFramebuffer:(NSError *__autoreleasing *)error ;
-(void)complileShader:(NSString*)shaderrv shaderrf:(NSString*)shaderrf;
@end

NS_ASSUME_NONNULL_END
