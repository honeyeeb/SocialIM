//
//  YYContactsModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYContactManager.h"
#import "YYUserModel.h"
#import "MediaPlusSDK+IM.h"
#import "YYMediaSDKEngine.h"


@interface YYContactManager ()



@end

@implementation YYContactManager


- (NSArray *)parseUserContactArray:(NSArray *)response {
    NSMutableArray *mutable = [NSMutableArray array];
    if (response) {
        for (id tmp in response) {
            [mutable addObject:[YYUserModel initWithDic:tmp]];
        }
    }
    return mutable;
}

- (void)getNearbayContact:(double)latitude
                longitude:(double)longitude
                    range:(long)range
               completion:(void (^)(NSArray *response, NSError *err))handler {
    NSString *url = [NSString stringWithFormat:@"%@/recommend/users/nearby", [YYMediaSDKEngine hostURL]];
    NSString *param = [NSString stringWithFormat:@"uid=%@&longitude=%f&latitude=%f&range=%ld", [YYMediaSDKEngine sharedInstance].userModel.userID, longitude, latitude, range];
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialAsyncRequest:@"GET" url:url params:param callbackId:0 timeout:10.0 completion:^(NSDictionary *json, NSError *error) {
        int apistatus = [json[@"apistatus"] intValue];
        NSArray *users;
        if (apistatus == 1) {
            users = [self parseUserContactArray:[NSArray arrayWithArray:json[@"result"][@"users"]]];
        } else {
            
        }
        handler(users, error);
    }];
}


@end
