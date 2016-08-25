//
//  YYBaseViewController.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/1.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYConferenceModel;
@class YYUserModel;


@interface YYBaseViewController : UIViewController



#pragma mark - HUD

- (BOOL)hudIsVisible;

- (void)showHUD;

- (void)showHUDWithStatus:(NSString *)status;

- (void)showHUDProgress:(float)progress status:(NSString*)status;

- (void)showHUDInfoWithStatus:(NSString*)status;

- (void)showHUDSuccessWithStatus:(NSString*)status;

- (void)showHUDErrorWithStatus:(NSString*)status;

- (void)dismissHUD;

- (void)dismissHUDWithDelay:(NSTimeInterval)delay;

#pragma mark - VoIP
/**
 *  给某一用户拨打电话
 *
 *  @param userID      对方用户ID
 */
- (void)callUser:(NSString *)userID userName:(NSString *)userName;

- (void)callRoom:(NSString *)Room withKey:(NSString *)key error:(NSError **)error;

- (void)presentConferenceViewController:(YYConferenceModel *)conferenceModel;

/**
 *  接受电话、会议
 *
 *  @param error 错误句柄
 */
- (void)acceptCall:(NSError **)error;
/**
 *  挂断电话、会议
 */
- (void)terminateCall;
/**
 *  设置是否使用外放
 *
 *  @param enable YES：使用外放
 */
- (void)enabelSpeaker:(BOOL)enable;
/**
 *  设置是否关闭话筒
 *
 *  @param enable YES：关闭话题
 */
- (void)enabelMute:(BOOL)enable;

#pragma mark - conference 电话会议
- (BOOL)conferenceRequestRoom;
- (BOOL)conferenceInviteUsers:(NSArray *)users roomID:(NSString *)roomID key:(NSString *)key;
- (BOOL)conferenceFetchUsersinRoom:(NSString *)roomID;
- (BOOL)conferenceKickUsers:(NSArray *)users roomID:(NSString *)roomID;
- (BOOL)conferenceMuteUsers:(NSArray *)users roomID:(NSString *)roomID;
- (BOOL)conferenceUnmuteUsers:(NSArray *)users roomID:(NSString *)roomID;

- (void)getUserInfoWithUserID:(NSString *)userID completion:(void (^)(YYUserModel *user))handler;

//#pragma mark - MediaSDKDelegate
////来电
//- (void)mediaCallIncomingByUser:(NSString *)userId;
////接通
//- (void)mediaCallConnectedByUser:(NSString *)userId;
////挂断
//- (void)mediaCallEndByUser:(NSString*)userId;
////挂起(被优先级更高任务打断)
//- (void)mediaCallRemotePauseByUser:(NSString*)userId;
////错误
//- (void)mediaCallError:(NSError*)error fromUser:(NSString*)userId;
////错过的电话
//- (void)missCallFromUser:(NSString *)fromUid atTime:(NSInteger)time;


@end
