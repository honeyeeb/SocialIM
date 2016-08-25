//
//  YYMediaSDKEngine.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/5/30.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "YYMsgManager.h"
#import "YYMsgUtils.h"
#import "YYMediaCoreData.h"


NSInteger const kPlatform = 1;

NSString * const CLIENT_ID = kPlatform ? @"1-20521-1b766ad17389c94e1dc1f2615714212a-ios" : @"1-20140-201c24b1df50a4e3a8348274963ab0a6-ios";
NSString * const SECRET    = kPlatform ? @"d5cf0a5812b4424f582ded05937e4387" : @"9d12b16f31926616582eabcf66a2a6ad";


@interface YYMediaSDKEngine ()
{
    NSMutableDictionary *receiveVoiceDataDic;
    NSMutableDictionary *onAppServiceBlockDic;
    NSMutableDictionary *onFileProgressBlockDic;
}

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) NSMutableArray *delegateArray;

@property (nonatomic, strong, readwrite) YYUserModel *userModel;

@property (nonatomic, copy, readwrite) NSString *pushToken;

@end


static YYMediaSDKEngine *staticMediaEngine = nil;
@implementation YYMediaSDKEngine

+ (YYMediaSDKEngine *)sharedInstance {
    @synchronized (self) {
        if (!staticMediaEngine) {
            staticMediaEngine = [[YYMediaSDKEngine alloc]init];
        }
    }
    return staticMediaEngine;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        if (!staticMediaEngine) {
            staticMediaEngine = [super allocWithZone:zone];
            return staticMediaEngine;
        }
    }
    return nil;
}

+ (NSString *)hostURL {
    if (kPlatform) {
        return @"http://api.ioyouyun.com";
    } else {
        return @"http://test.api.ioyouyun.com";
    }
}

- (instancetype)init {
    @synchronized (self) {
        if (self = [super init]) {
            _tag = 100;
            receiveVoiceDataDic = [NSMutableDictionary dictionary];
            onAppServiceBlockDic = [NSMutableDictionary dictionary];
            onFileProgressBlockDic = [NSMutableDictionary dictionary];
        }
        return self;
    }
}

- (MediaPlusSDK *)mediaPlusSDK {
    if (!_mediaPlusSDK) {
        _mediaPlusSDK = [MediaPlusSDK sharedInstance];
    }
    return _mediaPlusSDK;
}

- (NSMutableArray *)delegateArray {
    if (!_delegateArray) {
        _delegateArray = [NSMutableArray array];
    }
    return _delegateArray;
}

- (void)setUserInfo:(NSDictionary *)dic {
    self.userModel = [YYUserModel initWithDic:dic];
    // 更新本地数据库
    NSError *error;
    [[YYMediaCoreData sharedInstance] createUserEntityUserModel:_userModel error:&error];
    if (error) {
        NSLog(@"===failed to update local user info");
    }
}

- (void)signin {
    if (!self.mediaPlusSDK.isAuth) {
        [self.mediaPlusSDK setDelegate:self];
        if (kPlatform) {
            [self.mediaPlusSDK startWithUDID:[MediaPlusSDK getUDID] clientID:CLIENT_ID secret:SECRET];
        } else {
            [self.mediaPlusSDK testStartWithUDID:[MediaPlusSDK getUDID] clientID:CLIENT_ID secret:SECRET];
        }
    }
}

- (NSInteger)getConnectTag {
    return self.tag++;
}

- (NSString *)deviceToken {
    return _pushToken;
}

- (void)addNoTagMediaPlusDelegate:(id)delegate {
    if (delegate && ![self.delegateArray containsObject:delegate]) {
        [self.delegateArray addObject:delegate];
    }
}

- (void)removeNoTagMediaPlusDelegate:(id)delegate {
    if (delegate && [self.delegateArray containsObject:delegate]) {
        [self.delegateArray removeObject:delegate];
    }
}

- (void)addAppServiceBlock:(onAppServiceBlock)block tag:(NSInteger)tag {
    [onAppServiceBlockDic setObject:[block copy] forKey:[NSNumber numberWithInteger:tag]];
}

- (void)removeAppServiceTag:(NSInteger)tag {
    [onAppServiceBlockDic removeObjectForKey:[NSNumber numberWithInteger:tag]];
}

- (onAppServiceBlock)getAppServiceBlockByTag:(NSInteger)tag{
    return [onAppServiceBlockDic objectForKey:[NSNumber numberWithInteger:tag]];
}

- (void)addFileProgressBlock:(onMsgFileProgressBlock)block tag:(NSInteger)tag {
    [onFileProgressBlockDic setObject:[block copy] forKey:[NSNumber numberWithInteger:tag]];
}

- (void)removeFileProgressTag:(NSInteger)tag {
    [onFileProgressBlockDic removeObjectForKey:[NSNumber numberWithInteger:tag]];
}

- (onMsgFileProgressBlock)getFileProgressBlockTag:(NSInteger)tag {
    return [onFileProgressBlockDic objectForKey:[NSNumber numberWithInteger:tag]];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token {
    self.pushToken = [self.mediaPlusSDK setDeviceToken:token];
}

- (NSString *)getImgCachePath {
    return self.mediaPlusSDK.cachePath;
}

/**
 *  异步短连请求
 *
 *  @param method     POST/GET
 *  @param url        短链接URL
 *  @param params     参数(para1=%@&param2=%d)
 *  @param callbackId 回调ID
 *  @param timeout    超时时间
 *  @param handler    回调结果
 */
- (void)socialAsyncRequest:(NSString*)method
                       url:(NSString *)url
                    params:(NSString *)params
                callbackId:(NSInteger)callbackId
                   timeout:(NSTimeInterval)timeout
                completion:(void (^)(NSDictionary *json, NSError *error))handler {
    [self.mediaPlusSDK socialAsyncRequest:method url:url params:params callbackId:callbackId timeout:timeout completion:handler];
}

#pragma mark - MediaPlusSDKDelegate
- (void)mediaPlus:(MediaPlusSDK *)instance authUserinfo:(NSDictionary *)userinfo withError:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error && userinfo) {
            [self setUserInfo:userinfo];
        }
        NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
        for (id<MediaPlusSDKDelegate> tmp in tmpDelegateArr) {
            if ([tmp respondsToSelector:@selector(mediaPlus:authUserinfo:withError:)]) {
                [tmp mediaPlus:_mediaPlusSDK authUserinfo:userinfo withError:error];
            }
        }
    });
}

- (void)onConnected:(MediaPlusSDK *)instance {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onConnected:)]) {
            [tmp onConnected:instance];
        }
    }
}

/**
 *  @brief 连接断开回调
 */
- (void)onDisconnect:(MediaPlusSDK *)instance withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onDisconnect:withError:)]) {
            [tmp onDisconnect:instance withError:error];
        }
    }
}

/**
 *  @brief 向服务器发送断开连接的消息回调
 */
- (void)onClose:(MediaPlusSDK *)instance withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onClose:withError:)]) {
            [tmp onClose:instance withError:error];
        }
    }
}

/**
 *  @brief 退出登陆回调
 */
- (void)onLogout:(MediaPlusSDK *)instance withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onLogout:withError:)]) {
            [tmp onClose:instance withError:error];
        }
    }
}

/**
 *  @brief 超时回调
 */
- (void)onTimeout:(MediaPlusSDK *)instance withTag:(NSInteger)tag withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onTimeout:withTag:withError:)]) {
            [tmp onTimeout:instance withTag:tag withError:error];
        }
    }
}

- (void)onPreClose:(MediaPlusSDK *)instance withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onPreClose:withError:)]) {
            [tmp onPreClose:instance withError:error];
        }
    }
}

/**
 *  @brief 客户端回到前台, 开启服务器消息notice下发, 关闭推送
 */
- (void)onKeepAlive:(MediaPlusSDK *)instance withError:(NSError *)error {
    NSLog(@"===%s", __FUNCTION__);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onKeepAlive:withError:)]) {
            [tmp onKeepAlive:instance withError:error];
        }
    }
}

- (void)onConnectState:(MediaPlusSDK *)instance state:(WChatConnectState)state {
    NSLog(@"===%s===%ld", __FUNCTION__, state);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onConnectState:state:)]) {
            [tmp onConnectState:instance state:state];
        }
    }
}

- (void)onSendPreBack:(MediaPlusSDK *)instance withTag:(NSInteger)tag {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onSendPreBack:withTag:)]) {
            [tmp onSendPreBack:instance withTag:tag];
        }
    }
}

- (void)onSendMsg:(MediaPlusSDK *)instance withTag:(NSInteger)tag withTime:(NSInteger)time withMessageId:(NSString *)messageId withError:(NSError *)error {
    NSLog(@"===%s===%@", __FUNCTION__, messageId);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onSendMsg:withTag:withTime:withMessageId:withError:)]) {
            [tmp onSendMsg:instance withTag:tag withTime:time withMessageId:messageId withError:error];
        }
    }
}

- (void)onSendFile:(MediaPlusSDK *)instance withTag:(NSInteger)tag withTime:(NSInteger)time withMessageId:(NSString *)messageId withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onSendFile:withTag:withTime:withMessageId:withError:)]) {
            [tmp onSendFile:instance withTag:tag withTime:time withMessageId:messageId withError:error];
        }
    }
}

- (void)onUnreadNoticeCallback:(MediaPlusSDK*)instance withCallbackId:(NSInteger)callbackId {
    NSLog(@"===%s===%ld", __FUNCTION__, callbackId);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onUnreadNoticeCallback:withCallbackId:)]) {
            [tmp onUnreadNoticeCallback:instance withCallbackId:callbackId];
        }
    }
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
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvMsg:withMessageId:fromUid:toUid:filetype:time:content:extBody:withError:)]) {
            [tmp onRecvMsg:instance withMessageId:messageId fromUid:fromUid toUid:toUid filetype:type time:timevalue content:content extBody:extContent withError:error];
        }
    }
    
}

- (void)onRecvGroupMsg:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvGroupMsg:withMessageId:withGroupId:fromUid:filetype:time:content:extBody:withError:)]) {
            [tmp onRecvGroupMsg:instance withMessageId:messageId withGroupId:gid fromUid:fromUid filetype:type time:timevalue content:content extBody:extContent withError:error];
        }
    }
}

- (void)onRecvFile:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId fromUid:(NSString *)fromUid toUid:(NSString *)toUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue fileId:(NSString *)fileid thumbnail:(NSData *)thumbnailData extBody:(NSData *)extContent filelength:(UInt64)length pieceSize:(UInt32)size withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvFile:withMessageId:fromUid:toUid:filetype:time:fileId:thumbnail:extBody:filelength:pieceSize:withError:)]) {
            [tmp onRecvFile:instance withMessageId:messageId fromUid:fromUid toUid:toUid filetype:type time:timevalue fileId:fileid thumbnail:thumbnailData extBody:extContent filelength:length pieceSize:size withError:error];
        }
    }
}

- (void)onRecvGroupFile:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid filetype:(YYWChatFileType)type time:(NSInteger)timevalue fileId:(NSString *)fileid thumbnail:(NSData *)thumbnailData extBody:(NSData *)extContent filelength:(UInt64)length pieceSize:(UInt32)size withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvGroupFile:withMessageId:withGroupId:fromUid:filetype:time:fileId:thumbnail:extBody:filelength:pieceSize:withError:)]) {
            [tmp onRecvGroupFile:instance withMessageId:messageId withGroupId:gid fromUid:fromUid filetype:type time:timevalue fileId:fileid thumbnail:thumbnailData extBody:extContent filelength:length pieceSize:size withError:error];
        }
    }
}

- (void)onRecvVoice:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId fromUid:(NSString *)fromUid toUid:(NSString *)toUid spanId:(NSString *)spanId sequenceNo:(NSInteger)sequenceNo time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    if (!spanId) {
        return;
    }
    NSMutableData *muteVoiceData = [NSMutableData dataWithData:receiveVoiceDataDic[spanId]];
    if (!muteVoiceData) {
        muteVoiceData = [NSMutableData dataWithData:content];
    } else {
        [muteVoiceData appendData:content];
    }
    [receiveVoiceDataDic setObject:muteVoiceData forKey:spanId];
    NSLog(@"recvVoiceSpan:%@===sequence:%ld", spanId, sequenceNo);
    if (sequenceNo == -1) {
        // 结束
        NSData *voiceData = [NSData dataWithData:receiveVoiceDataDic[spanId]];
        if (voiceData) {
            [YYMsgUtils corverFromAmrData:voiceData spanID:spanId];
            [receiveVoiceDataDic removeObjectForKey:spanId];
        }
        
        NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
            if ([tmp respondsToSelector:@selector(onRecvVoice:withMessageId:fromUid:toUid:spanId:sequenceNo:time:content:extBody:withError:)]) {
                [tmp onRecvVoice:instance withMessageId:messageId fromUid:fromUid toUid:toUid spanId:spanId sequenceNo:sequenceNo time:timevalue content:content extBody:extContent withError:error];
            }
        }
    }
    
}

- (void)onRecvGroupVoice:(MediaPlusSDK *)instance withMessageId:(NSString *)messageId withGroupId:(NSString *)gid fromUid:(NSString *)fromUid spanId:(NSString *)spanId sequenceNo:(NSInteger)sequenceNo time:(NSInteger)timevalue content:(NSData *)content extBody:(NSData *)extContent withError:(NSError *)error {
    if (!spanId) {
        return;
    }
    NSMutableData *muteVoiceData = [NSMutableData dataWithData:receiveVoiceDataDic[spanId]];
    if (!muteVoiceData) {
        muteVoiceData = [NSMutableData dataWithData:content];
    } else {
        [muteVoiceData appendData:content];
    }
    [receiveVoiceDataDic setObject:muteVoiceData forKey:spanId];
    NSLog(@"recvGroupVoiceSpan:%@===sequence:%ld", spanId, sequenceNo);
    if (sequenceNo == -1) {
        NSData *voiceData = [NSData dataWithData:receiveVoiceDataDic[spanId]];
        if (voiceData) {
            [YYMsgUtils corverFromAmrData:voiceData spanID:spanId];
            [receiveVoiceDataDic removeObjectForKey:spanId];
        }
        NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
            if ([tmp respondsToSelector:@selector(onRecvGroupVoice:withMessageId:withGroupId:fromUid:spanId:sequenceNo:time:content:extBody:withError:)]) {
                [tmp onRecvGroupVoice:instance withMessageId:messageId withGroupId:gid fromUid:fromUid spanId:spanId sequenceNo:sequenceNo time:timevalue content:content extBody:extContent withError:error];
            }
        }
    }
}

- (void)onRecvNoticeMessage:(MediaPlusSDK *)instance
                    fromUid:(NSString *)fuid
                   withType:(WChatNoticeType)type
                withContent:(NSString *)content {
    NSLog(@"===%s===%@===%@===%ld", __FUNCTION__, fuid, content, type);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvNoticeMessage:fromUid:withType:withContent:)]) {
            [tmp onRecvNoticeMessage:instance fromUid:fuid withType:type withContent:content];
        }
    }
}

- (void)onGetFile:(MediaPlusSDK *)instance
           fileId:(NSString *)fileid
          withTag:(NSInteger)tag
        withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onGetFile:fileId:withTag:withError:)]) {
            [tmp onGetFile:instance fileId:fileid withTag:tag withError:error];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        onAppServiceBlock block = [self getAppServiceBlockByTag:tag];
        if (block) {
            [self removeAppServiceTag:tag];
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            if (fileid) {
                [dic setObject:fileid forKey:@"fid"];
            }
            block(tag, dic, error);
        }
    });
}

/**
 *  @brief 发送和接收文件进度的回调
 */
- (void)onFileProgress:(MediaPlusSDK *)instance
               withTag:(NSInteger)tag
             withIndex:(UInt32)index
             withLimit:(UInt32)limit
             withError:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onFileProgress:withTag:withIndex:withLimit:withError:)]) {
            [tmp onFileProgress:instance withTag:tag withIndex:index withLimit:limit withError:error];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        onMsgFileProgressBlock progressBlock = [self getFileProgressBlockTag:tag];
        if (progressBlock) {
            progressBlock(index, limit);
        }
    });
    
}

/**
 *  @brief 获取消息未读数
 *
 *  @param user  用户消息未读数, 字典格式 @{ @"用户id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 }, @"用户id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 } }
 *  @param group 群组消息未读数, 字典格式 @{ @"群组id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 }, @"群组id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 } }
 */
- (void)onRecvUnreadNumber:(MediaPlusSDK *)instance
                  withUser:(NSDictionary *)user
                 withGroup:(NSDictionary *)group {
    NSLog(@"===%s===user:%@===group:%@", __FUNCTION__, user, group);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onRecvUnreadNumber:withUser:withGroup:)]) {
            [tmp onRecvUnreadNumber:instance withUser:user withGroup:group];
        }
    }
}

/**
 *  @brief http链接请求回调
 *
 *  @param instance   实例
 *  @param response   返回消息
 *  @param callbackId 回调id
 *  @param error      如收消息出错, 则返回错误信息
 */
- (void)onShortResponse:(MediaPlusSDK *)instance
           withResponse:(NSString *)response
         withCallbackId:(NSInteger)callbackId
              withError:(NSError *)error {
    NSLog(@"===%s===resp:%@===callback:%ld", __FUNCTION__, response, callbackId);
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onShortResponse:withResponse:withCallbackId:withError:)]) {
            [tmp onShortResponse:instance withResponse:response withCallbackId:callbackId withError:error];
        }
    }
}

#pragma mark - 多人会话
/**
 * Called when receive conference 电话会议 房间 的 创建 和邀请 message
 **/
- (void)onReceiveConfeneceCallback:(MediaPlusSDK *)instance
                              type:(cfcallbackType)type
                          fromUser:(NSString *)fromUid
                           groupID:(NSString *)groupID
                            roomID:(NSString *)roomID
                               key:(NSString *)key
                             users:(NSArray *)users
                         startTime:(NSString *)startTime
                           endTime:(NSString *)endTime
                             error:(NSError *)error {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(onReceiveConfeneceCallback:type:fromUser:groupID:roomID:key:users:startTime:endTime:error:)]) {
            [tmp onReceiveConfeneceCallback:instance type:type fromUser:fromUid groupID:groupID roomID:roomID key:key users:users startTime:startTime endTime:endTime error:error];
        }
    }
}

/**
 * Called when conference 电话会议 有人加入
 **/
- (void)conferenceJoinedWith:(NSString *)roomID
                     groupID:(NSString *)groupID
                       users:(NSArray *)users {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceJoinedWith:groupID:users:)]) {
            [tmp conferenceJoinedWith:roomID groupID:groupID users:users];
        }
    }
}

/**
 * Called when conference 电话会议 有人被禁言
 **/
- (void)conferenceMutedWith:(NSString *)roomID
                    groupID:(NSString *)groupID
                    fromUid:(NSString *)fromUid
                      users:(NSArray *)users {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceMutedWith:groupID:fromUid:users:)]) {
            [tmp conferenceMutedWith:roomID groupID:groupID fromUid:fromUid users:users];
        }
    }
}

/**
 * Called when conference 电话会议 有人被解禁
 **/
- (void)conferenceUnmutedWith:(NSString *)roomID
                      groupID:(NSString *)groupID
                      fromUid:(NSString *)fromUid
                        users:(NSArray *)users {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceUnmutedWith:groupID:fromUid:users:)]) {
            [tmp conferenceUnmutedWith:roomID groupID:groupID fromUid:fromUid users:users];
        }
    }
}

/**
 * Called when conference 电话会议 有人被踢
 **/
- (void)conferenceKickedWith:(NSString *)roomID
                     groupID:(NSString *)groupID
                     fromUid:(NSString *)fromUid
                       users:(NSArray *)users {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceKickedWith:groupID:fromUid:users:)]) {
            [tmp conferenceKickedWith:roomID groupID:groupID fromUid:fromUid users:users];
        }
    }
}

/**
 * Called when conference 电话会议 有人离开
 **/
- (void)conferenceLeftWith:(NSString *)roomID
                   groupID:(NSString *)groupID
                     users:(NSArray *)users {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceLeftWith:groupID:users:)]) {
            [tmp conferenceLeftWith:roomID groupID:groupID users:users];
        }
    }
}

/**
 * Called when conference 电话会议 即将关闭的通知提示
 **/
- (void)conferenceWillbeEndWith:(NSString *)roomID
                        groupID:(NSString *)groupID
                         intime:(NSInteger )second {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceWillbeEndWith:groupID:intime:)]) {
            [tmp conferenceWillbeEndWith:roomID groupID:groupID intime:second];
        }
    }
}

/**
 * Called when conference 电话会议 验证失败 房间已经过期
 **/
- (void)conferenceExpiredWithRoomID:(NSString *)roomID
                                key:(NSString *)key {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(conferenceExpiredWithRoomID:key:)]) {
            [tmp conferenceExpiredWithRoomID:roomID key:key];
        }
    }
}

/**
 * 未接到的来电
 **/
- (void)missCallFromUser:(NSString *)fromUid
                  atTime:(NSInteger)time {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(missCallFromUser:atTime:)]) {
            [tmp missCallFromUser:fromUid atTime:time];
        }
    }
}


#pragma mark - VoIP
/**
 *  来电回调
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallIncomingByUser:(NSString*)userId {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(mediaCallIncomingByUser:)]) {
            [tmp mediaCallIncomingByUser:userId];
        }
    }
}

/**
 *  来电接通回调
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallConnectedByUser:(NSString*)userId {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(mediaCallConnectedByUser:)]) {
            [tmp mediaCallConnectedByUser:userId];
        }
    }
}

/**
 *  单人电话下，对方挂断 或 直播的时候本机来电话（live_self）  或 直播的时候主播失去连接超时
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallEndByUser:(NSString*)userId {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(mediaCallEndByUser:)]) {
            [tmp mediaCallEndByUser:userId];
        }
    }
}

/**
 *  挂起(被优先级更高任务打断)
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallRemotePauseByUser:(NSString*)userId {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(mediaCallRemotePauseByUser:)]) {
            [tmp mediaCallRemotePauseByUser:userId];
        }
    }
}

/**
 *  错误回调
 *
 *  @param error  错误信息
 *  @param userId 通话对方用户id
 */
- (void)mediaCallError:(NSError*)error fromUser:(NSString*)userId {
    NSArray *tmpDelegateArr = [NSArray arrayWithArray:self.delegateArray];
    for (id tmp in tmpDelegateArr) {
        if ([tmp respondsToSelector:@selector(mediaCallError:fromUser:)]) {
            [tmp mediaCallError:error fromUser:userId];
        }
    }
}


@end
