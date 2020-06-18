//
//  VideoCaptureView.h
//  CCMediaTutorial
//
//  Created by Jerry Chen on 2020/6/16.
//  Copyright © 2020 Jerry Chen. All rights reserved.
//

#import "CCGLView.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoCaptureView : CCGLView
@property(nonatomic,assign)BOOL ready;
-(void)laodTextureFormSampleBuffer:(CMSampleBufferRef)sampleBuffer;
-(void)draw;
@end

NS_ASSUME_NONNULL_END
