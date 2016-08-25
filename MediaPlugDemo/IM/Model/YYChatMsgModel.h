//
//  YYIMChatModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/20.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  消息聊天model

#import "YYBaseModel.h"
#import <UIKit/UIKit.h>
#import "XHMessageBubbleFactory.h"
#import "XHMessage.h"


@class YYUserModel;

/**
 *  聊天一条信息model
 */
@interface YYChatMsgModel : YYBaseModel

/**
 *  信息ID
 */
@property (nonatomic, copy) NSString *messageID;
/**
 *  发送者信息
 */
@property (nonatomic, strong) YYUserModel *sender;
/**
 *  附加消息内容
 */
@property (nonatomic, strong) NSData *extContent;
/**
 *  信息具体的内容
 */
@property (nonatomic, strong) XHMessage *messageContent;


@property (nonatomic, copy) NSString *audioSpanID;

@property (nonatomic, copy) NSString *fileID;

@property (nonatomic, assign) NSInteger fileLength;

@property (nonatomic, assign) NSInteger filePieceSize;

@property (nonatomic, copy) NSString *serverMsgID;


+  (instancetype)initWithHistoryDic:(NSDictionary *)dic;

@end