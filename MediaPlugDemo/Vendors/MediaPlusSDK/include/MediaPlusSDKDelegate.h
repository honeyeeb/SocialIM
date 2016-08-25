//
//  MediaPlusSDKDelegate.h
//  MediaPlusSDK
//
//  Created by Frederic on 16/5/23.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MediaPlusSDK;

@protocol MediaPlusSDKDelegate <NSObject>

/**
 *  登录授权回调，授权成功然后用户信息，授权失败反回失败原因
 *
 *  @param instance
 *  @param userinfo 授权成功的用户信息
 *  @param error    授权失败提示
 */
- (void)mediaPlus:(MediaPlusSDK *)instance authUserinfo:(NSDictionary *)userinfo withError:(NSError *)error;

@optional

/**
 *  @brief 连接成功回调
 *
 *  @param instance 实例
 */
- (void)onConnected:(MediaPlusSDK *)instance;

/**
 *  @brief 连接断开回调
 *
 *  @param instance 实例
 *  @param error    如连接出错断开, 则返回错误消息
 */
- (void)onDisconnect:(MediaPlusSDK *)instance withError:(NSError *)error;

/**
 *  @brief 向服务器发送断开连接的消息回调
 *
 *  @param instance 实例
 *  @param error    如果设置失败, 则返回错误信息
 */
- (void)onClose:(MediaPlusSDK *)instance withError:(NSError *)error;

/**
 *  @brief 退出登陆回调
 *
 *  @param instance 实例
 *  @param error    如登陆出错, 则返回错误消息
 */
- (void)onLogout:(MediaPlusSDK *)instance withError:(NSError *)error;

/**
 *  @brief 超时回调
 *
 *  @param instance 实例
 *  @param tag      消息标示
 *  @param error    如操作超时, 则返回错误消息
 */
- (void)onTimeout:(MediaPlusSDK *)instance withTag:(NSInteger)tag withError:(NSError *)error;

#pragma mark - 前后台切换
/**
 *  @brief 客户端退到后台, 关闭服务器消息notice下发, 开启推送回调
 *
 *  @param instance 实例
 *  @param error    如果设置失败, 则返回错误信息
 */
- (void)onPreClose:(MediaPlusSDK *)instance withError:(NSError *)error;

/**
 *  @brief 客户端回到前台, 开启服务器消息notice下发, 关闭推送
 *
 *  @param instance 实例
 *  @param error    如果设置失败, 则返回错误信息
 */
- (void)onKeepAlive:(MediaPlusSDK *)instance withError:(NSError *)error;

#pragma mark - 连接状态

/**
 *  @brief 连接状态回调
 *
 *  @param instance 实例
 *  @param state    连接状态
 */
- (void)onConnectState:(MediaPlusSDK *)instance state:(WChatConnectState)state;

#pragma mark - 发送消息回调
/**
 *  @brief 消息已送达到服务器, 但服务器还未下发相应, sdk预先返回, 随后服务器会下发相应, 以及时间戳.
 *  可理解为发送消息成功, 前端可根据此状态, 预先显示消息发送成功, 后台处理服务器下发.
 *
 *  @param instance 实例
 *  @param tag      消息标示
 */
- (void)onSendPreBack:(MediaPlusSDK *)instance withTag:(NSInteger)tag;

/**
 *  @brief 发送文本消息回调
 *
 *  @param instance  实例
 *  @param tag       消息标示
 *  @param time      消息时间
 *  @param messageId 消息id
 *  @param error     如发送出错, 则返回错误消息
 */
- (void)onSendMsg:(MediaPlusSDK *)instance
          withTag:(NSInteger)tag
         withTime:(NSInteger)time
    withMessageId:(NSString *)messageId
        withError:(NSError *)error;

/**
 *  @brief 发送文件回调
 *
 *  @param instance  实例
 *  @param tag       消息标示
 *  @param time      消息时间
 *  @param messageId 消息id
 *  @param error     如发送出错, 则返回错误消息
 */
- (void)onSendFile:(MediaPlusSDK *)instance
           withTag:(NSInteger)tag
          withTime:(NSInteger)time
     withMessageId:(NSString *)messageId
         withError:(NSError *)error;

#pragma mark - 未读数设置回调
/**
 *  未读数设置回调
 *
 *  @param instance   实例
 *  @param callbackId 消息标示
 */
-(void)onUnreadNoticeCallback:(MediaPlusSDK*)instance withCallbackId:(NSInteger)callbackId;

#pragma mark - 接收文本, 语音, 文件, notice, 订阅消息回调
/**
 *  @brief 接收文本消息回调
 *
 *  @param instance   实例
 *  @param messageId  消息id
 *  @param fromUid    发消息人Uid
 *  @param toUid      收消息人Uid
 *  @param type       消息类型
 *  @param timevalue  消息时间
 *  @param content    消息内容
 *  @param extContent 消息扩展内容
 *  @param error      如收消息出错, 则返回错误信息
 */
- (void)onRecvMsg:(MediaPlusSDK *)instance
    withMessageId:(NSString *)messageId
          fromUid:(NSString *)fromUid
            toUid:(NSString *)toUid
         filetype:(YYWChatFileType)type
             time:(NSInteger)timevalue
          content:(NSData *)content
          extBody:(NSData *)extContent
        withError:(NSError *)error;

/**
 *  @brief 接收群组文本消息回调
 *
 *  @param instance   实例
 *  @param messageId  消息id
 *  @param gid        群id
 *  @param fromUid    发消息人Uid
 *  @param type       消息类型
 *  @param timevalue  消息时间
 *  @param content    消息内容
 *  @param extContent 消息扩展内容
 *  @param error      如收消息出错, 则返回错误信息
 */
- (void)onRecvGroupMsg:(MediaPlusSDK *)instance
         withMessageId:(NSString *)messageId
           withGroupId:(NSString *)gid
               fromUid:(NSString *)fromUid
              filetype:(YYWChatFileType)type
                  time:(NSInteger)timevalue
               content:(NSData *)content
               extBody:(NSData *)extContent
             withError:(NSError *)error;

/**
 *  @brief 接收聊天室消息回调
 *
 *  @param instance      实例
 *  @param messageId     消息id
 *  @param rid           房间id
 *  @param fromUid       发消息人Uid
 *  @param type          消息类型
 *  @param spanId        语音唯一标识
 *  @param sequenceNo    语音分片编号, 如 1, 2, 3, ... -1, -1 表示结束
 *  @param fileid        文件id
 *  @param thumbnailData 缩略图二进制数据
 *  @param length        文件长度
 *  @param size          分片大小
 *  @param timevalue     消息时间
 *  @param content       消息内容
 *  @param extContent    消息扩展内容
 *  @param error         如收消息出错, 则返回错误信息
 */
- (void)onRecvChatRoomMsg:(MediaPlusSDK *)instance
            withMessageId:(NSString *)messageId
               withRoomId:(NSString *)rid
                  fromUid:(NSString *)fromUid
                 filetype:(YYWChatFileType)type
                   spanId:(NSString *)spanId
               sequenceNo:(NSInteger)sequenceNo
                   fileId:(NSString *)fileid
                thumbnail:(NSData *)thumbnailData
               filelength:(UInt64)length
                pieceSize:(UInt32)size
                     time:(NSInteger)timevalue
                  content:(NSData *)content
                  extBody:(NSData *)extContent
                withError:(NSError *)error;

/**
 *  @brief 接收语音消息回调
 *
 *  @param instance   实例
 *  @param messageId  消息id
 *  @param fromUid    发消息人Uid
 *  @param toUid      收消息人Uid
 *  @param spanId     语音唯一标识
 *  @param sequenceNo 语音分片编号, 如 1, 2, 3, ... -1, -1 表示结束
 *  @param timevalue  消息时间
 *  @param content    消息内容
 *  @param extContent 消息扩展内容
 *  @param error      如收消息出错, 则返回错误信息
 */
- (void)onRecvVoice:(MediaPlusSDK *)instance
      withMessageId:(NSString *)messageId
            fromUid:(NSString *)fromUid
              toUid:(NSString *)toUid
             spanId:(NSString *)spanId
         sequenceNo:(NSInteger)sequenceNo
               time:(NSInteger)timevalue
            content:(NSData *)content
            extBody:(NSData *)extContent
          withError:(NSError *)error;

/**
 *  @brief 接收群组语音消息回调
 *
 *  @param instance   实例
 *  @param messageId  消息id
 *  @param gid        群id
 *  @param fromUid    发消息人Uid
 *  @param spanId     语音唯一标识
 *  @param sequenceNo 语音分片编号, 如 1, 2, 3, ... -1, -1 表示结束
 *  @param timevalue  消息时间
 *  @param content    消息内容
 *  @param extContent 消息扩展内容
 *  @param error      如收消息出错, 则返回错误信息
 */
- (void)onRecvGroupVoice:(MediaPlusSDK *)instance
           withMessageId:(NSString *)messageId
             withGroupId:(NSString *)gid
                 fromUid:(NSString *)fromUid
                  spanId:(NSString *)spanId
              sequenceNo:(NSInteger)sequenceNo
                    time:(NSInteger)timevalue
                 content:(NSData *)content
                 extBody:(NSData *)extContent
               withError:(NSError *)error;

/**
 *  @brief 接收文件消息回调
 *
 *  @param instance      实例
 *  @param messageId     消息id
 *  @param fromUid       发消息人Uid
 *  @param toUid         收消息人Uid
 *  @param type          消息类型
 *  @param timevalue     消息时间
 *  @param fileid        文件id
 *  @param thumbnailData 缩略图二进制数据
 *  @param extContent    消息扩展内容
 *  @param length        文件长度
 *  @param size          文件分片大小
 *  @param error         如收文件出错, 则返回错误信息
 */
- (void)onRecvFile:(MediaPlusSDK *)instance
     withMessageId:(NSString *)messageId
           fromUid:(NSString *)fromUid
             toUid:(NSString *)toUid
          filetype:(YYWChatFileType)type
              time:(NSInteger)timevalue
            fileId:(NSString *)fileid
         thumbnail:(NSData *)thumbnailData
           extBody:(NSData *)extContent
        filelength:(UInt64)length
         pieceSize:(UInt32)size
         withError:(NSError *)error;

/**
 *  @brief 接收群组文件消息回调
 *
 *  @param instance      实例
 *  @param messageId     消息id
 *  @param gid           群id
 *  @param fromUid       发消息人Uid
 *  @param type          消息类型
 *  @param timevalue     消息时间
 *  @param fileid        文件id
 *  @param thumbnailData 缩略图二进制数据
 *  @param extContent    消息扩展内容
 *  @param length        文件长度
 *  @param size          文件分片大小
 *  @param error         如收文件出错, 则返回错误信息
 */
- (void)onRecvGroupFile:(MediaPlusSDK *)instance
          withMessageId:(NSString *)messageId
            withGroupId:(NSString *)gid
                fromUid:(NSString *)fromUid
               filetype:(YYWChatFileType)type
                   time:(NSInteger)timevalue
                 fileId:(NSString *)fileid
              thumbnail:(NSData *)thumbnailData
                extBody:(NSData *)extContent
             filelength:(UInt64)length
              pieceSize:(UInt32)size
              withError:(NSError *)error;

/**
 *  @brief 系统下发的notice消息, 踢人回调
 *
 *  @param instance 实例
 *  @param fuid     发消息人Uid
 *  @param type     Notice类型
 *  @param content  消息内容
 */
- (void)onRecvNoticeMessage:(MediaPlusSDK *)instance
                    fromUid:(NSString *)fuid
                   withType:(WChatNoticeType)type
                withContent:(NSString *)content;

/**
 *  @brief 订阅消息回调
 *
 *  @param instance      实例
 *  @param messageId     消息id
 *  @param fromUid       发消息人Uid
 *  @param toUid         收消息人Uid
 *  @param type          消息类型
 *  @param spanId        语音唯一标识
 *  @param sequenceNo    语音分片编号, 如 1, 2, 3, ... -1, -1 表示结束
 *  @param fileid        文件id
 *  @param thumbnailData 缩略图二进制数据
 *  @param length        文件长度
 *  @param size          分片大小
 *  @param timevalue     消息时间
 *  @param content       消息内容
 *  @param extContent    消息扩展内容
 *  @param error         如收消息出错, 则返回错误信息
 */
- (void)onRecvSubscribeMsg:(MediaPlusSDK *)instance
             withMessageId:(NSString *)messageId
                   fromUid:(NSString *)fromUid
                     toUid:(NSString *)toUid
                  filetype:(YYWChatFileType)type
                    spanId:(NSString *)spanId
                sequenceNo:(NSInteger)sequenceNo
                    fileId:(NSString *)fileid
                 thumbnail:(NSData *)thumbnailData
                filelength:(UInt64)length
                 pieceSize:(UInt32)size
                      time:(NSInteger)timevalue
                   content:(NSData *)content
                   extBody:(NSData *)extContent
                 withError:(NSError *)error;

#pragma mark - 获取文件 & 文件进度
/**
 *  @brief 获取文件数据回调
 *
 *  @param instance 实例
 *  @param fileid   文件id
 *  @param tag      消息标示
 *  @param error    如获取文件出错, 则返回错误信息
 */
- (void)onGetFile:(MediaPlusSDK *)instance
           fileId:(NSString *)fileid
          withTag:(NSInteger)tag
        withError:(NSError *)error;

/**
 *  @brief 发送和接收文件进度的回调
 *
 *  @param instance 实例
 *  @param tag      消息标示
 *  @param index    文件分片索引
 *  @param limit    文件分片总数
 *  @param error    如获取进度出错, 则返回错误信息
 */
- (void)onFileProgress:(MediaPlusSDK *)instance
               withTag:(NSInteger)tag
             withIndex:(UInt32)index
             withLimit:(UInt32)limit
             withError:(NSError *)error;

#pragma mark - 获取个人 & 群组消息未读数

/**
 *  @brief 获取消息未读数
 *
 *  @param user  用户消息未读数, 字典格式 @{ @"用户id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 }, @"用户id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 } }
 *  @param group 群组消息未读数, 字典格式 @{ @"群组id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 }, @"群组id": @{ @"num": NSNumber 未读数, @"time": NSNumber 消息时间 } }
 */
- (void)onRecvUnreadNumber:(MediaPlusSDK *)instance
                  withUser:(NSDictionary *)user
                 withGroup:(NSDictionary *)group;

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
              withError:(NSError *)error;

#pragma mark - 系统服务
/**
 *  @brief 发送微博消息回调
 *
 *  @param instance 实例
 *  @param tag      消息标示
 *  @param content  消息内容
 *  @param error    如收消息出错, 则返回错误信息
 */
- (void)onAppService:(MediaPlusSDK *)instance
             withTag:(NSInteger)tag
         withContent:(NSData *)content
           withError:(NSError *)error;

#pragma mark - http链接请求回调
/**
 *  @brief 短链发送文件进度
 *
 *  @param progress   进度 0~1
 *  @param callbackId 回调id
 */
- (void)onShortProgress:(float)progress withCallbackId:(NSInteger)callbackId;

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
                             error:(NSError *)error;

/**
 * Called when conference 电话会议 有人加入
 **/
- (void)conferenceJoinedWith:(NSString *)roomID
                     groupID:(NSString *)groupID
                       users:(NSArray *)users;

/**
 * Called when conference 电话会议 有人被禁言
 **/
- (void)conferenceMutedWith:(NSString *)roomID
                    groupID:(NSString *)groupID
                    fromUid:(NSString *)fromUid
                      users:(NSArray *)users;

/**
 * Called when conference 电话会议 有人被解禁
 **/
- (void)conferenceUnmutedWith:(NSString *)roomID
                      groupID:(NSString *)groupID
                      fromUid:(NSString *)fromUid
                        users:(NSArray *)users;

/**
 * Called when conference 电话会议 有人被踢
 **/
- (void)conferenceKickedWith:(NSString *)roomID
                     groupID:(NSString *)groupID
                     fromUid:(NSString *)fromUid
                       users:(NSArray *)users;

/**
 * Called when conference 电话会议 有人离开
 **/
- (void)conferenceLeftWith:(NSString *)roomID
                   groupID:(NSString *)groupID
                     users:(NSArray *)users;

/**
 * Called when conference 电话会议 即将关闭的通知提示
 **/
- (void)conferenceWillbeEndWith:(NSString *)roomID
                        groupID:(NSString *)groupID
                         intime:(NSInteger )second;

/**
 * Called when conference 电话会议 验证失败 房间已经过期
 **/
- (void)conferenceExpiredWithRoomID:(NSString *)roomID
                                key:(NSString *)key;

/**
 * 未接到的来电
 **/
- (void)missCallFromUser:(NSString *)fromUid
                  atTime:(NSInteger)time;


#pragma mark - VoIP
/**
 *  来电回调
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallIncomingByUser:(NSString*)userId;

/**
 *  来电接通回调
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallConnectedByUser:(NSString*)userId;

/**
 *  单人电话下，对方挂断 或 直播的时候本机来电话（live_self）  或 直播的时候主播失去连接超时
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallEndByUser:(NSString*)userId;

/**
 *  挂起(被优先级更高任务打断)
 *
 *  @param userId 通话对方用户id
 */
- (void)mediaCallRemotePauseByUser:(NSString*)userId;

/**
 *  错误回调
 *
 *  @param error  错误信息
 *  @param userId 通话对方用户id
 */
- (void)mediaCallError:(NSError*)error fromUser:(NSString*)userId;

@end
