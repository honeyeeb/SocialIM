//
//  YYConversationModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/14.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYConversationModel.h"

#import "YYChatMsgModel.h"
#import "YYUserModel.h"


@implementation YYConversationModel

- (instancetype)init {
    if (self = [super init]) {
        _iconURL = @"iconImg";
    }
    return self;
}


+ (instancetype)testInit {
    YYConversationModel *convModel = [[YYConversationModel alloc]init];
    [convModel setConversationID:@"149419"];
    [convModel setConversationName:@"honeybee"];
    [convModel setUnreadCount:2];
    [convModel setIconURL:@"iconImg"];
    
    return convModel;
}

@end
