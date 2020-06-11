//
//  HomeDataSource.h
//  CCKit
//
//  Created by CC on 2020/1/16.
//  Copyright © 2020 CC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeDataSource : NSObject
+(instancetype)shareInstance;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end

NS_ASSUME_NONNULL_END
