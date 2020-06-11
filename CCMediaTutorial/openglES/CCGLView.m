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

-(void)setUpLayer{
     self.eaglLayer =  (CAEAGLLayer*)self.layer;
     //设置放大倍数
     [self setContentScaleFactor:[[UIScreen mainScreen]scale]];
    
     self.eaglLayer.opaque = YES;
     
     self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
}
+(Class)layerClass{
    return [CAEAGLLayer class];
}
@end
