//
//  YYGroupListModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseModel.h"
#import "WChatCommon.h"


/**
 *  群组列表model
 */
@interface YYGroupModel : YYBaseModel

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, copy) NSString *groupName;

@property (nonatomic, copy) NSString *groupDesc;

@property (nonatomic, copy) NSString *createrID;

@property (nonatomic, assign) NSInteger memberCount;

@property (nonatomic, assign) NSInteger maxMemberCount;

@property (nonatomic, assign) WChatGroupCategary groupCategary;

@property (nonatomic, assign) YYGroupMemberRoleType groupMemberRole;

+ (instancetype)initGroupList:(NSDictionary *)dic;

- (void)initGroupList:(NSDictionary *)dic;

@end

/**
 *  用户拥有的群组列表
 */
@interface YYGroupManage : YYBaseModel

//@property (nonatomic, strong, readonly) NSArray *groupListArray;
/**
 *  获取群组列表
 *
 *  @param handler 回调
 */
- (void)getGroupListHandler:(void (^)(NSArray *groups, NSError *err))handler;
/**
 *  创建一个群组
 *
 *  @param name    群组名称
 *  @param desc    群简介
 *  @param handler 回调
 */
- (void)createGroup:(NSString *)name description:(NSString *)desc completion:(void (^)(NSError *err))handler;
/**
 *  退出群组
 *
 *  @param gid     群ID
 *  @param handler 回调
 */
- (void)exitGroup:(NSString *)gid completion:(void (^)(NSError *))handler;
/**
 *  获取群组信息
 *
 *  @param gid     群滴
 *  @param handler 回调
 */
- (void)getGroupInfo:(NSString *)gid completion:(void (^)(YYGroupModel *group, NSError *err))handler;
/**
 *  查询群组
 *
 *  @param content 查询条件
 *  @param handler 回调
 */
- (void)searchGroup:(NSString *)content completion:(void (^)(NSError *err))handler;
/**
 *  获取群组成员
 *
 *  @param gid     群ID
 *  @param handler 回调
 */
- (void)getGroupMember:(NSString *)gid completion:(void (^)(NSArray *members, NSError *err))handler;
/**
 *  群组邀请群成员
 *
 *  @param userid  用户ID
 *  @param gid     群组ID
 *  @param handler 回调
 */
- (void)groupInviteUsers:(NSArray *)userid groupID:(NSString *)gid completion:(void (^)(NSError *err))handler;
/**
 *  群组删除群成员
 *
 *  @param gid     群组ID
 *  @param members 成员ID数组
 *  @param handler 回调
 */
- (void)groupRemoveMember:(NSString *)gid members:(NSArray *)members completion:(void (^)(NSError *err))handler;

@end