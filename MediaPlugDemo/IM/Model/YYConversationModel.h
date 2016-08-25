//
//  YYConversationModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/14.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  聊天会话model


#import "YYBaseModel.h"

@class XHMessage;


@interface YYConversationModel : YYBaseModel

/**
 *  会话的ID(单人对方ID、群聊天ID、聊天室ID)
 */
@property (nonatomic, copy) NSString *conversationID;
/**
 *  会话名称
 */
@property (nonatomic, copy) NSString *conversationName;
/**
 *  未读数
 */
@property (nonatomic, assign) NSInteger unreadCount;
/**
 *  icon图片地址
 */
@property (nonatomic, copy) NSString *iconURL;
/**
 *  消息目标类型
 */
@property (nonatomic, assign) YYChatTargetType targetType;
/**
 *  最新一条消息
 */
@property (nonatomic, strong) XHMessage *lastMsg;
/**
 *  当前授权登陆的用户ID
 */
@property (nonatomic, copy) NSString *userID;


@end
