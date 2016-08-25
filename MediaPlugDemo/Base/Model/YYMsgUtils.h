//
//  YYMsgID.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/8/17.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 通过时间标识本地的消息ID
@interface YYMsgUtils : NSObject

@property (nonatomic, assign, readonly) UInt64 msgIDTime;

+ (instancetype)sharedInstance;

- (UInt64)getMsgID;

#pragma mark - Tools

+ (NSString *)getLocalRecordAudioPathBySpanId:(id)spanId;
+ (NSString *)geResendAudioPathByMsgId:(id)msgId;
+ (NSString *)getPeerRecordAudioPathBySpanId:(id)spanId;
+ (NSString *)getImageStorePathWithMsgId:(UInt64)msgId;
+ (NSString *)getThumbImageStorePathWithMsgId:(UInt64)msgId;

+ (NSString *)corverFromAmrData:(NSData *)amrData spanID:(NSString *)spanID;

+ (NSString *)corverFromWavAmrPath:(NSString *)path spanID:(NSString *)spanID;

@end
