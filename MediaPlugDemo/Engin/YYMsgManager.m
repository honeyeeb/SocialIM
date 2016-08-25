//
//  YYMsgManager.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMsgManager.h"

#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "YYMediaCoreData.h"
#import "YYConversationModel.h"
#import "YYMessageEntity.h"
#import "YYConversationEntity.h"
#import "YYMsgUtils.h"


@interface YYMsgManager ()
/**
 *  消息监听
 */
@property (nonatomic, strong) NSMutableArray *mutaMsgListenerArr;

@property (nonatomic, strong) NSArray *allConvsArr;
/**
 *  所有发送中的消息
 */
@property (nonatomic, strong) NSMutableDictionary *allSendMsgDic;

@end


@implementation YYMsgManager

static YYMsgManager *shared = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!shared) {
            shared = [[YYMsgManager alloc]init];
        }
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        if (!shared) {
            shared = [super allocWithZone:zone];
            return shared;
        }
    }
    return nil;
}

- (instancetype)init {
    @synchronized(self) {
        if (self = [super init]) {
            [[YYMediaSDKEngine sharedInstance]addNoTagMediaPlusDelegate:self];
        }
        return self;
    }
}

- (void)dealloc {
    [[YYMediaSDKEngine sharedInstance]removeNoTagMediaPlusDelegate:self];
}

- (NSMutableArray *)mutaMsgListenerArr {
    if (!_mutaMsgListenerArr) {
        _mutaMsgListenerArr = [NSMutableArray array];
    }
    return _mutaMsgListenerArr;
}

- (NSMutableDictionary *)allSendMsgDic {
    if (!_allSendMsgDic) {
        _allSendMsgDic = [NSMutableDictionary dictionary];
    }
    return _allSendMsgDic;
}

- (void)addMessageListener:(id)listener {
    if (![self.mutaMsgListenerArr containsObject:listener]) {
        [self.mutaMsgListenerArr addObject:listener];
    }
}

- (void)removeMessageListener:(id)listener {
    if ([self.mutaMsgListenerArr containsObject:listener]) {
        [self.mutaMsgListenerArr removeObject:listener];
    }
}

- (XHMessage *)changeXHMessageToMessageEntity:(YYMessageEntity *)entity {
    XHMessage *msg = [[XHMessage alloc]init];
    msg.messageID = entity.msgID;
    [msg setText:entity.textContent];
    [msg setSender:entity.senderName];
    [msg setTimestamp:[[NSDate alloc]initWithTimeIntervalSince1970:entity.timestamp.doubleValue]];
    [msg setShouldShowUserName:NO];
    msg.isRead = entity.readed.boolValue;
    msg.sended = entity.sended.boolValue;
    msg.avatar = [UIImage imageNamed:@"iconImg"];
    msg.serverMsgID = entity.serverMsgID;
    msg.extContent = entity.extContent;
    msg.isLoaded = entity.isLoaded.boolValue;
    if (entity.extContent) {
        NSError *err = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:entity.extContent options:NSJSONReadingMutableLeaves | NSJSONReadingMutableLeaves error:&err];
        if(!err) {
            // 语音时间
            [msg setVoiceDuration:[NSString stringWithFormat:@"%@", dic[kVoiceDuration]]];
        }
    }
    // 消息媒体类型
    [msg setMessageMediaType:entity.msgMediaType.integerValue];
    // 发送／接收
    [msg setBubbleMessageType:entity.msgDirection.integerValue];

    if (msg.messageMediaType == XHBubbleMessageMediaTypeText) {
        
    } else if(msg.messageMediaType == XHBubbleMessageMediaTypePhoto) {
        // 图片
        if (msg.isLoaded) {
            // 下载了原图
            NSString *originPath = [[[YYMediaSDKEngine sharedInstance] getImgCachePath]stringByAppendingPathComponent:entity.fileID];
            msg.photo = [UIImage imageWithData:[NSData dataWithContentsOfFile:originPath]];
        } else {
            // 缩略图
            msg.photo = [UIImage imageWithData:[NSData dataWithContentsOfFile:[YYMsgUtils getThumbImageStorePathWithMsgId:entity.thumbnailPath.integerValue]]];
        }
        
        msg.fileID = entity.fileID;
        msg.fileLength = [entity.fileLength integerValue];
        msg.filePieceSize = [entity.filePieceSize integerValue];
        
    } else if (msg.messageMediaType == XHBubbleMessageMediaTypeVoice) {
        // 音频
        msg.audioSpanID = entity.audioSpanID;
        // 本地发的
        if (entity.audioPath) {
            msg.voicePath = entity.audioPath;
        } else {
            // 对方发的，
            msg.voicePath = [YYMsgUtils getLocalRecordAudioPathBySpanId:entity.audioSpanID];
        }
    }
    return msg;
}

- (YYConversationModel *)changeToConvModelFromConvEntity:(YYConversationEntity *)entity {
    YYConversationModel *model = [[YYConversationModel alloc]init];
    model.conversationID = entity.convid;
    model.conversationName = entity.convName;
    model.unreadCount = entity.unreadNum.integerValue;
    model.targetType = entity.msgTargetType.integerValue;
    model.userID = [YYMediaSDKEngine sharedInstance].userModel.userID;
    XHMessage *message = [[XHMessage alloc]init];
    message.text = entity.detailName;
    message.messageMediaType = entity.msgMediaType.integerValue;
    message.timestamp = [NSDate dateWithTimeIntervalSince1970:entity.time.doubleValue];
    
    message.senderID = entity.userid;
    message.sender = entity.userid;
    model.lastMsg = message;
    
    return model;
}

- (void)sendMessage:(XHMessage *)msgModel conversation:(NSString *)convID convName:(NSString *)convName progress:(onMsgFileProgressBlock)progress conversationType:(YYChatTargetType)convType {
    // 如果没有这个会话，就新建一个会话。
    [self createUpConversationTargetID:convID conversationName:convName lastMsg:msgModel conversationType:convType];
    // 创建／更新消息
    NSError *err;
    [[YYMediaCoreData sharedInstance] createMessageEntity:msgModel conversationID:convID error:&err];
    
    WChatMsgTargetType targetType = WChatMsgTargetTypeSingle;
    if (convType == YYChatTargetTypeGroup) {
        targetType = WChatMsgTargetTypeGroup;
    }
    NSMutableDictionary *extDic = [NSMutableDictionary dictionary];
    NSString *name;
    if (YYChatTargetTypeSingle == convType) {
        name = msgModel.sender;
    } else {
        name = convName;
    }
    if (name) {
        // 单聊，对方名称。群聊，群名称
        [extDic setObject:name forKey:kUserNickName];
    }
    NSInteger tag = [[YYMediaSDKEngine sharedInstance] getConnectTag];
    if (XHBubbleMessageMediaTypeText == msgModel.messageMediaType) {
        // 文本
        NSData *extTmp = [NSJSONSerialization dataWithJSONObject:extDic options:NSJSONWritingPrettyPrinted error:nil];
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialSendMsg:convID body:[msgModel.text dataUsingEncoding:NSUTF8StringEncoding] extBody:extTmp withTag:tag withType:YYWChatFileTypeText targetType:targetType withTimeout:20.0 error:&err];
        
    } else if(XHBubbleMessageMediaTypePhoto == msgModel.messageMediaType) {
        // 图片
        [[YYMediaSDKEngine sharedInstance] addFileProgressBlock:progress tag:tag];
        [self compressedImageFiles:msgModel.photo imageKB:40 imageBlock:^(UIImage *image) {
            // 缩略图最大50k
            NSData *origData = UIImageJPEGRepresentation(msgModel.photo, 1);
            NSData *thumbImgData = UIImageJPEGRepresentation(image, 0);
            NSString *nailPath = [YYMsgUtils getThumbImageStorePathWithMsgId:[msgModel.messageID integerValue]];
            [thumbImgData writeToFile:nailPath atomically:YES];
            NSString *fileID = [[YYMediaSDKEngine sharedInstance].mediaPlusSDK getFileIdWithTargetID:convID];
            NSString *origPath = [[[YYMediaSDKEngine sharedInstance] getImgCachePath] stringByAppendingPathComponent:fileID];
            [origData writeToFile:origPath atomically:YES];
            [self updateMessageFileID:fileID msgID:msgModel.messageID error:nil];
            NSData *extTmp = [NSJSONSerialization dataWithJSONObject:extDic options:NSJSONWritingPrettyPrinted error:nil];
            [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialSendFileWithThumbnail:convID fileId:fileID path:origPath nailpath:nailPath extBody:extTmp withIndex:1 withTag:tag filetype:YYWChatFileTypeImage targetType:targetType withTimeout:100.0 error:nil];
            
        }];
        
        
    } else if (XHBubbleMessageMediaTypeVoice == msgModel.messageMediaType) {
        // 语音
        
        if (msgModel.voiceDuration) {
            [extDic setObject:[NSNumber numberWithInteger:[msgModel.voiceDuration integerValue]] forKey:kVoiceDuration];
        } else {
            [extDic setObject:[NSNumber numberWithInteger:0] forKey:kVoiceDuration];
        }
        NSString *amrpath = [YYMsgUtils getPeerRecordAudioPathBySpanId:msgModel.audioSpanID];
        NSData *extTmp = [NSJSONSerialization dataWithJSONObject:extDic options:NSJSONWritingPrettyPrinted error:nil];
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialSendVoice:convID spanId:msgModel.audioSpanID sequenceNo:-1 content:[NSData dataWithContentsOfFile:amrpath] ext:extTmp withTag:tag targetType:targetType withTimeout:100.0 error:&err];
        NSLog(@"===send voice path :%@", amrpath);
    }
    
    [self.allSendMsgDic setObject:msgModel.messageID forKey:[NSString stringWithFormat:@"%ld", (long)tag]];
}

- (void)getChatHistory:(NSString *)targetID timestamp:(NSInteger)time type:(YYChatHistoryType)type completion:(void (^)(NSArray *result, NSError *err))handler {
    WEAKSELF
    if (YYChatHistoryTypeSingle == type) {
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK getHistoryByUser:targetID timestamp:time size:20 completionHandler:^(NSArray *history, NSError *requestError) {
            // 存储到本地数据库
            NSArray *arr = [weakSelf parseHistoryResults:history targetID:targetID];
            handler(arr, requestError);
        }];
    } else if (YYChatHistoryTypeGroup == type) {
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK getHistoryByGroup:targetID timestamp:time size:20 completionHandler:^(NSArray *history, NSError *requestError) {
            // 存储到本地数据库
            NSArray *arr = [weakSelf parseHistoryResults:history targetID:targetID];
            handler(arr, requestError);
        }];
    }
}

- (NSArray *)parseHistoryResults:(NSArray *)history targetID:(NSString *)targetID {
    NSMutableArray *muteHist = [NSMutableArray array];
    if (history && [history isKindOfClass:[NSArray class]]) {
        for (NSInteger i = history.count - 1; i >= 0; i--) {
            XHMessage *chatModel = [XHMessage initWithHistoryDic:history[i]];
            [muteHist addObject:chatModel];
        }
    }
    [self insertMessagesWithChatMsgModel:muteHist conversationID:targetID];
    return muteHist;
}

- (void)insertMessagesWithChatMsgModel:(NSArray *)chatModel conversationID:(NSString *)convID {
    NSError *err;
    for (XHMessage *chat in chatModel) {
        [[YYMediaCoreData sharedInstance] createMessageEntity:chat conversationID:convID error:&err];
        if (err) {
            NSLog(@"===%s===%@", __FUNCTION__, err);
        }
    }
    NSArray *tmpListener = [NSArray arrayWithArray:_mutaMsgListenerArr];
    for (id tmp in tmpListener) {
        if ([tmp respondsToSelector:@selector(msgsInsert:conversation:)]) {
            YYConversationModel *conv = [[YYConversationModel alloc]init];
            conv.conversationID = convID;
            conv.conversationName = convID;
            [tmp msgsInsert:chatModel conversation:conv];
        }
    }
}

- (void)clearAllMessages:(NSString *)targetID error:(NSError **)err{
    if (targetID) {
        [[YYMediaCoreData sharedInstance] clearAllMessageEntitiesConvID:targetID error:err];
    }
}

- (void)deleteConverID:(NSString *)conversion error:(NSError **)err {
    if (conversion) {
        [[YYMediaCoreData sharedInstance] deleteConvEntityConvID:conversion userID:[YYMediaSDKEngine sharedInstance].userModel.userID error:err];
    }
}

- (void)getFileWithMessage:(XHMessage *)msg completion:(onAppServiceBlock)completion progress:(onMsgFileProgressBlock)progress {
    NSInteger callbackTag = [[YYMediaSDKEngine sharedInstance] getConnectTag];
    [[YYMediaSDKEngine sharedInstance] addAppServiceBlock:completion tag:callbackTag];
    [[YYMediaSDKEngine sharedInstance] addFileProgressBlock:progress tag:callbackTag];
    if (msg.messageMediaType == XHBubbleMessageMediaTypePhoto) {
        if (msg.fileID && ![msg.fileID isEmptyString]) {
            [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialGetFile:msg.fileID filelength:msg.fileLength withTag:callbackTag withTimeout:100 error:nil];
        }
    }
    
}

#pragma mark - DB

/**
 *  获取会话下的所有聊天信息
 *
 */
- (NSArray *)getAllMsgsConvID:(NSString *)convID offset:(NSInteger)offset error:(NSError **)err {
    NSArray *arr = [[YYMediaCoreData sharedInstance] getAllMessageEntityConversationID:convID offset:offset error:err];
    // 需要将YYMessageEntity 转换成 XHMessage model
    __block NSMutableArray *xhMessages = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [xhMessages addObject:[self changeXHMessageToMessageEntity:obj]];
    }];
    
    return xhMessages;
}

- (void)createMessageEntity:(XHMessage *)message convModel:(YYConversationModel *)conv {
    // 消息
    NSError *err;
    [[YYMediaCoreData sharedInstance] createMessageEntity:message conversationID:conv.conversationID error:&err];
    if (!err) {
        // 成功
        NSArray *tmpListener = [NSArray arrayWithArray:_mutaMsgListenerArr];
        for (id tmp in tmpListener) {
            if ([tmp respondsToSelector:@selector(msgsAdded:conversation:)]) {
                // TODO
                [tmp msgsAdded:@[message] conversation:conv];
            }
        }
    } else {
        
    }
}

- (YYMessageEntity *)fetchMsgEntityWithID:(NSString *)msgID {
    if ([msgID isEmptyString]) {
        return nil;
    }
    NSError *err;
    YYMessageEntity *entity = [[YYMediaCoreData sharedInstance]fetchMessageEntityMsgID:msgID error:&err];
    if (err) {
        NSLog(@"===%s===error: %@", __FUNCTION__, err);
    }
    return entity;
}

- (void)updateMessageLoadedMsgID:(NSString *)msgID error:(NSError *__autoreleasing *)err {
    [[YYMediaCoreData sharedInstance] updateMsgEntityLoadedWithMsgID:msgID error:err];
}

- (void)updateMessageServerID:(NSString *)serverID msgID:(NSString *)msgID error:(NSError **)err {
    [[YYMediaCoreData sharedInstance] updateMessageServerID:serverID msgID:msgID error:err];
}

- (void)updateMessageFileID:(NSString *)fileID msgID:(NSString *)msgID error:(NSError **)err {
    [[YYMediaCoreData sharedInstance] updateMessageFileID:fileID msgID:msgID error:err];
}

- (void)updateAllMsgToReaded:(NSString *)convID {
    NSError *err;
    [[YYMediaCoreData sharedInstance] updateAllMsgToReaded:convID error:&err];
    if (err) {
        NSLog(@"===update all unread message except voice to readed error :%@===", err);
    }
}

- (void)updateMsgToReaded:(NSString *)msgID {
    if (msgID) {
        NSError *err;
        [[YYMediaCoreData sharedInstance] updateMsgEntityReaded:msgID error:&err];
        if (err) {
            NSLog(@"===update a message to readed falied :%@", err);
        }
    }
}

#pragma mark - 会话
/**
 *  获取所有的会话列表
 *
 */
- (NSArray *)getAllConversations:(NSError **)err {
    NSArray *arr = [[YYMediaCoreData sharedInstance] getConvEntitiesWithUid:[YYMediaSDKEngine sharedInstance].userModel.userID error:err];
    return arr;
}
/**
 *  根据用户ID、群ID 创建/更新 一个会话
 */
- (YYConversationModel *)createUpConversationTargetID:(NSString *)convID conversationName:(NSString *)convName lastMsg:(XHMessage *)msgModel conversationType:(YYChatTargetType)convType {
    YYConversationModel *conv = [[YYConversationModel alloc]init];
    [conv setConversationID:convID];
    [conv setConversationName:convName];
    [conv setTargetType:convType];
    [conv setUserID:[YYMediaSDKEngine sharedInstance].userModel.userID];
    [conv setLastMsg:msgModel];
    [[YYMediaCoreData sharedInstance] createConvEntity:conv error:nil];
    /// 添加会话
    NSArray *tmpListener = [NSArray arrayWithArray:_mutaMsgListenerArr];
    for (id tmp in tmpListener) {
        if ([tmp respondsToSelector:@selector(conversationAdded:)]) {
            [tmp conversationAdded:conv];
        }
    }
    return conv;
}
/**
 *  根据用户ID、群ID获取一个会话
 */
- (YYConversationModel *)getConversationTargetID:(NSString *)convID error:(NSError **)err {
    if ([convID isEmptyString]) {
        return nil;
    }
    YYConversationEntity *entity = [self getConversationEntity:convID error:err];
    return [self changeToConvModelFromConvEntity:entity];
}

- (NSInteger)fetchUnreadCountConvID:(NSString *)convID {
    if (convID) {
        NSError *err;
        NSInteger count = [[YYMediaCoreData sharedInstance] fetchUnreadMsg:convID error:&err];
        return count;
    }
    return 0;
}

- (YYConversationEntity *)getConversationEntity:(NSString *)convID error:(NSError **)err {
    
    YYConversationEntity *entity = [[YYMediaCoreData sharedInstance] fetchConvEntityConvID:convID userID:[YYMediaSDKEngine sharedInstance].userModel.userID error:err];
    return entity;
}

- (void)deleteConversationWithID:(NSString *)convID error:(NSError **)err {
    [[YYMediaCoreData sharedInstance] deleteConvEntityConvID:convID userID:[YYMediaSDKEngine sharedInstance].userModel.userID error:err];
    if (!*err) {
        // 删除成功
        NSArray *tmpListener = [NSArray arrayWithArray:_mutaMsgListenerArr];
        for (id tmp in tmpListener) {
            if ([tmp respondsToSelector:@selector(conversationDeleted:)]) {
                [tmp conversationDeleted:nil];
            }
        }
    }
}

#pragma mark - MediaPlusSDKDelegate

- (void)onRecvMsg:(NSString *)messageId fromUid:(NSString *)fromUid touid:(NSString *)touid filetype:(YYWChatFileType)type timevalue:(NSInteger)timevalue content:(NSData *)content wxt:(NSData *)extContent error:(NSError *)error targetType:(YYChatTargetType)targetType {
    XHMessage *msgTmp = [[XHMessage alloc] initWithText:[[NSString alloc]initWithData:content encoding:NSUTF8StringEncoding] sender:fromUid timestamp:[NSDate dateWithTimeIntervalSince1970:timevalue]];
    msgTmp.avatar = [UIImage imageNamed:@"iconImg"];
    msgTmp.messageMediaType = XHBubbleMessageMediaTypeText;
    msgTmp.bubbleMessageType = XHBubbleMessageTypeReceiving;
    msgTmp.senderID = fromUid;
    NSString *msgID = [NSString stringWithFormat:@"%llu", [[YYMsgUtils sharedInstance] getMsgID]];
    msgTmp.messageID = msgID;
    NSDictionary *extDic = @{};
    if (extContent) {
        extDic = [NSJSONSerialization JSONObjectWithData:extContent options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *nickName = extDic[kUserNickName];
    if (!nickName) {
        nickName = fromUid;
    }
    msgTmp.sender = nickName;
    msgTmp.serverMsgID = messageId;
    // 会话
    YYConversationModel *conv = [self createUpConversationTargetID:touid conversationName:nickName lastMsg:msgTmp conversationType:targetType];
    // 消息
    [self createMessageEntity:msgTmp convModel:conv];
    NSLog(@"======recvMsg:");
}

- (void)onRecvMsg:(MediaPlusSDK *)instance
    withMessageId:(NSString *)messageId
          fromUid:(NSString *)fromUid
            toUid:(NSString *)toUid
         filetype:(YYWChatFileType)type
             time:(NSInteger)timevalue
          content:(NSData *)content
          extBody:(NSData *)extContent
        withError:(NSError *)error {
    WEAKSELF
    if (YYWChatFileTypeText == type) {
        [weakSelf onRecvMsg:messageId fromUid:fromUid touid:fromUid filetype:type timevalue:timevalue content:content wxt:extContent error:error targetType:YYChatTargetTypeSingle];
        
    } else if (YYWChatFileTypeMixed == type) {
        // 系统消息、通知
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        NSLog(@"===receive mixed msg: %@, fromuid: %@", dic, fromUid);
    }
    
}

- (void)onRecvGroupMsg:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    WEAKSELF
    if (YYWChatFileTypeText == type) {
        [weakSelf onRecvMsg:messageId fromUid:fromUid touid:gid filetype:type timevalue:timevalue content:content wxt:extContent error:error targetType:YYChatTargetTypeGroup];
        
    } else if (YYWChatFileTypeMixed == type) {
        // 系统消息、通知
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        NSLog(@"===receive mixed msg: %@, fromuid: %@", dic, fromUid);
        
    }
}

- (void)onRecvFile:(NSString *)messageId fromuid:(NSString *)fromUid touid:(NSString *)toUid fileType:(YYWChatFileType)type time:(NSInteger)timevalue fileid:(NSString *)fileid thumb:(NSData *)thumbnailData ext:(NSData *)extContent filelength:(UInt64)length pieceSize:(UInt32)size withError:(NSError *)error targetType:(YYChatTargetType)target {
    NSString *msgID = [NSString stringWithFormat:@"%llu", [[YYMsgUtils sharedInstance] getMsgID]];
    NSString *thumImgPath = [YYMsgUtils getThumbImageStorePathWithMsgId:msgID.integerValue];
    [thumbnailData writeToFile:thumImgPath atomically:YES];
    UIImage *imgs = [UIImage imageWithData:thumbnailData];
    XHMessage *msgTmp = [[XHMessage alloc]initWithPhoto:imgs thumbnailUrl:nil originPhotoUrl:nil sender:fromUid timestamp:[NSDate dateWithTimeIntervalSince1970:timevalue]];
    msgTmp.avatar = [UIImage imageNamed:@"iconImg"];
    msgTmp.messageMediaType = XHBubbleMessageMediaTypePhoto;
    msgTmp.bubbleMessageType = XHBubbleMessageTypeReceiving;
    msgTmp.senderID = fromUid;
    msgTmp.messageID = msgID;
    msgTmp.fileID = fileid;
    msgTmp.fileLength = length;
    msgTmp.filePieceSize = size;
    NSDictionary *extDic = @{};
    if (extContent) {
        extDic = [NSJSONSerialization JSONObjectWithData:extContent options:NSJSONReadingMutableContainers error:nil];
    }
    NSString *nickName = extDic[kUserNickName];
    if (!nickName) {
        nickName = fromUid;
    }
    msgTmp.sender = nickName;
    msgTmp.serverMsgID = messageId;
    
    // 会话
    YYConversationModel *conv = [self createUpConversationTargetID:toUid conversationName:nickName lastMsg:msgTmp conversationType:target];
    // 消息
    [self createMessageEntity:msgTmp convModel:conv];
}

- (void)onRecvFile:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId fromUid:(NSString *)fromUid toUid:(NSString *)toUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue fileId:(NSString *)fileid thumbnail:(NSData *)thumbnailData extBody:(NSData *)extContent filelength:(UInt64)length pieceSize:(UInt32)size withError:(NSError *)error {
    WEAKSELF
    if (YYWChatFileTypeImage == type) {
        [weakSelf onRecvFile:messageId fromuid:fromUid touid:fromUid fileType:type time:timevalue fileid:fileid thumb:thumbnailData ext:extContent filelength:length pieceSize:size withError:error targetType:YYChatTargetTypeSingle];
        
    }
}

- (void)onRecvGroupFile:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue fileId:(NSString *)fileid thumbnail:(NSData *)thumbnailData extBody:(NSData *)extContent filelength:(UInt64)length pieceSize:(UInt32)size withError:(NSError *)error {
    WEAKSELF
    if (YYWChatFileTypeImage == type) {
        [weakSelf onRecvFile:messageId fromuid:fromUid touid:gid fileType:type time:timevalue fileid:fileid thumb:thumbnailData ext:extContent filelength:length pieceSize:size withError:error targetType:YYChatTargetTypeGroup];
        
    }
}

- (void)onRecvVoice:(NSString *)messageId fromUid:(NSString *)fromUid toUid:(NSString *)toUid spanId:(NSString *)spanId sequenceNo:(NSInteger)sequenceNo time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error targetType:(YYChatTargetType)target {
    
    NSString *voicePath = [YYMsgUtils getLocalRecordAudioPathBySpanId:spanId];
    NSDictionary *extDic = @{};
    if (extContent) {
        extDic = [NSJSONSerialization JSONObjectWithData:extContent options:NSJSONReadingMutableContainers error:nil];
    }
    XHMessage *msgTmp = [[XHMessage alloc]initWithVoicePath:voicePath voiceUrl:nil voiceDuration:[extDic[kVoiceDuration] description] sender:fromUid timestamp:[NSDate dateWithTimeIntervalSince1970:timevalue] isRead:NO];
    msgTmp.avatar = [UIImage imageNamed:@"iconImg"];
    msgTmp.messageMediaType = XHBubbleMessageMediaTypeVoice;
    msgTmp.bubbleMessageType = XHBubbleMessageTypeReceiving;
    NSString *msgID = [NSString stringWithFormat:@"%llu", [[YYMsgUtils sharedInstance] getMsgID]];
    msgTmp.messageID = msgID;
    msgTmp.senderID = fromUid;
    msgTmp.audioSpanID = spanId;
    NSString *nickName = extDic[kUserNickName];
    if (!nickName) {
        nickName = fromUid;
    }
    msgTmp.sender = nickName;
    msgTmp.serverMsgID = messageId;
    // 会话
    YYConversationModel *conv = [self createUpConversationTargetID:toUid conversationName:nickName lastMsg:msgTmp conversationType:target];
    // 消息
    [self createMessageEntity:msgTmp convModel:conv];
}

- (void)onRecvVoice:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId fromUid:(NSString *)fromUid toUid:(NSString *)toUid spanId:(NSString *)spanId sequenceNo:(NSInteger)sequenceNo time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    WEAKSELF
    
    [weakSelf onRecvVoice:messageId fromUid:fromUid toUid:fromUid spanId:spanId sequenceNo:sequenceNo time:timevalue content:content extBody:extContent withError:error targetType:YYChatTargetTypeSingle];
    
}

- (void)onRecvGroupVoice:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid spanId:(NSString *)spanId sequenceNo:(NSInteger)sequenceNo time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    WEAKSELF
    
    [weakSelf onRecvVoice:messageId fromUid:fromUid toUid:gid spanId:spanId sequenceNo:sequenceNo time:timevalue content:content extBody:extContent withError:error targetType:YYChatTargetTypeGroup];
}

- (void)onSendMsg:(MediaPlusSDK *)instance withTag:(NSInteger)tag withTime:(NSInteger)time withMessageId:(NSString *)messageId withError:(NSError *)error {
    NSLog(@"==============onsendMsg:%@=========error:%@", messageId, error.localizedDescription);
    NSString *msgID = [_allSendMsgDic objectForKey:[NSString stringWithFormat:@"%ld", (long)tag]];
    if (msgID) {
        NSError *errTmp;
        [self updateMessageServerID:messageId msgID:msgID error:&errTmp];
        [_allSendMsgDic removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)tag]];
        if (errTmp) {
            NSLog(@"===update message error :%@", errTmp);
        }
    }
}

- (void)onSendFile:(MediaPlusSDK *)instance withTag:(NSInteger)tag withTime:(NSInteger)time withMessageId:(NSString *)messageId withError:(NSError *)error {
    NSLog(@"==============onsendFile:%@=========error:%@", messageId, error.localizedDescription);
    NSString *msgID = [_allSendMsgDic objectForKey:[NSString stringWithFormat:@"%ld", (long)tag]];
    if (msgID) {
        NSError *errTmp;
        [self updateMessageServerID:messageId msgID:msgID error:&errTmp];
        [_allSendMsgDic removeObjectForKey:[NSString stringWithFormat:@"%ld", (long)tag]];
        
        [self updateMessageLoadedMsgID:msgID error:&errTmp];
        if (errTmp) {
            NSLog(@"===update message error :%@", errTmp);
        }
    }
    
}

- (void)onSendPreBack:(MediaPlusSDK *)instance withTag:(NSInteger)tag {
    NSLog(@"=========%s", __FUNCTION__);
}

- (void)onTimeout:(MediaPlusSDK *)instance withTag:(NSInteger)tag withError:(NSError *)error {
    NSLog(@"=========%s", __FUNCTION__);
}

/**
 *  压缩图片
 *
 *  @param image       需要压缩的图片
 *  @param fImageBytes 希望压缩后的大小(以KB为单位)
 *
 *  @return 压缩后的图片
 */
- (void)compressedImageFiles:(UIImage *)image
                     imageKB:(CGFloat)fImageKBytes
                  imageBlock:(void(^)(UIImage *image))block {
    
    __block UIImage *imageCope = image;
    CGFloat fImageBytes = fImageKBytes * 1024;//需要压缩的字节Byte
    
    __block NSData *uploadImageData = nil;
    
    uploadImageData = UIImagePNGRepresentation(imageCope);
    NSLog(@"图片压前缩成 %fKB",uploadImageData.length/1024.0);
    CGSize size = imageCope.size;
    CGFloat imageWidth = size.width;
    CGFloat imageHeight = size.height;
    
    if (uploadImageData.length > fImageBytes && fImageBytes >0) {
        
        dispatch_async(dispatch_queue_create("CompressedImage", DISPATCH_QUEUE_SERIAL), ^{
            
            /* 宽高的比例 **/
            CGFloat ratioOfWH = imageWidth/imageHeight;
            /* 压缩率 **/
            CGFloat compressionRatio = fImageBytes/uploadImageData.length;
            /* 宽度或者高度的压缩率 **/
            CGFloat widthOrHeightCompressionRatio = sqrt(compressionRatio);
            
            CGFloat dWidth   = imageWidth *widthOrHeightCompressionRatio;
            CGFloat dHeight  = imageHeight*widthOrHeightCompressionRatio;
            if (ratioOfWH >0) { /* 宽 > 高,说明宽度的压缩相对来说更大些 **/
                dHeight = dWidth/ratioOfWH;
            }else {
                dWidth  = dHeight*ratioOfWH;
            }
            
            imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
            uploadImageData = UIImagePNGRepresentation(imageCope);
            
            NSLog(@"当前的图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            //微调
            NSInteger compressCount = 0;
            /* 控制在 1M 以内**/
            while (fabs(uploadImageData.length - fImageBytes) > 1024) {
                /* 再次压缩的比例**/
                CGFloat nextCompressionRatio = 0.9;
                
                if (uploadImageData.length > fImageBytes) {
                    dWidth = dWidth*nextCompressionRatio;
                    dHeight= dHeight*nextCompressionRatio;
                }else {
                    dWidth = dWidth/nextCompressionRatio;
                    dHeight= dHeight/nextCompressionRatio;
                }
                
                imageCope = [self drawWithWithImage:imageCope width:dWidth height:dHeight];
                uploadImageData = UIImagePNGRepresentation(imageCope);
                
                /*防止进入死循环**/
                compressCount ++;
                if (compressCount == 10) {
                    break;
                }
                
            }
            
            NSLog(@"图片已经压缩成 %fKB",uploadImageData.length/1024.0);
            imageCope = [[UIImage alloc] initWithData:uploadImageData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(imageCope);
            });
        });
    }
    else
    {
        block(imageCope);
    }
}

/* 根据 dWidth dHeight 返回一个新的image**/
- (UIImage *)drawWithWithImage:(UIImage *)imageCope width:(CGFloat)dWidth height:(CGFloat)dHeight{
    
    UIGraphicsBeginImageContext(CGSizeMake(dWidth, dHeight));
    [imageCope drawInRect:CGRectMake(0, 0, dWidth, dHeight)];
    imageCope = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCope;
    
}

@end
