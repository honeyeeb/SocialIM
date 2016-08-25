//
//  MediaPlusSDK+IM.h
//  MediaPlusSDK
//
//  Created by Frederic on 16/5/23.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "MediaPlusSDK.h"

@interface MediaPlusSDK (IM)

#pragma mark - 群组 管理相关接口

/**
 *  创建群组
 *
 *  @param handler 回调block (创建成功的群组id, 如果错误则返回错误信息)
 */
- (void)groupCreateHandler:(void(^)(NSString *groupId, NSError* requestError))handler;

/**
 *  创建一个群组
 *
 *  @param name    群名称
 *  @param desc    群简介
 *  @param cate    群类别
 *  @param handler 回调
 */
- (void)groupCreateName:(NSString *)name
            description:(NSString *)desc
               categary:(WChatGroupCategary)cate
             completion:(void (^)(NSDictionary *response, NSError *err))handler;

/**
 *  群组加人
 *
 *  @param groupId 群组id
 *  @param userIds 用户id数组
 *  @param handler 回调block (是否操作成功, 如果错误则返回错误信息)
 */
- (void)group:(NSString *)groupId
      addUser:(NSArray *)userIds
completionHandler:(void (^)(BOOL isAdd, NSError* requestError))handler;

/**
 *  群组踢人
 *
 *  @param groupId 群组id
 *  @param userIds 用户id数组
 *  @param handler 回调block (是否操作成功, 如果错误则返回错误信息)
 */
- (void)group:(NSString *)groupId
      delUser:(NSArray *)userIds
completionHandler:(void (^)(BOOL isDel, NSError* requestError))handler;

/**
 *  退出群组
 *
 *  @param groupId 群组id
 *  @param handler 回调block (是否操作成功, 如果错误则返回错误信息)
 */
- (void)groupExit:(NSString *)groupId
completionHandler:(void(^)(BOOL isExit, NSError* requestError))handler;

/**
 *  获取群组成员
 *
 *  @param groupId 群组id
 *  @param handler 回调block (群组成员数据, 如果错误则返回错误信息)
 */
- (void)groupGetUsers:(NSString *)groupId
    completionHandler:(void (^)(NSArray *users, NSError* requestError))handler;

/**
 *  获取当前用户的群组
 *
 *  @param handler 回调block (用户的群组数据, 如果错误则返回错误信息)
 */
- (void)getUserGroupsHandler:(void (^)(NSArray *groups, NSError* requestError))handler;

/**
 *  销毁房间
 *
 *  @param gid     房间ID
 *  @param handler 回调
 */
- (void)groupDelete:(NSString *)gid completion:(void (^)(BOOL sucess, NSError *err))handler;
/**
 *  获取群信息
 *
 *  @param gid     群组ID
 *  @param handler 回调
 */
- (void)groupGetInfo:(NSString *)gid completion:(void (^)(NSDictionary *response, NSError *err))handler;
/**
 *  获取群组内的所有成员
 *
 *  @param gid     群id
 *  @param handler 回调
 */
- (void)groupGetMember:(NSString *)gid completion:(void (^)(NSArray *members, NSError *err))handler;
/**
 *  更新群组信息
 *
 *  @param gid     群ID
 *  @param name    群名称
 *  @param desc    群简介
 *  @param cate    群类别
 *  @param handler 回调
 */
- (void)groupUpdate:(NSString *)gid name:(NSString *)name description:(NSString *)desc categary:(WChatGroupCategary)cate completion:(void (^)(NSDictionary *response, NSError *err))handler;
/**
 *  申请加入群组
 *
 *  @param gid        群组ID
 *  @param extContent 附言
 *  @param handler    回调
 */
- (void)groupApplyJoinin:(NSString *)gid extContent:(NSString *)extContent completion:(void (^)(BOOL success, NSError *err))handler;

#pragma mark - 消息相关接口

/**
 *  单聊聊天历史消息.
 *
 *  @param userId    聊天对方uid(非当前登陆用户)
 *  @param timestamp 时间戳(精确到秒)
 *  @param size      数据条数(服务器默认一次最多取20)
 *  @param handler   回调block (历史消息数据, 如果错误则返回错误信息)
 */
- (void)getHistoryByUser:(NSString *)userId timestamp:(NSInteger)timestamp size:(NSInteger)size completionHandler:(void (^)(NSArray *history, NSError* requestError))handler;

/**
 *  群聊聊天历史消息
 *
 *  @param groupId   群组id
 *  @param timestamp 时间戳(精确到秒)
 *  @param size      数据条数(服务器默认一次最多取20)
 *  @param handler   回调block (历史消息数据, 如果错误则返回错误信息)
 */
- (void)getHistoryByGroup:(NSString *)groupId timestamp:(NSInteger)timestamp size:(NSInteger)size completionHandler:(void (^)(NSArray *, NSError *))handler;


#pragma mark - 发送通知消息接口
/**
 *  @brief 发送通知消息
 *
 *  @param tuid    收消息人Uid
 *  @param type    通知类型
 *  @param content 通知内容
 *  @param errPtr  错误句柄
 *
 */
- (void)socialSendNoticeMsg:(NSString *)tuid
                   withType:(NSInteger)type
                withContent:(NSString *)content
                      error:(NSError **)errPtr;

#pragma mark - 发送文本消息接口
/**
 *  @brief 发送文本消息
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param content    消息内容
 *  @param extContent 扩展消息内容
 *  @param tag        消息标示, 用于回调
 *  @param type       消息类型
 *                      YYWChatFileTypeCustom : 自定义消息(服务器不作处理)
 *                      YYWChatFileTypeText : (服务器业务处理(e:敏感词...))
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 消息是否正常发送, YES是, NO否
 */
- (void)socialSendMsg:(NSString *)toid
                 body:(NSData *)content
              extBody:(NSData *)extContent
              withTag:(NSInteger)tag
             withType:(YYWChatFileType)type
           targetType:(WChatMsgTargetType)target
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr;

#pragma mark - 发送语音消息接口

/**
 *  @brief 发送音频消息
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param spanId     语音唯一标示
 *  @param sequenceNo 语音分片编号, 如 1, 2, 3, ... -1, -1 表示结束
 *  @param content    语音消息内容
 *  @param ext        扩展消息内容
 *  @param tag        消息标示, 用于回调
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 消息是否正常发送, YES是, NO否
 */
- (void)socialSendVoice:(NSString *)toid
                 spanId:(NSString *)spanId
             sequenceNo:(NSInteger)sequenceNo
                content:(NSData *)content
                    ext:(NSData *)ext
                withTag:(NSInteger)tag
             targetType:(WChatMsgTargetType)target
            withTimeout:(NSTimeInterval)timeout
                  error:(NSError **)errPtr;

/**
 *  @brief 获取语音唯一标示
 *
 *  @param tuid 收消息人Uid
 *
 *  @return 语音消息唯一标示
 */
- (NSString *)getVoiceSpanId:(NSString *)tuid;

#pragma mark - 发送文件消息接口

/**
 *  获取发送文件的文件ID
 *
 *  @param targetID 对方的ID
 *
 *  @return 文件ID
 */
- (NSString *)getFileIdWithTargetID:(NSString *)targetID;
/**
 *  @brief 发送文件给个人、群组
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param filepath   文件路径
 *  @param extContent 扩展消息内容
 *  @param tag        消息标示, 用于回调
 *  @param fileType   文件类型
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 文件id
 */
- (NSString *)socialSendFile:(NSString *)toid
                        path:(NSString *)filepath
                     extBody:(NSData *)extContent
                     withTag:(NSInteger)tag
                    filetype:(YYWChatFileType)fileType
                  targetType:(WChatMsgTargetType)target
                 withTimeout:(NSTimeInterval)timeout
                       error:(NSError **)errPtr;

/**
 *	@brief 发送文件给个人、群组, 断点续传
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param fid        文件id
 *  @param filepath   文件路径
 *  @param extContent 扩展消息内容
 *  @param index      文件片数索引
 *  @param tag        消息标示, 用于回调
 *  @param fileType   文件类型
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 文件id
 */
- (NSString *)socialSendFile:(NSString *)toid
                     withFid:(NSString *)fid
                        path:(NSString *)filename
                     extBody:(NSData *)extContent
                   withIndex:(UInt32)index
                     withTag:(NSInteger)tag
                    filetype:(YYWChatFileType)fileType
                  targetType:(WChatMsgTargetType)target
                 withTimeout:(NSTimeInterval)timeout
                       error:(NSError **)errPtr;

/**
 *  @brief 发送文件(图片)给个人、群组, 带缩略图
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param filepath   文件路径
 *  @param nailpath   缩略图路径
 *  @param extContent 扩展消息内容
 *  @param tag        消息标示, 用于回调
 *  @param fileType   文件类型
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 文件id
 */

- (NSString *)socialSendFileWithThumbnail:(NSString *)toid
                                     path:(NSString *)filepath
                                 nailpath:(NSString *)nailpath
                                  extBody:(NSData *)extContent
                                  withTag:(NSInteger)tag
                                 filetype:(YYWChatFileType)fileType
                               targetType:(WChatMsgTargetType)target
                              withTimeout:(NSTimeInterval)timeout
                                    error:(NSError **)errPtr;

/**
 *	@brief 发送文件给个人、群组, 带缩略图, 断点续传
 *
 *  @param toid       收消息人、群组、聊天室id
 *  @param fid        文件id
 *  @param filepath   文件路径
 *  @param nailpath   缩略图路径
 *  @param extContent 扩展消息内容
 *  @param index      文件片数索引
 *  @param tag        消息标示, 用于回调
 *  @param fileType   文件类型
 *  @param target     消息对象类型
 *  @param timeout    调用超时时间
 *  @param errPtr     错误句柄
 *
 *  @return 文件id
 */
- (NSString *)socialSendFileWithThumbnail:(NSString *)toid
                                   fileId:(NSString *)fid
                                     path:(NSString *)filename
                                 nailpath:(NSString *)nailfile
                                  extBody:(NSData *)extContent
                                withIndex:(UInt32)index
                                  withTag:(NSInteger)tag
                                 filetype:(YYWChatFileType)fileType
                               targetType:(WChatMsgTargetType)target
                              withTimeout:(NSTimeInterval)timeout
                                    error:(NSError **)errPtr;

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
                completion:(void (^)(NSDictionary *json, NSError *error))handler;

#pragma mark - 消息未读数设置
/**
 *  @brief 设置消息未读数
 *
 *  @param number 未读数数量
 *  @param tag    消息标示, 用于回调
 *  @param errPtr 错误句柄
 *
 */
- (void)socialSetUnreadNumber:(NSInteger)number
                     withTag:(NSInteger)tag
                       error:(NSError **)errPtr;

/**
 *  @brief 设置消息未读数 - number
 *
 *  @param number 减掉的消息未读数
 *  @param tag    消息标示, 用于回调
 *  @param errPtr 错误句柄
 *
 */
- (void)socialMinusUnreadNumber:(NSInteger)number
                       withTag:(NSInteger)tag
                         error:(NSError **)errPtr;

#pragma mark - 获取文件
/**
 *  @brief 根据文件id获取文件, 分片获取
 *
 *  @param fid     文件id
 *  @param length  文件长度
 *  @param size    分片长度
 *  @param tag     消息标示, 用于回调
 *  @param index   分片索引
 *  @param timeout 调用超时时间
 *  @param errPtr  错误句柄
 *
 */
- (void)socialGetFile:(NSString *)fid
           filelength:(UInt64)length
            pieceSize:(UInt32)size
              withTag:(NSInteger)tag
                index:(UInt32)index
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr;

/**
 *  @brief 根据文件id获取文件
 *
 *  @param fid     文件id
 *  @param length  文件长度
 *  @param tag     消息标示, 用于回调
 *  @param timeout 调用超时时间
 *  @param errPtr  错误句柄
 *
 */
- (void)socialGetFile:(NSString *)fid
           filelength:(UInt64)length
              withTag:(NSInteger)tag
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr;

@end
