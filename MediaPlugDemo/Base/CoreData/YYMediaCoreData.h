//
//  YYMediaCoreData.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/5.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  数据持久化

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YYConversationEntity;
@class YYConversationModel;
@class YYMessageEntity;
@class XHMessage;
@class YYUserModel;
@class YYUserEntity;


@interface YYMediaCoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


#pragma mark - MsgList
/**
 *  通过userid获取会话列表
 *
 *  @param uid 用户ID
 *  @param err 错误句柄
 *
 *  @return 会话列表／nil
 */
- (NSArray *)getConvEntitiesWithUid:(NSString *)uid error:(NSError **)err;
/**
 *  新建一条会话
 *
 *  @param model 会话
 *  @param err   错误句柄
 *
 *  @return 加入后的会话
 */
- (YYConversationEntity *)createConvEntity:(YYConversationModel *)model error:(NSError **)err;
/**
 *  根据会话ID查询会话
 *
 *  @param convID 会话ID
 *  @param userID 当前授权登陆的用户ID
 *  @param err    错误句柄
 *
 *  @return 查询结果，没有则返回nil
 */
- (YYConversationEntity *)fetchConvEntityConvID:(NSString *)convID userID:(NSString *)userID error:(NSError **)err;

/**
 *  删除一条会话
 *
 *  @param convID 单聊:对方userid；群聊:群ID
 *  @param userid 当前用户ID
 *  @param err    错误句柄
 */
- (void)deleteConvEntityConvID:(NSString *)convID userID:(NSString *)userID error:(NSError **)err;

#pragma mark - MessageEntity
/**
 *  根据会话ID
 *
 *  @param convID 会话ID
 *  @param offset 跳过的数量
 *  @param err    错误句柄
 *
 *  @return 某一会话下的所有会话(一次50条)
 */
- (NSArray *)getAllMessageEntityConversationID:(NSString *)convID offset:(NSInteger)offset error:(NSError **)err;
/**
 *  新建一个聊天消息，若果有则更新这个聊天消息
 *
 *  @param chatMsg 聊天model
 *  @param convID  会话ID
 *  @param err     错误句柄
 *
 *  @return 新建／更新的聊天消息
 */
- (YYMessageEntity *)createMessageEntity:(XHMessage *)chatMsg conversationID:(NSString *)convID error:(NSError **)err;
/**
 *  根据聊天消息ID查询聊天消息
 *
 *  @param msgID 消息ID
 *  @param err   错误句柄
 *
 *  @return 查询后的消息或者nil
 */
- (YYMessageEntity *)fetchMessageEntityMsgID:(NSString *)msgID error:(NSError **)err;
/**
 *  查询某一会话下的所有未读消息数
 *
 *  @param convID 会话ID
 *  @param err    错误句柄
 *
 *  @return 未读数
 */
- (NSInteger)fetchUnreadMsg:(NSString *)convID error:(NSError **)err;
/**
 *  更新一条消息为已读
 *
 *  @param msgID 消息ID
 *  @param err   错误句柄
 *
 *  @return 更新后的消息记录
 */
- (YYMessageEntity *)updateMsgEntityReaded:(NSString *)msgID error:(NSError *__autoreleasing *)err;
/**
 *  更新所有消息都为已读
 *
 *  @param convID 会话ID
 *  @param err    错误句柄
 */
- (void)updateAllMsgToReaded:(NSString *)convID error:(NSError *__autoreleasing *)err;

/**
 *  更新一条消息记录是否下载了原图
 *
 *  @param msgID 消息ID
 *  @param err   错误句柄
 *
 *  @return 更新后的消息实体
 */
- (YYMessageEntity *)updateMsgEntityLoadedWithMsgID:(NSString *)msgID error:(NSError **)err;
/**
 *  更新一条消息记录的服务器端消息
 *
 *  @param serverID 服务器端消息ID
 *  @param msgID    本地消息ID
 *  @param err      错误句柄
 *
 *  @return 更新后的消息记录
 */
- (YYMessageEntity *)updateMessageServerID:(NSString *)serverID msgID:(NSString *)msgID error:(NSError **)err;
/**
 *  更细一小消息记录的文件ID
 *
 *  @param fileID 文件ID
 *  @param msgID  本地消息ID
 *  @param err    错误句柄
 *
 *  @return 更新后的消息记录
 */
- (YYMessageEntity *)updateMessageFileID:(NSString *)fileID msgID:(NSString *)msgID error:(NSError **)err;

/**
 *  根据消息ID删除消息
 *
 *  @param msgID 消息ID
 *  @param err   错误句柄
 */
- (void)deleteMessageEntityMsgID:(NSString *)msgID error:(NSError **)err;
/**
 *  清空所有会话下的的聊天消息
 *
 *  @param convID 会话ID
 *  @param err    错误句柄
 */
- (void)clearAllMessageEntitiesConvID:(NSString *)convID error:(NSError **)err;

#pragma mark - UserEntity

- (YYUserEntity *)createUserEntityUserModel:(YYUserModel *)userModel error:(NSError *__autoreleasing *)err;

- (YYUserEntity *)fetchUserEntityWithUserID:(NSString *)userID error:(NSError *__autoreleasing *)err;

- (void)deleteUserEntity:(NSString *)userID error:(NSError *__autoreleasing *)err;

@end
