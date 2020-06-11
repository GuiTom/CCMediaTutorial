//
//  CCGLView.h
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/11.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCGLView : UIView
@property(nonatomic,strong)CAEAGLLayer *eaglLayer;
-(void)setUpLayer;
@end

NS_ASSUME_NONNULL_END
