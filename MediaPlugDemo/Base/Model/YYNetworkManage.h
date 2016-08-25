//
//  YYNetworkManage.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/8/22.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYUserModel;

@interface YYNetworkManage : NSObject


+ (void)getUserInfoWithUserID:(NSString *)userID completion:(void (^)(YYUserModel *user))handler;


@end
