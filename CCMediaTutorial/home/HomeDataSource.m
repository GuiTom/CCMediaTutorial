
//
//  HomeDataSource.m
//  CCKit
//
//  Created by CC on 2020/1/16.
//  Copyright © 2020 CC. All rights reserved.
//

#import "HomeDataSource.h"
@interface HomeDataSource()

@end
@implementation HomeDataSource
+(instancetype)shareInstance{
    static HomeDataSource * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HomeDataSource alloc] init];
    });
    return instance;
}
-(instancetype)init{
    if(self = [super init]){
        [self initDataSource];
    }
    return self;
}
-(void)initDataSource{
    if(!_dataSource){
        _dataSource = @[
            @{
                @"header":@"opengl ES",
                @"cells":@[
                        @{@"title":@"绘制一个三角形"},
                         @{@"title":@"绘制一个矩形"},
                         @{@"title":@"加载一张图片"},
                        @{@"title":@"透视投影变换"},
                        @{@"title":@"视频采集变换"},
                        @{@"title":@"图片滤镜(单滤镜)"},
                        @{@"title":@"图片滤镜(流水线)"},
                        @{@"title":@"粒子系统"}
                ]
            },
            @{
                @"header":@"音视频编解码",
                @"cells":@[
                        @{@"title":@"视频播放器"},
                
                ]
            },
            
        ].mutableCopy;
    }
}

@end
