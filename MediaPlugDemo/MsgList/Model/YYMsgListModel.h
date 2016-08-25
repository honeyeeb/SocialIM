//
//  MsgListModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseModel.h"


/**
 *  消息列表cell model
 */
@interface YYMsgListModel : YYBaseModel

/**
 *  消息ID(单人／群组ID)
 */
@property (nonatomic, copy) NSString *msgid;
/**
 *  当前登录的uid
 */
@property (nonatomic, copy) NSString *userid;
/**
 *  群名称／人名称
 */
@property (nonatomic, copy) NSString *title;
/**
 *  最后一条消息
 */
@property (nonatomic, copy) NSString *detailTitle;
/**
 *  时间
 */
@property (nonatomic, assign) NSTimeInterval timeTitle;
/**
 *  最新一条消息类型
 */
@property (nonatomic, assign) YYMessageMediaType mediaType;
/**
 *  消息目标类型
 */
@property (nonatomic, assign) YYChatTargetType targetType;
/**
 *  消息未读数
 */
@property (nonatomic, assign) NSInteger unreadNum;
/**
 *  头像
 */
@property (nonatomic, copy) NSString *msgIcon;


@end

/**
 *  消息列表model
 */
@interface YYMsgListManager : YYBaseModel

@property (nonatomic, strong, readonly) NSArray *msgListArray;


+ (instancetype)initMsgLists;

- (void)initMsgLists;

- (void)addMsg:(YYMsgListModel *)msg;

- (void)removeMsg:(YYMsgListModel *)msg;

- (void)removeAllMsg;

@end