//
//  YYPhoneCallModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  电话model


#import "YYBaseModel.h"

typedef NS_ENUM(NSInteger, YYPhoneCallType) {
    YYPhoneCallModelSender,
    YYPhoneCallModelReceive,
    
};


@interface YYPhoneCallModel : YYBaseModel



@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) YYPhoneCallType callType;



@end
