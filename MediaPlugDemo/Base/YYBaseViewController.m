//
//  YYBaseViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/1.
//  Copyright © 2016年 YouYun. All rights reserved.
//


#import "YYBaseViewController.h"
#import "YYPhoneCallViewController.h"
#import "YYConferenceViewController.h"

#import "SVProgressHUD.h"
#import "YYMsgManager.h"
#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "MediaPlusSDK+VoIP.h"
#import "YYPhoneCallModel.h"
#import "YYConferenceModel.h"
#import "YYNetworkManage.h"
#import "YYUserModel.h"
#import "YYMediaCoreData.h"
#import "YYUserEntity.h"


@interface YYBaseViewController ()



@end

@implementation YYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[YYMsgManager sharedInstance]addMessageListener:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[YYMediaSDKEngine sharedInstance]addNoTagMediaPlusDelegate:self];
    
    // 有来电通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fLincomingPhoneCall:) name:NotificationMediaCallIncoming object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self dismissHUD];
    [[YYMediaSDKEngine sharedInstance]removeNoTagMediaPlusDelegate:self];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NotificationMediaCallIncoming object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HUD

- (void)setDefaultHUD {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeFlat];
}

- (BOOL)hudIsVisible {
    return [SVProgressHUD isVisible];
}

- (void)showHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDefaultHUD];
        [SVProgressHUD show];
    });
}

- (void)showHUDWithStatus:(NSString *)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:status];
    });
}

- (void)showHUDProgress:(float)progress status:(NSString*)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showProgress:progress status:status];
    });
}

- (void)showHUDInfoWithStatus:(NSString*)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showInfoWithStatus:status];
    });
}

- (void)showHUDSuccessWithStatus:(NSString*)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:status];
    });
}

- (void)showHUDErrorWithStatus:(NSString*)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:status];
    });
}

- (void)dismissHUD {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)dismissHUDWithDelay:(NSTimeInterval)delay {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismissWithDelay:delay];
    });
}

- (void)getUserInfoWithUserID:(NSString *)userID completion:(void (^)(YYUserModel *))handler {
    [YYNetworkManage getUserInfoWithUserID:userID completion:handler];
}

#pragma mark - conference 电话会议
- (BOOL)conferenceRequestRoom {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceRequestRoomGroupID:[YYMediaSDKEngine sharedInstance].userModel.userID error:nil];
}
- (BOOL)conferenceInviteUsers:(NSArray *)users roomID:(NSString *)roomID key:(NSString *)key {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceInviteUsers:users groupID:[YYMediaSDKEngine sharedInstance].userModel.userID roomID:roomID key:key error:nil];
}
- (BOOL)conferenceFetchUsersinRoom:(NSString *)roomID {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceFetchUsersinRoom:roomID groupID:[YYMediaSDKEngine sharedInstance].userModel.userID error:nil];
}
- (BOOL)conferenceKickUsers:(NSArray *)users roomID:(NSString *)roomID{
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceKickUsers:users roomID:roomID error:nil];
}
- (BOOL)conferenceMuteUsers:(NSArray *)users roomID:(NSString *)roomID {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceMuteUsers:users roomID:roomID error:nil];
}
- (BOOL)conferenceUnmuteUsers:(NSArray *)users roomID:(NSString *)roomID {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK conferenceUnmuteUsers:users roomID:roomID error:nil];
}

#pragma mark - voip 网络电话（一对一电话)
- (void)callUser:(NSString *)userID userName:(NSString *)userName {
    NSError *error = nil;
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK callUser:userID enableVideo:NO error:&error];
    if (error) {
        [self showHUDErrorWithStatus:error.localizedDescription];
    } else {
        YYPhoneCallModel *phoneCall = [[YYPhoneCallModel alloc]init];
        phoneCall.userID = userID;
        phoneCall.userName = userName;
        [self presentPhoneCallViewController:phoneCall];
    }
}
- (void)callRoom:(NSString *)Room withKey:(NSString *)key error:(NSError **)error {
    return [[YYMediaSDKEngine sharedInstance].mediaPlusSDK callRoom:Room withKey:key error:error];
}
- (void)acceptCall:(NSError **)error {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK acceptCall:error];
}

- (void)terminateCall {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK terminateCall];
}

- (void)enabelSpeaker:(BOOL)enable {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK enableSpeaker:enable];
}

- (void)enabelMute:(BOOL)enable {
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK enableMute:enable];
}

- (void)showRecvConfAlertVCTitle:(NSString *)title message:(NSString *)message confirmHandler:(void (^)())confirmHandler {
    if ([self isKindOfClass:[YYPhoneCallViewController class]] || [self isKindOfClass:[YYConferenceViewController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"拒接" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            confirmHandler();
        }];
        [alert addAction:cancleAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)successRequestConferenceRoom:(YYConferenceModel *)conferenceModel {
    // subclass implementation
}

- (void)successRequestConfrenceMembers:(NSArray *)members {
    // subclass implementation
}

- (void)onConnectState:(MediaPlusSDK *)instance state:(WChatConnectState)state {
    if (state == UnReconnect) {
        [self showHUDErrorWithStatus:@"链接断开，重新连接中"];
        [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialReconnect];
    } else if (state == Connected) {
        [self dismissHUD];
    }
}

- (void)missCallFromUser:(NSString *)fromUid atTime:(NSInteger)time {
    YYUserEntity *entity = [[YYMediaCoreData sharedInstance] fetchUserEntityWithUserID:fromUid error:nil];
    NSString *tmpName = fromUid;
    if (entity && entity.userName) {
        tmpName = entity.userName;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"错过来电" message:[NSString stringWithFormat:@"用户:%@\n时间%@", tmpName, [NSDate dateWithTimeIntervalSince1970:time]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

//申请电话会议房间 或 邀请好友加入电话会议 或 收到电话会议邀请 或 获取成员列表 的 callback
- (void)onReceiveConfeneceCallback:(WChatSDK *)instance type:(cfcallbackType)type fromUser:(NSString *)fromUid groupID:(NSString *)groupID roomID:(NSString *)roomID key:(NSString *)key users:(NSArray *)users startTime:(NSString *)startTime endTime:(NSString *)endTime error:(NSError *)error {
    YYConferenceModel *conferenceModel = [[YYConferenceModel alloc]init];
    conferenceModel.users = users;
    conferenceModel.fromUsrID = fromUid;
    conferenceModel.groupID = groupID;
    conferenceModel.roomID = roomID;
    conferenceModel.key = key;
    conferenceModel.startTime = startTime;
    conferenceModel.endTime = endTime;
    conferenceModel.callBackType = type;
    
    WEAKSELF
    if (type == cfcallbackTypeRoomRequest) {
        // 请求房间
        if ([conferenceModel.roomID isEqualToString:@"0"] || [conferenceModel.roomID isEmptyString]) {
            
            [weakSelf showHUDErrorWithStatus:@"房间已满，申请房间失败"];
        } else {
            if ([weakSelf respondsToSelector:@selector(successRequestConferenceRoom:)]) {
                [weakSelf successRequestConferenceRoom:conferenceModel];
            }
            
        }
    } else if (type == cfcallbackTypeSendInvite) {
        //邀请已经发送成功 可以在这里添加 通知 做UI呈现
        
    } else if (type == cfcallbackReceiveInvite) {
        NSString *tmpName = fromUid;
        YYUserEntity *entity = [[YYMediaCoreData sharedInstance] fetchUserEntityWithUserID:fromUid error:nil];
        if (entity && entity.userName) {
            tmpName = entity.userName;
        }
        [weakSelf showRecvConfAlertVCTitle:@"电话会议邀请" message:[NSString stringWithFormat:@"%@邀请你加入多人电话会议", tmpName] confirmHandler:^(){
            NSError *err = nil;
            [weakSelf callRoom:conferenceModel.roomID withKey:conferenceModel.key error:&err];
            if (err) {
                [weakSelf showHUDErrorWithStatus:err.localizedDescription];
            } else {
                [weakSelf presentConferenceViewController:conferenceModel];
            }
            
        }];
    } else if (type == cfcallbackTypeFetch) {
        if ([weakSelf respondsToSelector:@selector(successRequestConfrenceMembers:)]) {
            [weakSelf successRequestConfrenceMembers:conferenceModel.users];
        }
        
    }
}

#pragma mark - 电话

- (void)presentPhoneCallViewController:(YYPhoneCallModel *)phoneCallModel {
    if ([self isKindOfClass:[YYPhoneCallViewController class]] || [self isKindOfClass:[YYConferenceViewController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (phoneCallModel) {
            YYPhoneCallViewController *phoneCallVC = [[YYPhoneCallViewController alloc]init];
            phoneCallVC.phonCallModel = phoneCallModel;
            [self.navigationController pushViewController:phoneCallVC animated:YES];
        }

        
    });
}
// 来电通知
- (void)fLincomingPhoneCall:(NSNotification *)notification {
    YYPhoneCallModel *phoneCall = [[YYPhoneCallModel alloc]init];
    if ([notification.userInfo objectForKey:@"uid"] != nil) {
        phoneCall.userID = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"uid"]];
        phoneCall.userName = [NSString stringWithFormat:@"%@", [notification.userInfo objectForKey:@"uid"]];
        phoneCall.callType = YYPhoneCallModelReceive;
    }
    NSLog(@"************** incoming call uid :%@",phoneCall.userID);
    [self presentPhoneCallViewController:phoneCall];
}

#pragma mark - 会议

- (void)presentConferenceViewController:(YYConferenceModel *)conferenceModel {
    if ([self isKindOfClass:[YYPhoneCallViewController class]] || [self isKindOfClass:[YYConferenceViewController class]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (conferenceModel) {
            YYConferenceViewController *confVC = [[YYConferenceViewController alloc]init];
            confVC.confModel = conferenceModel;
            [self.navigationController pushViewController:confVC animated:YES];
        }
        
    });
    
}

@end
