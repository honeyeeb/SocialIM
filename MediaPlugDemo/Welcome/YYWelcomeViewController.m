//
//  YYWelcomeViewController.m
//  YouYunDemo
//
//  Created by Frederic on 16/1/14.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYWelcomeViewController.h"

#import "AppDelegate.h"
#import "YYMediaSDKEngine.h"
#import "MediaPlusSDK+IM.h"
#import "MediaPlusSDKDelegate.h"

NSString * const kConfigedUserNickName = @"yyConfigedUserNickName";

NSString * const kSuccessLogin         = @"yySuccessLoginKey";

NSString * const kWelcomeSugeTabVc     = @"yy_welcome_tabviewcontroller_id";

NSString * const kUserDefaultUInfo      = @"yyUserInfo";

@interface YYWelcomeViewController ()<UIAlertViewDelegate, UITextFieldDelegate>
{
    BOOL isAuthing;
    
}

// 一键登录
@property (weak, nonatomic) IBOutlet UIButton *signInOrSignUpButton;


@end

@implementation YYWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[YYMediaSDKEngine sharedInstance] addNoTagMediaPlusDelegate:self];
    
    isAuthing = NO;
    [_signInOrSignUpButton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSuccessLogin]) {
        // 已经登录过, 隐藏登录按钮自动登录
        [self.signInOrSignUpButton setHidden:YES];
        [self signInButtonAction:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[YYMediaSDKEngine sharedInstance] removeNoTagMediaPlusDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 登录注册
- (IBAction)signInButtonAction:(id)sender {
    if (!isAuthing) {
        isAuthing = YES;
        [self showHUD];
        [[YYMediaSDKEngine sharedInstance]signin];
    }
}

// 成功获取用户ID
- (void)recivedUserIDSucc {
    [self dismissHUDWithDelay:1];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSuccessLogin];
    BOOL hasUsrName = ![[YYMediaSDKEngine sharedInstance].userModel.userID isEqualToString:[YYMediaSDKEngine sharedInstance].userModel.userNickName];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kConfigedUserNickName] || hasUsrName) {
        // 设置过用户昵称，页面跳转
        [self performSegueWithIdentifier:kWelcomeSugeTabVc sender:self];
    } else {
        // 设置用户昵称
        [self updateUserInfo];
    }
}
// 登录失败
- (void)recivedUserIDFailed {
    isAuthing = NO;
    [self showHUDErrorWithStatus:@""];
    if (self.signInOrSignUpButton.hidden) {
        [self.signInOrSignUpButton setHidden:NO];
    }
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误" message:@"登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - updateUserInfo
- (void)updateUserInfo {
    UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"设置昵称" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alerView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alerView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"设置昵称"]) {
        // 设置昵称
        [[alertView textFieldAtIndex:buttonIndex] resignFirstResponder];
        NSString *userName = [NSString stringWithFormat:@"%@", [alertView textFieldAtIndex:buttonIndex].text];
        if (![userName isEmptyString]) {
            // 更新用户名称
            NSMutableDictionary *infoDic = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:kUserDefaultUInfo]];
            [infoDic setObject:userName forKey:@"nickname"];
            [[NSUserDefaults standardUserDefaults]setObject:infoDic forKey:kUserDefaultUInfo];
            [self sendUpdateUserName:userName];
        } else {
            [self updateUserInfo];
        }
        
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kWelcomeSugeTabVc]) {
        YYTabBarViewController *tabBarController = segue.destinationViewController;
        if (tabBarController) {
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate setTabBarController:tabBarController];
        }
    }
}

- (void)sendUpdateUserName:(NSString *)userName {
    WEAKSELF
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialAsyncRequest:@"POST" url:[NSString stringWithFormat:@"%@/users/update", [YYMediaSDKEngine hostURL]] params:[NSString stringWithFormat:@"nickname=%@", userName] callbackId:100 timeout:10.0 completion:^(NSDictionary *json, NSError *error) {
        if (!error) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kConfigedUserNickName];
            // 页面跳转
            [YYMediaSDKEngine sharedInstance].userModel.userNickName = userName;
            [weakSelf performSegueWithIdentifier:kWelcomeSugeTabVc sender:nil];
        } else {
            [weakSelf showHUDErrorWithStatus:error.localizedDescription];
        }
    }];
}

#pragma mark - MediaPlusSDKDelegate

- (void)mediaPlus:(MediaPlusSDK *)instance authUserinfo:(NSDictionary *)userinfo withError:(NSError *)error {
    
    if (!error && userinfo) {
        [self recivedUserIDSucc];
    } else {
        [self recivedUserIDFailed];
    }
}

@end
