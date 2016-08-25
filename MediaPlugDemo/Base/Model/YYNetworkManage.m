//
//  YYNetworkManage.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/8/22.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYNetworkManage.h"

#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "YYUserModel.h"

@implementation YYNetworkManage

+ (void)getUserInfoWithUserID:(NSString *)userID completion:(void (^)(YYUserModel *))handler {
    if (userID) {
        NSInteger callback = [[YYMediaSDKEngine sharedInstance] getConnectTag];
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialAsyncRequest:@"GET" url:[NSString stringWithFormat:@"%@/users/show", [YYMediaSDKEngine hostURL]] params:[NSString stringWithFormat:@"uid=%@", userID] callbackId:callback timeout:20.0 completion:^(NSDictionary *json, NSError *error) {
            NSInteger apistatus = [json[@"apistatus"] integerValue];
            if (apistatus == 1) {
                NSDictionary *result = json[@"result"];
                if (result) {
                    YYUserModel *user = [[YYUserModel alloc]init];
                    user.userID = [NSString stringWithFormat:@"%@", result[@"id"]];
                    user.userNickName = [NSString stringWithFormat:@"%@", result[@"nickname"]];
                    handler(user);
                }
            }
        }];
    }
}

@end
