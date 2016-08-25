//
//  YYPhoneCallViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/21.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYPhoneCallViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "YYPhoneCallModel.h"
#import "MediaPlusSDK+VoIP.h"
#import "YYUserModel.h"
#import "YYMediaCoreData.h"
#import "YYUserEntity.h"


@interface YYPhoneCallViewController ()

/**
 *  icon图片
 */
@property (nonatomic, strong) UIImageView *iconImagView;
/**
 *  用户ID
 */
@property (nonatomic, strong) UILabel *userIDLabel;
/**
 *  用户名称
 */
@property (nonatomic, strong) UILabel *userNameLabel;
/**
 *  提示信息
 */
@property (nonatomic, strong) UILabel *noticeLabel;
/**
 *  接收电话
 */
@property (nonatomic, strong) UIButton *acceptBtn;
/**
 *  挂断电话
 */
@property (nonatomic, strong) UIButton *turnOffBtn;
/**
 *  外放／听筒 按钮
 */
@property (nonatomic, strong) UIButton *speakerBtn;

/**
 *  是否是外放
 */
@property (nonatomic, assign) BOOL isSpeaker;

@property (nonatomic, strong) NSDate *connectedDate;

@property (nonatomic, strong) NSTimer *countTimer;

@end



@implementation YYPhoneCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    [self changeProximityMonitorEnableState:YES];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.iconImagView];
    [self.view addSubview:self.userNameLabel];
    [self.view addSubview:self.userIDLabel];
    [self.view addSubview:self.noticeLabel];
    [self.view addSubview:self.turnOffBtn];
    [self.view addSubview:self.speakerBtn];
    
    _isSpeaker = NO;
    self.userIDLabel.text = _phonCallModel.userID;
    self.userNameLabel.text = _phonCallModel.userName;
    if (_phonCallModel.callType == YYPhoneCallModelReceive) {
        
        [self.view addSubview:self.acceptBtn];
        // 获取对方名称
        __block NSError *errPrt;
        YYUserEntity *userEntity = [[YYMediaCoreData sharedInstance] fetchUserEntityWithUserID:_phonCallModel.userID error:&errPrt];
        if (!userEntity || errPrt) {
            [self getUserInfoWithUserID:_phonCallModel.userID completion:^(YYUserModel *user) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (user) {
                        // 更新本地数据库
                        [[YYMediaCoreData sharedInstance] createUserEntityUserModel:user error:&errPrt];
                        _userNameLabel.text = user.userNickName;
                    }
                });
            }];
        } else {
            _userNameLabel.text = userEntity.userName;
        }
        
        
    } else {
        _noticeLabel.text = @"等待对方接听，请稍后...";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
    [self terminateCall];
    [self.countTimer invalidate];
    [self changeProximityMonitorEnableState:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImageView *)iconImagView {
    if (!_iconImagView) {
        _iconImagView = [[UIImageView alloc]init];
        CGRect frame = CGRectMake((SCREEN_WIDTH - 120) / 2, 60, 120, 120);
        [_iconImagView setFrame:frame];
        UIImage *img = [UIImage imageNamed:@"iconImg"];
        [_iconImagView setImage:img];
    }
    return _iconImagView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]init];
        CGRect frame = CGRectMake(0, _iconImagView.frame.origin.y +_iconImagView.frame.size.height + 20, SCREEN_WIDTH, 30);
        _userNameLabel.frame = frame;
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.font = [UIFont systemFontOfSize:20];
    }
    return _userNameLabel;
}

- (UILabel *)userIDLabel {
    if (!_userIDLabel) {
        _userIDLabel = [[UILabel alloc]init];
        CGRect frame = CGRectMake(0, _userNameLabel.frame.origin.y + _userNameLabel.frame.size.height + 10, SCREEN_WIDTH, 20);
        _userIDLabel.frame = frame;
        _userIDLabel.textAlignment = NSTextAlignmentCenter;
        _userIDLabel.textColor = [UIColor lightGrayColor];
    }
    return _userIDLabel;
}

- (UILabel *)noticeLabel {
    if (!_noticeLabel) {
        _noticeLabel = [[UILabel alloc]init];
        CGRect frame = CGRectMake(0, _userIDLabel.frame.origin.y + _userIDLabel.frame.size.height + 20, SCREEN_WIDTH, 30);
        _noticeLabel.frame = frame;
        _noticeLabel.font = [UIFont systemFontOfSize:20];
        _noticeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _noticeLabel;
}

- (UIButton *)acceptBtn {
    if (!_acceptBtn) {
        _acceptBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_acceptBtn setTitle:@"接听" forState:UIControlStateNormal];
        _acceptBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        CGRect frame = CGRectMake(_turnOffBtn.frame.origin.x, _turnOffBtn.frame.origin.y - _turnOffBtn.frame.size.height - 20, _turnOffBtn.frame.size.width, _turnOffBtn.frame.size.height);
        _acceptBtn.frame = frame;
        _acceptBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        _acceptBtn.backgroundColor = [UIColor greenColor];
        _acceptBtn.layer.borderColor = [UIColor clearColor].CGColor;
        _acceptBtn.layer.borderWidth = 0.5;
        _acceptBtn.layer.cornerRadius = frame.size.height / 2.0;
        _acceptBtn.layer.masksToBounds = YES;
        [_acceptBtn addTarget:self action:@selector(acceptBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _acceptBtn;
}

- (UIButton *)turnOffBtn {
    if (!_turnOffBtn) {
        _turnOffBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_turnOffBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_turnOffBtn setTitle:@"挂断" forState:UIControlStateNormal];
        _turnOffBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        CGRect frame = CGRectMake(30, SCREEN_HEIGHT - 130, (SCREEN_WIDTH - 60), 44);
        _turnOffBtn.frame = frame;
        _turnOffBtn.backgroundColor = [UIColor colorWithRed:1.0 green:160 / 255.0 blue:0 alpha:1.0];
        _turnOffBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        _turnOffBtn.layer.borderColor = [UIColor clearColor].CGColor;
        _turnOffBtn.layer.cornerRadius = frame.size.height / 2;
        _turnOffBtn.layer.masksToBounds = YES;
        [_turnOffBtn addTarget:self action:@selector(turnOffBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _turnOffBtn;
}

- (UIButton *)speakerBtn {
    if (!_speakerBtn) {
        _speakerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 60, 60, 60);
        [_speakerBtn setFrame:frame];
        [_speakerBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        if (_isSpeaker) {
            [_speakerBtn setImage:[UIImage imageNamed:@"yy_live_d_2"] forState:UIControlStateNormal];
        } else {
            [_speakerBtn setImage:[UIImage imageNamed:@"yy_live_d"] forState:UIControlStateNormal];
        }
        [_speakerBtn addTarget:self action:@selector(spankerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _speakerBtn;
}

- (NSTimer *)countTimer {
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (void)dismissPhoneCallVCAfter:(NSTimeInterval)duration {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)turnOffBtnAction {
    [self dismissPhoneCallVCAfter:0];
}

- (void)acceptBtnAction {
    NSError *err;
    [self acceptCall:&err];
    if (err) {
        [self showHUDErrorWithStatus:err.localizedDescription];
    }
}

- (void)countTime {
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:_connectedDate];
    int totalseconds = (int)time;
    int hour = totalseconds / (60*60);
    int min  = (totalseconds - hour * 60 * 60) / 60;
    int second = totalseconds - hour * 60 * 60 - min * 60;
    NSString *hourStr = [NSString stringWithFormat:@"%d",hour];
    if (hourStr.length<2) {
        hourStr = [NSString stringWithFormat:@"0%@",hourStr];
    }
    NSString *minStr = [NSString stringWithFormat:@"%d",min];
    if (minStr.length<2) {
        minStr = [NSString stringWithFormat:@"0%@",minStr];
    }
    NSString *secondStr = [NSString stringWithFormat:@"%d",second];
    if (secondStr.length<2) {
        secondStr = [NSString stringWithFormat:@"0%@",secondStr];
    }
    _noticeLabel.text = [NSString stringWithFormat:@"网络通话中  %@:%@:%@",hourStr,minStr,secondStr];
    
}

- (void)spankerBtnAction:(UIButton *)sender {
    _isSpeaker = !_isSpeaker;
    [self enabelSpeaker:_isSpeaker];
    if (_isSpeaker) {
        [_speakerBtn setImage:[UIImage imageNamed:@"yy_live_d_2"] forState:UIControlStateNormal];
    } else {
        [_speakerBtn setImage:[UIImage imageNamed:@"yy_live_d"] forState:UIControlStateNormal];
    }
}

#pragma mark - Override
- (void)mediaCallConnectedByUser:(NSString *)userId {
    AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
    });
    _connectedDate = [[NSDate alloc]init];
    [_acceptBtn setHidden:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.countTimer fire];
    });
}

- (void)mediaCallRemotePauseByUser:(NSString *)userId {
    AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        _noticeLabel.text = @"会话被打断!!!";
        [self.countTimer invalidate];
        [self dismissPhoneCallVCAfter:3];
    });
}

- (void)mediaCallEndByUser:(NSString *)userId {
    AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
    });
    NSLog(@"************** end by user :%@",userId);
    [self showHUDInfoWithStatus:@"通话已挂断"];
    dispatch_async(dispatch_get_main_queue(), ^{
//        _noticeLabel.text = @"通话挂断";
        [self.countTimer invalidate];
        [self dismissPhoneCallVCAfter:3];
    });
}

- (void)mediaCallError:(NSError *)error fromUser:(NSString *)userId {
    AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate, ^{
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.code == 101 || [error.userInfo[@"msg"] isEqualToString:@"No response."]) {
            _noticeLabel.text = @"对方不在线，通话将自动挂断";
        } else {
            _noticeLabel.text = @"通话异常!!!";
        }
        [self.countTimer invalidate];
        [self dismissPhoneCallVCAfter:3];

    });
}

#pragma mark - 近距离传感器

- (void)changeProximityMonitorEnableState:(BOOL)enable {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        if (enable) {
            
            //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
            
        } else {
            
            //删除近距离事件监听
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

- (void)sensorStateChange:(NSNotificationCenter *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        //黑屏
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    } else {
        //没黑屏幕
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

@end
