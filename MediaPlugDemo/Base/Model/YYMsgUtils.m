//
//  YYMsgID.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/8/17.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMsgUtils.h"
#import "YYMediaSDKEngine.h"
#import "Voice.h"


static YYMsgUtils *sharedMsgID = nil;
@implementation YYMsgUtils

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMsgID = [[YYMsgUtils alloc]init];
    });
    return sharedMsgID;
}

- (UInt64)getMsgID {
    if (!_msgIDTime) {
        _msgIDTime = (UInt64)[[NSDate date]timeIntervalSince1970] * 1000;
    }
    return _msgIDTime++;
}

#pragma mark - Tools

+ (BOOL)createPathIfNecessary:(NSString*)path {
    BOOL succeeded = YES;
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        succeeded = [fm createDirectoryAtPath: path
                  withIntermediateDirectories: YES
                                   attributes: nil
                                        error: nil];
    }
    
    return succeeded;
}

+ (BOOL)removeItemAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSError *err;
        BOOL success = [fm removeItemAtPath:path error:&err];
        if (err) {
            NSLog(@"remove file error %@, path :%@", err, path);
        }
        return success;
    }
    return NO;
}

+ (NSString *)documentDirectotyPath:(NSString *)name {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (![name isEmptyString]) {
        path = [path stringByAppendingPathComponent:name];
    }
    [YYMsgUtils createPathIfNecessary:path];
    
    return path;
}

+ (NSString *)getAudioStorePathWithMsgId:(NSString*)msgid {
    NSString *audioPath = [[YYMsgUtils documentDirectotyPath:[NSString stringWithFormat:@"accounts/%@/audio", [YYMediaSDKEngine sharedInstance].userModel.userID]] stringByAppendingPathComponent:msgid];
    return audioPath;
}

+ (NSString *)getLocalRecordAudioPathBySpanId:(id)spanId {
    NSString *localpath = [NSString stringWithFormat:@"%@.wav", [YYMsgUtils getAudioStorePathWithMsgId:[NSString stringWithFormat:@"%@", spanId]]];
    return localpath;
}

+ (NSString *)getTempRecodAudioPathByUnionid:(id)unionid {
    NSString *localpath = [NSString stringWithFormat:@"%@.wav", [YYMsgUtils getAudioStorePathWithMsgId:[NSString stringWithFormat:@"%@", unionid]]];
    return localpath;
}

+ (NSString *)geResendAudioPathByMsgId:(id)msgId {
    NSString *localpath = [NSString stringWithFormat:@"%@.amr", [YYMsgUtils getAudioStorePathWithMsgId:[NSString stringWithFormat:@"%@", msgId]]];
    return localpath;
}

+ (NSString *)getPeerRecordAudioPathBySpanId:(id)spanId {
    NSString *localpath = [NSString stringWithFormat:@"%@.amr", [YYMsgUtils getAudioStorePathWithMsgId:[NSString stringWithFormat:@"%@", spanId]]];
    return localpath;
}

+ (NSString*)getImageStorePathWithMsgId:(UInt64)msgId {
    NSString* imageFilePath = [[YYMsgUtils documentDirectotyPath:[NSString stringWithFormat:@"accounts/%@/image", [YYMediaSDKEngine sharedInstance].userModel.userID]] stringByAppendingPathComponent:[[NSNumber numberWithLongLong:msgId] description]];
    return imageFilePath;
}

+ (NSString*)getThumbImageStorePathWithMsgId:(UInt64)msgId {
    NSString* thumbImageFilePath = [[YYMsgUtils documentDirectotyPath:[NSString stringWithFormat:@"accounts/%@/image", [YYMediaSDKEngine sharedInstance].userModel.userID]] stringByAppendingPathComponent:[NSString stringWithFormat:@"thumb_%@", [[NSNumber numberWithLongLong:msgId] description]]];
    return thumbImageFilePath;
}

+ (NSString *)corverFromAmrData:(NSData *)amrData spanID:(NSString *)spanID {
    if (!amrData || !spanID) {
        return nil;
    }
    NSString *tmpPath = [YYMsgUtils getPeerRecordAudioPathBySpanId:spanID];
    [amrData writeToFile:tmpPath atomically:YES];
    // 需要把amr音频转wav格式才能播放
    NSString *wavPath = [YYMsgUtils getLocalRecordAudioPathBySpanId:spanID];
    [VoiceRecorder AMR2WAV:tmpPath wav:wavPath];
    [YYMsgUtils removeItemAtPath:tmpPath];
    
    return wavPath;
}

+ (NSString *)corverFromWavAmrPath:(NSString *)path spanID:(NSString *)spanID {
    if (!path || !spanID) {
        return nil;
    }
    NSString *amrPath = [YYMsgUtils getPeerRecordAudioPathBySpanId:spanID];
    [VoiceRecorder WAV2AMR:path amr:amrPath];
    
    return amrPath;
}

@end
