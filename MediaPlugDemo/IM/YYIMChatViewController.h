//
//  YYIMChatViewController.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  聊天主页面

#import "XHMessageTableViewController.h"

@interface YYIMChatViewController : XHMessageTableViewController
/**
 *  聊天的会话ID(单人：对方userID；群组：群组ID)
 */
@property (nonatomic, copy) NSString *targetid;
/**
 *  聊天的会话名称(单人：对方userName；群组：群组名称)
 */
@property (nonatomic, copy) NSString *targetName;
/**
 *  会话类型
 */
@property (nonatomic, assign) YYChatTargetType targetType;


@end
