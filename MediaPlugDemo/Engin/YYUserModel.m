//
//  UserModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/5/30.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYUserModel.h"


@implementation YYUserModel

+ (instancetype)initWithDic:(NSDictionary *)dic {
    YYUserModel *model = [[YYUserModel alloc]init];
    [model initWithDic:dic];
    return model;
}

- (void)initWithDic:(NSDictionary *)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        [self setUserID:[NSString stringWithFormat:@"%@", [dic objectForKey:@"id"]]];
        [self setGender:[NSString stringWithFormat:@"%@", [dic objectForKey:@"gender"]]];
        [self setUserNickName:[NSString stringWithFormat:@"%@", [dic objectForKey:@"nickname"]]];
        [self setFriendCount:[NSString stringWithFormat:@"%@", [dic objectForKey:@"friends_count"]]];
        [self setUserCreateTime:[NSString stringWithFormat:@"%@", [dic objectForKey:@"created_at"]]];
        [self setRoleType:[dic[@"role"] integerValue]];
        [self setDistance:[NSString stringWithFormat:@"%@", dic[@"distance"]]];
    }
}

@end
