//
//  XHMessage.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessage.h"
#import <objc/runtime.h>

#import "YYMediaSDKEngine.h"
#import "YYMsgManager.h"
#import "YYMsgUtils.h"


@implementation XHMessage

- (instancetype)initWithText:(NSString *)text
                      sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.text = text;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = XHBubbleMessageMediaTypeText;
    }
    return self;
}

/**
 *  初始化图片类型的消息
 *
 *  @param photo          目标图片
 *  @param thumbnailUrl   目标图片在服务器的缩略图地址
 *  @param originPhotoUrl 目标图片在服务器的原图地址
 *  @param sender         发送者
 *  @param date           发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithPhoto:(UIImage *)photo
                 thumbnailUrl:(NSString *)thumbnailUrl
               originPhotoUrl:(NSString *)originPhotoUrl
                       sender:(NSString *)sender
                         timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.photo = photo;
        self.thumbnailUrl = thumbnailUrl;
        self.originPhotoUrl = originPhotoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = XHBubbleMessageMediaTypePhoto;
    }
    return self;
}

/**
 *  初始化视频类型的消息
 *
 *  @param videoConverPhoto 目标视频的封面图
 *  @param videoPath        目标视频的本地路径，如果是下载过，或者是从本地发送的时候，会存在
 *  @param videoUrl         目标视频在服务器上的地址
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVideoConverPhoto:(UIImage *)videoConverPhoto
                               videoPath:(NSString *)videoPath
                                videoUrl:(NSString *)videoUrl
                                  sender:(NSString *)sender
                                    timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.videoConverPhoto = videoConverPhoto;
        self.videoPath = videoPath;
        self.videoUrl = videoUrl;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = XHBubbleMessageMediaTypeVideo;
    }
    return self;
}

/**
 *  初始化语音类型的消息
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp {
    
    return [self initWithVoicePath:voicePath voiceUrl:voiceUrl voiceDuration:voiceDuration sender:sender timestamp:timestamp isRead:YES];
}

/**
 *  初始化语音类型的消息。增加已读未读标记
 *
 *  @param voicePath        目标语音的本地路径
 *  @param voiceUrl         目标语音在服务器的地址
 *  @param voiceDuration    目标语音的时长
 *  @param sender           发送者
 *  @param date             发送时间
 *  @param isRead           已读未读标记
 *
 *  @return 返回Message model 对象
 */
- (instancetype)initWithVoicePath:(NSString *)voicePath
                         voiceUrl:(NSString *)voiceUrl
                    voiceDuration:(NSString *)voiceDuration
                           sender:(NSString *)sender
                        timestamp:(NSDate *)timestamp
                           isRead:(BOOL)isRead {
    self = [super init];
    if (self) {
        self.voicePath = voicePath;
        self.voiceUrl = voiceUrl;
        self.voiceDuration = voiceDuration;
        
        self.sender = sender;
        self.timestamp = timestamp;
        self.isRead = isRead;
        
        self.messageMediaType = XHBubbleMessageMediaTypeVoice;
    }
    return self;
}

- (instancetype)initWithEmotionPath:(NSString *)emotionPath
                          sender:(NSString *)sender
                            timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.emotionPath = emotionPath;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = XHBubbleMessageMediaTypeEmotion;
    }
    return self;
}

- (instancetype)initWithLocalPositionPhoto:(UIImage *)localPositionPhoto
                              geolocations:(NSString *)geolocations
                                  location:(CLLocation *)location
                                    sender:(NSString *)sender
                                 timestamp:(NSDate *)timestamp {
    self = [super init];
    if (self) {
        self.localPositionPhoto = localPositionPhoto;
        self.geolocations = geolocations;
        self.location = location;
        
        self.sender = sender;
        self.timestamp = timestamp;
        
        self.messageMediaType = XHBubbleMessageMediaTypeLocalPosition;
    }
    return self;
}

+  (instancetype)initWithHistoryDic:(NSDictionary *)dic {
    XHMessage *model = [[XHMessage alloc]init];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        
        XHBubbleMessageType direction = XHBubbleMessageTypeSending;
        NSDictionary *ext = [NSJSONSerialization JSONObjectWithData:dic[@"extBody"] options:NSJSONReadingMutableContainers error:nil];
        
        UInt64 msgID = [[YYMsgUtils sharedInstance] getMsgID];
        
        Byte fileType = *(Byte*)[dic[@"fileType"] bytes];
        if (fileType == YYWChatFileTypeText) {
            
            model = [[XHMessage alloc]initWithText:[[NSString alloc] initWithData:dic[@"content"] encoding:NSUTF8StringEncoding] sender:@"" timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
            
        } else if (fileType == YYWChatFileTypeVoice) {
            NSData *voiceData = dic[@"content"];
            NSString *spanId = [dic[@"spanId"] description];
            NSString *wavPath = [YYMsgUtils corverFromAmrData:voiceData spanID:spanId];
            
            model = [[XHMessage alloc]initWithVoicePath:wavPath voiceUrl:nil voiceDuration:[ext[kVoiceDuration] description] sender:@"" timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
            model.messageMediaType = XHBubbleMessageMediaTypeVoice;
            
        } else if (fileType == YYWChatFileTypeImage) {
            NSData *thumb = dic[@"thumbnail"];
            if (thumb) {
                [thumb writeToFile:[YYMsgUtils getThumbImageStorePathWithMsgId:msgID] atomically:YES];
            }
            NSLog(@"history image length :%ld", thumb.length);
            UIImage *imgs = [UIImage imageWithData:thumb];
            model = [[XHMessage alloc]initWithPhoto:imgs thumbnailUrl:nil originPhotoUrl:nil sender:@"" timestamp:[NSDate dateWithTimeIntervalSince1970:[dic[@"time"] doubleValue]]];
            model.messageMediaType = XHBubbleMessageMediaTypePhoto;
            
        }
        if (model) {
            
            NSString *from = [dic[@"fromUid"] description];
            NSString *nickName = ext[kUserNickName];
            
            if ([from isEqualToString:[YYMediaSDKEngine sharedInstance].userModel.userID]) {
                model.senderID = [dic[@"toUid"] description];
                model.sender = [YYMediaSDKEngine sharedInstance].userModel.userNickName;
            } else {
                direction = XHBubbleMessageTypeReceiving;
                model.senderID = [dic[@"fromUid"] description];
                model.sender = nickName;
            }
            
            model.extContent = dic[@"extBody"];
            model.messageID = [NSString stringWithFormat:@"%llu", msgID];
            model.fileID = [dic[@"fileId"] description];
            model.fileLength = [dic[@"filelength"] integerValue];
            model.serverMsgID = [dic[@"messageId"] description];
            model.filePieceSize = [dic[@"pieceSize"] integerValue];
            model.audioSpanID = [dic[@"spanId"] description];
            model.isLoaded = NO;
            model.isRead = YES;
            model.sended = YES;
            model.bubbleMessageType = direction;
            model.avatar = [UIImage imageNamed:@"iconImg"];
            
        }
        
    }
    return model;
}

- (void)dealloc {
    _text = nil;
    
    _photo = nil;
    _thumbnailUrl = nil;
    _originPhotoUrl = nil;
    
    _videoConverPhoto = nil;
    _videoPath = nil;
    _videoUrl = nil;
    
    _voicePath = nil;
    _voiceUrl = nil;
    _voiceDuration = nil;
    
    _emotionPath = nil;
    
    _localPositionPhoto = nil;
    _geolocations = nil;
    _location = nil;
    
    _avatar = nil;
    _avatarUrl = nil;
    
    _sender = nil;
    
    _timestamp = nil;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        // 取出i位置对应的成员变量
        Ivar ivar = ivars[i];
        // 查看成员变量
        const char *name = ivar_getName(ivar);
        // 归档
        NSString *key = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
    free(ivars);
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            // 取出i位置对应的成员变量
            Ivar ivar = ivars[i];
            // 查看成员变量
            const char *name = ivar_getName(ivar);
            // 归档
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [decoder decodeObjectForKey:key];
            // 设置到成员变量身上
            [self setValue:value forKey:key];
            
        }
        free(ivars);
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    switch (self.messageMediaType) {
        case XHBubbleMessageMediaTypeText:
            return [[[self class] allocWithZone:zone] initWithText:[self.text copy]
                                                            sender:[self.sender copy]
                                                              timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypePhoto:
            return [[[self class] allocWithZone:zone] initWithPhoto:[self.photo copy]
                                                       thumbnailUrl:[self.thumbnailUrl copy]
                                                     originPhotoUrl:[self.originPhotoUrl copy]
                                                             sender:[self.sender copy]
                                                               timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeVideo:
            return [[[self class] allocWithZone:zone] initWithVideoConverPhoto:[self.videoConverPhoto copy]
                                                                     videoPath:[self.videoPath copy]
                                                                      videoUrl:[self.videoUrl copy]
                                                                        sender:[self.sender copy]
                                                                          timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeVoice:
            return [[[self class] allocWithZone:zone] initWithVoicePath:[self.voicePath copy]
                                                               voiceUrl:[self.voiceUrl copy]
                                                          voiceDuration:[self.voiceDuration copy]
                                                                 sender:[self.sender copy]
                                                              timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeEmotion:
            return [[[self class] allocWithZone:zone] initWithEmotionPath:[self.emotionPath copy]
                                                                sender:[self.sender copy]
                                                                  timestamp:[self.timestamp copy]];
        case XHBubbleMessageMediaTypeLocalPosition:
            return [[[self class] allocWithZone:zone] initWithLocalPositionPhoto:[self.localPositionPhoto copy]
                                                                    geolocations:self.geolocations
                                                                        location:[self.location copy]
                                                                          sender:[self.sender copy]
                                                                            timestamp:[self.timestamp copy]];
        default:
            return nil;
    }
}

@end
