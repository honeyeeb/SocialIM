//
//  MediaPlusSDK+VoIP.h
//  MediaPlusSDK
//
//  Created by Frederic on 16/5/23.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "MediaPlusSDK.h"


#pragma mark - Notification 通知

//正常流程
extern NSString *const NotificationMediaCallIncoming;     //来电
extern NSString *const NotificationMediaCallConnected;    //来电接通
extern NSString *const NotificationMediaCallEnd;          //单人电话下，对方挂断 或 直播的时候本机来电话（live_self） 或 直播的时候主播失去连接超时
extern NSString *const NotificationMediaCallRemotePause;  //挂起(被优先级更高任务打断)

//出错
extern NSString *const NotificationMediaCallError;        //错误

//直播
extern NSString *const NotificationLiveReceiveIPandPort;
extern NSString *const NotificationMediaHeartBeatErrorKey;   //直播中 主播的心跳状态出问题的通知

@interface MediaPlusSDK (VoIP)

/**
 *  根据群组ID，申请创建一个电话会议的房间
 *
 *  @param goupID 申请房间的群组ID（自行管理群ID）
 *  @param error 错误句柄
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceRequestRoomGroupID:(NSString *)goupID
                               error:(NSError *__autoreleasing *)error;

/**
 *  邀请多个成员进入申请好的电话会议房间
 *
 *  @param users   被邀请人员的ID列表
 *  @param groupID 群组ID
 *  @param roomID  房间ID
 *  @param key     房间key
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceInviteUsers:(NSArray *)users
                      groupID:(NSString *)groupID
                       roomID:(NSString *)roomID
                          key:(NSString *)key
                        error:(NSError *__autoreleasing *)error;

/**
 *  根据群组ID和房间ID查询房间当前成员列表
 *
 *  @param roomID  房间ID
 *  @param groupID 群组ID
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceFetchUsersinRoom:(NSString *)roomID
                           groupID:(NSString *)groupID
                             error:(NSError *__autoreleasing *)error;

/**
 *  根据房间ID踢人（一个或多个）
 *
 *  @param users  被踢人的人员ID列表
 *  @param roomID 房间ID
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceKickUsers:(NSArray *)users
                     roomID:(NSString *)roomID
                      error:(NSError *__autoreleasing *)error;

/**
 *  根据房间ID给某些人禁言
 *
 *  @param users  被禁言人员ID列表
 *  @param roomID 当前房间ID
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceMuteUsers:(NSArray *)users
                     roomID:(NSString *)roomID
                      error:(NSError *__autoreleasing *)error;

/**
 *  根据房间ID给某些人解除禁言
 *
 *  @param users  被解除禁言的人员ID
 *  @param roomID 当前房间ID
 *
 *  @return 操作是否成功
 */
- (BOOL)conferenceUnmuteUsers:(NSArray *)users
                       roomID:(NSString *)roomID
                        error:(NSError *__autoreleasing *)error;

/**
 *  给否个人员拨打语音消息
 *
 *  @param userID      人员ID
 *  @param enableVideo 是否视频（当前版本不支持）
 *  @param error       错误句柄
 */
- (void)callUser:(NSString *)userID
     enableVideo:(BOOL)enableVideo
           error:(NSError *__autoreleasing *)error;

/**
 *  拨通某个电话会议房间
 *
 *  @param Room  房间ID
 *  @param key   房间key
 *  @param error 错误句柄
 */
- (void)callRoom:(NSString *)Room
         withKey:(NSString *)key
           error:(NSError *__autoreleasing *)error;

/**
 *  接受来电／会议请求
 *
 *  @param error 错误句柄
 */
- (void)acceptCall:(NSError *__autoreleasing *)error;

/**
 *  挂断离开单人／会议
 */
- (void)terminateCall;
/**
 *  是否外放
 *
 *  @param enable Y/N
 */
- (void)enableSpeaker:(BOOL)enable;
/**
 *  是否启用麦克声音
 *
 *  @param enable Y/N
 */
- (void)enableMute:(BOOL)enable;

#pragma mark - Setting

- (void)meidaConfigSetString:(NSString *)value forKey:(NSString *)key;

- (NSString *)mediaConfigGetString:(NSString *)key;

- (void)mediaConfigSetInt:(NSInteger)value forKey:(NSString *)key;

- (NSInteger)mediaConfigGetInt:(NSString *)key;

- (void)mediaConfigSetFloat:(float)value forKey:(NSString *)key;

- (float)mediaConfigGetFloat:(NSString *)key;

@end


