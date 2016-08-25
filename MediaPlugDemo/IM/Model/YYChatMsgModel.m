//
//  YYIMChatModel.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/20.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYChatMsgModel.h"

#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "YYUserModel.h"
#import "WChatCommon.h"
#import "YYMsgManager.h"

/// 通过时间标识本地的消息ID
@interface YYMsgID : NSObject

@property (nonatomic, assign) UInt64 msgIDTime;

+ (instancetype)sharedInstance;

- (UInt64)getMsgID;

@end

static YYMsgID *sharedMsgID = nil;
@implementation YYMsgID

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMsgID = [[YYMsgID alloc]init];
    });
    return sharedMsgID;
}

- (UInt64)getMsgID {
    if (!_msgIDTime) {
        _msgIDTime = (UInt64)[[NSDate date]timeIntervalSince1970] * 1000;
    }
    return _msgIDTime++;
}

@end


@interface YYChatMsgModel ()


@end

@implementation YYChatMsgModel

- (instancetype)init {
    if (self = [super init]) {
        _sender = [[YYUserModel alloc]init];
        _messageContent = [[XHMessage alloc]init];
    }
    return self;
}

- (NSString *)messageID {
    return [NSString stringWithFormat:@"%llu", [[YYMsgID sharedInstance] getMsgID]];
}

+  (instancetype)initWithHistoryDic:(NSDictionary *)dic {
    YYChatMsgModel *model = [[YYChatMsgModel alloc]init];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        YYUserModel *user = [[YYUserModel alloc]init];
        
        XHBubbleMessageType direction = XHBubbleMessageTypeSending;
        NSString *from = [dic[@"fromUid"] description];
        NSDictionary *ext = [NSJSONSerialization JSONObjectWithData:dic[@"extBody"] options:NSJSONReadingMutableContainers error:nil];
        NSString *nickName = ext[kUserNickName];
        if ([from isEqualToString:[YYMediaSDKEngine sharedInstance].userModel.userID]) {
            user.userID = [dic[@"toUid"] description];
            user.userNickName = [YYMediaSDKEngine sharedInstance].userModel.userNickName;
        } else {
            direction = XHBubbleMessageTypeReceiving;
            user.userID = [dic[@"fromUid"] description];
            user.userNickName = nickName;
        }
        
        model.sender = user;
        model.extContent = dic[@"extBody"];
        
        model.fileID = [dic[@"fileId"] description];
        model.fileLength = [dic[@"filelength"] integerValue];
        model.serverMsgID = [dic[@"messageId"] description];
        model.filePieceSize = [dic[@"pieceSize"] integerValue];
        model.audioSpanID = [dic[@"spanId"] description];
        
        XHMessage *message;
        Byte fileType = *(Byte*)[dic[@"fileType"] bytes];
        XHBubbleMessageMediaType mediaType = XHBubbleMessageMediaTypeText;
        NSData *thumbData = dic[@"content"];
        switch (fileType) {
            case YYWChatFileTypeText:
                message = [[XHMessage alloc]initWithText:[[NSString alloc] initWithData:dic[@"content"] encoding:NSUTF8StringEncoding] sender:[dic[@"fromUid"] description] timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
                break;
            case YYWChatFileTypeVoice:
                
                message = [[XHMessage alloc]initWithVoicePath:[YYMsgManager getLocalRecordAudioPathBySpanId:model.audioSpanID] voiceUrl:nil voiceDuration:ext[kVoiceDuration] sender:@"" timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
                
                mediaType = XHBubbleMessageMediaTypeVoice;
                break;
                
            case YYWChatFileTypeImage:
                
                if (thumbData) {
                    [thumbData writeToFile:[YYMsgManager getThumbImageStorePathWithMsgId:[model.messageID integerValue]] atomically:YES];
                }
                UIImage *imgs = [UIImage imageWithData:thumbData];
                message = [[XHMessage alloc]initWithPhoto:imgs thumbnailUrl:nil originPhotoUrl:nil sender:[dic[@"fromUid"] description] timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
                
                mediaType = XHBubbleMessageMediaTypePhoto;
                break;
                
        }
        if (message) {
            message.bubbleMessageType = direction;
            message.messageMediaType = mediaType;
            message.avatar = [UIImage imageNamed:@"iconImg"];
            
            model.messageContent = message;
        }
        
    }
    return model;
}

@end
