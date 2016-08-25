//
//  YYMsgManager.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  消息管理


#import "YYBaseModel.h"

#import "XHMessage.h"

@class YYConversationModel;
@class YYConversationEntity;


typedef NS_ENUM(NSInteger, YYChatHistoryType) {
    YYChatHistoryTypeSingle,
    YYChatHistoryTypeGroup,
};

/**
 *  消息动态监听(会话改变、添加、删除)
 */
@protocol YYMsgListener <NSObject>

@optional
/**
 *  消息增加
 *
 *  @param msgs         消息列表
 *  @param conversation 会话
 */
- (void)msgsAdded:(NSArray*)msgs conversation:(YYConversationModel*)conversation;
- (void)msgsUpdated:(NSArray*)msgs conversation:(YYConversationModel*)conversation;
- (void)msgsDeleted:(NSArray*)msgIds conversation:(YYConversationModel*)conversation;
- (void)msgsInsert:(NSArray *)msgs conversation:(YYConversationModel*)conversation;
/**
 *  会话增加
 *
 *  @param conversation 增加的会话
 */
- (void)conversationAdded:(YYConversationModel*)conversation;
- (void)conversationDeleted:(YYConversationModel*)conversation;
- (void)conversationUpdate:(YYConversationModel*)conversation;
- (void)conversationsClear;
- (void)conversationClearAllMsgs:(YYConversationModel*)conversation;
- (void)conversationUnreadedNumChange:(YYConversationModel*)conversation;

@end


#pragma mark - 消息管理

@interface YYMsgManager : YYBaseModel

/**
 *  消息管理单例
 *
 *  @return 实例化的单例
 */
+ (instancetype)sharedInstance;

/**
 *  添加消息监听对象
 *
 *  @param listener 处理消息监听的对象
 */
- (void)addMessageListener:(id)listener;
/**
 *  移除消息监听对象
 *
 *  @param listener 处理消息监听的对象
 */
- (void)removeMessageListener:(id)listener;

/**
 *  发送消息
 *
 *  @param msgModel 消息model
 *  @param convID   会话ID
 *  @param convName 会话名称
 *  @param progress 文件进度回调
 */
- (void)sendMessage:(XHMessage *)msgModel
       conversation:(NSString *)convID
           convName:(NSString *)convName
           progress:(onMsgFileProgressBlock)progress
   conversationType:(YYChatTargetType)convType;
/**
 *  删除所有的聊天内容
 *
 *  @param targetID 当前对话ID
 *  @param err      错误句柄
 */
- (void)clearAllMessages:(NSString *)targetID error:(NSError **)err;
/**
 *  获取图片、文件
 *
 *  @param msg        消息ID
 *  @param completion 完成的回调
 *  @param progress   进度回调
 */
- (void)getFileWithMessage:(XHMessage *)msg completion:(onAppServiceBlock)completion progress:(onMsgFileProgressBlock)progress;

#pragma mark - 会话
/**
 *  获取所有的会话列表
 *
 *  @param err   错误句柄
 *
 *  @return 会话列表
 */
- (NSArray *)getAllConversations:(NSError **)err;
/**
 *  根据用户ID、群ID创建一个会话
 *
 *  @param convID   会话ID
 *  @param convName 会话名称
 *  @param convType 类型
 *
 *  @return 创建的会话
 */
- (YYConversationModel *)createUpConversationTargetID:(NSString *)convID
                                     conversationName:(NSString *)convName
                                              lastMsg:(XHMessage *)msgModel
                                     conversationType:(YYChatTargetType)convType;
/**
 *  根据用户ID、群ID获取一个会话
 *
 *  @param convID 会话ID
 *
 *  @return 查询或者创建的ID
 */
- (YYConversationModel *)getConversationTargetID:(NSString *)convID error:(NSError **)err;
/**
 *  查询一个会话的未读消息数量
 *
 *  @param convID 会话ID
 *
 *  @return 未读数
 */
- (NSInteger)fetchUnreadCountConvID:(NSString *)convID;
/**
 *  通过会话ID查询一条会话记录
 *
 *  @param convID 会话ID
 *  @param err    错误句柄
 *
 *  @return 会话记录
 */
- (YYConversationEntity *)getConversationEntity:(NSString *)convID error:(NSError **)err;
/**
 *  删除一个本地会话纪录和会话中所有的聊天内容
 *
 *  @param convID 会话ID
 *  @param err    错误句柄
 */
- (void)deleteConversationWithID:(NSString *)convID error:(NSError **)err;

/**
 *  获取某一会话下的20条本地聊天内容
 *
 *  @param convID 会话ID
 *  @param offset 偏移量
 *  @param err    错误句柄
 *
 *  @return 本地会话内容(XHMessage)
 */
- (NSArray *)getAllMsgsConvID:(NSString *)convID offset:(NSInteger)offset error:(NSError **)err;
/**
 *  更新一条图片消息下载成功
 *
 *  @param msgID 消息ID
 *  @param err   错误句柄
 */
- (void)updateMessageLoadedMsgID:(NSString *)msgID error:(NSError **)err;
/**
 *  更新一条消息的服务器端ID
 *
 *  @param serverID 服务器端ID
 *  @param msgID    本地消息ID
 *  @param err      错误句柄
 */
- (void)updateMessageServerID:(NSString *)serverID msgID:(NSString *)msgID error:(NSError **)err;
/**
 *  更新所有的消息为已读
 *
 *  @param convID 会话ID
 */
- (void)updateAllMsgToReaded:(NSString *)convID;
/**
 *  更新一条消息记录为已读
 *
 *  @param msgID 消息ID
 */
- (void)updateMsgToReaded:(NSString *)msgID;

// 历史消息
- (void)getChatHistory:(NSString *)targetID timestamp:(NSInteger)time type:(YYChatHistoryType)type completion:(void (^)(NSArray *result, NSError *err))handler;

@end
