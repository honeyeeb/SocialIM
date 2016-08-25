//
//  YYGroupInfoViewController.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/7.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  群组信息页面

#import "YYBaseTableViewController.h"

// 清空所有聊天记录
extern NSString *const kGroupInfoClearAllMessageNF;


@interface YYGroupInfoViewController : YYBaseTableViewController

@property (nonatomic, copy) NSString *groupID;

@end
