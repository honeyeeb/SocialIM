//
//  UserModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/5/30.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYBaseModel.h"

@interface YYUserModel : YYBaseModel


/**
 *  用户ID
 */
@property (nonatomic, copy) NSString    * userID;
/**
 *  昵称
 */
@property (nonatomic, copy) NSString    * userNickName;
/**
 *  创建时间
 */
@property (nonatomic, copy) NSString    * userCreateTime;
/**
 *  朋友数量
 */
@property (nonatomic, copy) NSString    * friendCount;
/**
 *  性别
 */
@property (nonatomic, copy) NSString    * gender;
/**
 *  附近的人距离(米)
 */
@property (nonatomic, copy) NSString    * distance;
/**
 *  用户角色
 */
@property (nonatomic, assign) YYGroupMemberRoleType roleType;


+ (instancetype)initWithDic:(NSDictionary *)dic;

- (void)initWithDic:(NSDictionary *)dic;


@end
