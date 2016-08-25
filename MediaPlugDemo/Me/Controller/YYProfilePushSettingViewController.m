//
//  YYProfilePushSettingViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/8.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYProfilePushSettingViewController.h"

#import "YYMediaSDKEngine.h"

@interface YYProfilePushSettingViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;

@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (nonatomic, assign) BOOL updatingPush;

@end

@implementation YYProfilePushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_startDatePicker setMinuteInterval:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (IBAction)confirmBtnAction:(UIButton *)sender {
    [self updatePushSetting];
}

- (IBAction)canclePush:(UIBarButtonItem *)sender {
    [self canclePushNotification];
}

/**
 *  更新push推送时段
 */
- (void)updatePushSetting {
    if (_updatingPush) {
        return;
    }
    [self showHUD];
    self.updatingPush = YES;
    WEAKSELF
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH"];
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK deviceRegisterPush:[YYMediaSDKEngine sharedInstance].deviceToken pushStartTime:[dateFormatter stringFromDate:self.startDatePicker.date].integerValue endTime:[dateFormatter stringFromDate:self.endDatePicker.date].integerValue completionHandler:^(BOOL isRegister, NSError *requestError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (requestError) {
                [weakSelf showHUDErrorWithStatus:requestError.localizedDescription];
            } else {
                [weakSelf dismissHUD];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}

- (void)canclePushNotification {
    if (_updatingPush) {
        return;
    }
    [self showHUD];
    self.updatingPush = YES;
    WEAKSELF
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK deviceUnRegisterPush:^(BOOL isUnRegister, NSError *requestError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (requestError) {
                [weakSelf showHUDErrorWithStatus:requestError.localizedDescription];
            } else {
                [weakSelf dismissHUD];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}

@end
