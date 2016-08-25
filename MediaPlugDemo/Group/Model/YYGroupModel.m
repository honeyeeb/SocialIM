//
//  YYGroupListModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupModel.h"
#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "WChatCommon.h"
#import "YYUserModel.h"

@implementation YYGroupModel

+ (instancetype)initGroupList:(NSDictionary *)dic {
    YYGroupModel *model = [[YYGroupModel alloc]init];
    [model initGroupList:dic];
    return model;
}

- (void)initGroupList:(NSDictionary *)dic {
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        [self setGroupID:[NSString stringWithFormat:@"%@", dic[@"gid"]]];
        [self setGroupName:[NSString stringWithFormat:@"%@", dic[@"name"]]];
        [self setGroupMemberRole:[dic[@"role"] integerValue]];
        [self setGroupDesc:[NSString stringWithFormat:@"%@", dic[@"intra"]]];
        [self setMemberCount:[dic[@"members"] integerValue]];
        [self setMaxMemberCount:[dic[@"maxMembers"] integerValue]];
    }
}

@end


#pragma mark - 群组列表

@interface YYGroupManage ()

@property (nonatomic, strong) NSMutableArray *mutGroupArray;

@end

@implementation YYGroupManage

- (NSMutableArray *)mutGroupArray {
    if (!_mutGroupArray) {
        _mutGroupArray = [NSMutableArray array];
    }
    return _mutGroupArray;
}

- (NSArray *)groupListArray {
    return self.mutGroupArray;
}

/**
 *  解析群组列表
 *
 *  @param response 返回群组列表信息
 */
- (NSArray *)parseGroupListArray:(NSArray *)response {
    NSMutableArray *mutable = [NSMutableArray array];
    if (response) {
        for (id tmp in response) {
            [mutable addObject:[YYGroupModel initGroupList:tmp]];
        }
    }
    return mutable;
}

- (NSArray *)parseMembersArray:(NSArray *)response {
    NSMutableArray *mutable = [NSMutableArray array];
    if (response) {
        for (id tmp in response) {
            [mutable addObject:[YYUserModel initWithDic:tmp]];
        }
    }
    return mutable;
}

- (void)getGroupListHandler:(void (^)(NSArray *, NSError *err))handler {
    WEAKSELF
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK getUserGroupsHandler:^(NSArray *groups, NSError *requestError) {
        
        NSArray *result = [weakSelf parseGroupListArray:groups];
        handler(result, requestError);
    }];
}

- (void)createGroup:(NSString *)name description:(NSString *)desc completion:(void (^)(NSError *err))handler {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK groupCreateName:name description:desc categary:WChatGroupCategaryPublic completion:^(NSDictionary *response, NSError *err) {
        handler(err);
    }];
}

- (void)exitGroup:(NSString *)gid completion:(void (^)(NSError *))handler {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK groupExit:gid completionHandler:^(BOOL isExit, NSError *requestError) {
        handler(requestError);
    }];
}

- (void)getGroupInfo:(NSString *)gid completion:(void (^)(YYGroupModel *group, NSError *err))handler {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK groupGetInfo:gid completion:^(NSDictionary *response, NSError *err) {
        YYGroupModel *groupModel = [YYGroupModel initGroupList:response];
        handler(groupModel, err);
    }];
}

- (void)searchGroup:(NSString *)content completion:(void (^)(NSError *err))handler {
    
}

- (void)getGroupMember:(NSString *)gid completion:(void (^)(NSArray *members, NSError *err))handler {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK groupGetMember:gid completion:^(NSArray *users, NSError *requestError) {
        NSArray *result = [self parseMembersArray:users];
        handler(result, requestError);
    }];
}

- (void)groupInviteUsers:(NSArray *)userid groupID:(NSString *)gid completion:(void (^)(NSError *err))handler {
    if (userid) {
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK group:gid addUser:userid completionHandler:^(BOOL isAdd, NSError *requestError) {
            handler(requestError);
        }];
    }
}

- (void)groupRemoveMember:(NSString *)gid members:(NSArray *)members completion:(void (^)(NSError *err))handler {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK group:gid delUser:members completionHandler:^(BOOL isDel, NSError *requestError) {
        handler(requestError);
    }];
}

@end