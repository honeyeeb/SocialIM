//
//  MsgListModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMsgListModel.h"
#import "YYMediaSDKEngine.h"
#import "YYMediaCoreData.h"

@implementation YYMsgListModel

- (instancetype)init {
    if (self = [super init]) {
//        [self setTitle:@"游云"];
//        [self setDetailTitle:@"Detail"];
//        [self setUserid:@"10086"];
//        [self setUnreadNum:3];
//        [self setMsgid:@"10010"];
//        [self setMsgIcon:@"iconImg"];
//        [self setMediaType:YYMessageMediaTypeText];
//        [self setTargetType:YYChatTargetTypeSingle];
//        [self setTimeTitle:[[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

@end


@interface YYMsgListManager ()

@property (nonatomic, strong) NSMutableArray *mutMsgListArray;

@end


@implementation YYMsgListManager


+ (instancetype)initMsgLists {
    YYMsgListManager *list = [[YYMsgListManager alloc]init];
    [list initMsgLists];
    return list;
}

- (void)initMsgLists {
    self.mutMsgListArray = [NSMutableArray arrayWithArray:[[YYMediaCoreData sharedInstance] getMsgEntitiesWithUid:[YYMediaSDKEngine sharedInstance].userModel.userID error:nil]];
}

- (NSMutableArray *)mutMsgListArray {
    if (!_mutMsgListArray) {
        _mutMsgListArray = [NSMutableArray array];
    }
    return _mutMsgListArray;
}

- (NSArray *)msgListArray {
    return _mutMsgListArray;
}

- (void)addMsg:(YYMsgListModel *)msg {
    if (![self.mutMsgListArray containsObject:msg]) {
        [self.mutMsgListArray insertObject:msg atIndex:0];
    }
}

- (void)removeMsg:(YYMsgListModel *)msg {
    if ([self.mutMsgListArray containsObject:msg]) {
        [self.mutMsgListArray removeObject:msg];
    }
}

- (void)removeAllMsg {
    if (self.mutMsgListArray.count > 0) {
        [self.mutMsgListArray removeAllObjects];
    }
}

@end
