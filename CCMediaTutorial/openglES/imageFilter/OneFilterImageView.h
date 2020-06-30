//
//  OneFilterImageView.h
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/30.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "CCGLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OneFilterImageView : CCGLView
@property(nonatomic,assign)float sauration;
-(void)renderLayer;
@end

NS_ASSUME_NONNULL_END
