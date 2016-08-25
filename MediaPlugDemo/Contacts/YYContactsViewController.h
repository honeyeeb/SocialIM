//
//  YYContactsViewController.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewController.h"

extern NSString *const kGetNearbayMemberNotification;

/**
 *  页面来源
 */
typedef NS_ENUM(NSInteger, YYContactsFromType) {
    /**
     *  主页面(联系人)
     */
    YYContactsFromTypeHome          = 0,
    /**
     *  群组邀请添加
     */
    YYContactsFromTypeGroup,
    /**
     *  音频会议
     */
    YYContactsFromTypeConference,
    
};

@interface YYContactsViewController : YYBaseTableViewController

/**
 *  页面来源
 */
@property (nonatomic, assign) YYContactsFromType fromType;

/**
 *  群组邀请成员的群组ID
 */
@property (nonatomic, copy) NSString *groupID;

@end
