//
//  YYConferenceModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/22.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  电话会议model


#import "YYBaseModel.h"
#import "WChatCommon.h"


@interface YYConferenceModel : YYBaseModel

@property (nonatomic, copy) NSString *fromUsrID;

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *startTime;

@property (nonatomic, copy) NSString *endTime;

@property (nonatomic, strong) NSArray *users;

@property (nonatomic, assign) cfcallbackType callBackType;


@end
