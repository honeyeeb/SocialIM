//
//  YYLocationServiceUtil.h
//  YouYunDemo
//
//  Created by Frederic on 16/5/31.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
typedef void(^LocationBlock)(NSString *errorString);
typedef void(^LocationSucessBlock)(CLLocation *location);

@interface YYLocationServiceUtil : NSObject

+(YYLocationServiceUtil *)shareInstance;

//简单判断定位服务是否开启
+ (BOOL)isLocationServiceOpen;

//获取用户地址
- (void)getUserCurrentLocation:(LocationBlock)block location:(LocationSucessBlock)locationSucess;
@end
