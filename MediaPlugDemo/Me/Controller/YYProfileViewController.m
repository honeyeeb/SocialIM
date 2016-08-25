//
//  YYProfileViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/8.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYProfileViewController.h"
#import "YYProfilePushSettingViewController.h"
#import "YYProfileMeTableViewCell.h"
#import "YYProfileSwitchTableViewCell.h"
#import "YYScanViewController.h"
#import "YYVersionViewController.h"

#import "YYMediaSDKEngine.h"

typedef NS_ENUM(NSInteger, YYProfileSectionType) {
    YYProfileSectionTypeMe              = 0,
//    YYProfileSectionTypeMute,
    YYProfileSectionTypePush,
//    YYProfileSectionTypeScan,
    YYProfileSectionTypeVersion,
    
    YYProfileSectionTypeAll,
    
};


static NSString *const kProfileMeTableViewCellID                = @"kProfileMeTableViewCellID";
static NSString *const kProfileSwitchTabelViewCellID            = @"kProfileSwitchTabelViewCellID";
static NSString *const kProfileScanTableViewCellID              = @"kProfileScanTableViewCellID";
static NSString *const kProfileSubstype2TabelViewCellID         = @"kProfileSubstype2TabelViewCellID";


NSString *const kProfilePushSettingSegueID                      = @"yy_profile_push_setting_segue_id";


@interface YYProfileViewController ()

/**
 *  设置推送开始时间(0~24)
 */
@property (assign, nonatomic) NSInteger pushStartTime;
/**
 *  设置推送结束时间(0~24)
 */
@property (assign, nonatomic) NSInteger pushEndTime;

@end

@implementation YYProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initViewData];
    [self.navigationItem setTitle:@"我"];
    
    [self.tableView registerNib:[YYProfileMeTableViewCell nib] forCellReuseIdentifier:kProfileMeTableViewCellID];
    [self.tableView registerNib:[YYProfileSwitchTableViewCell nib] forCellReuseIdentifier:kProfileSwitchTabelViewCellID];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getDevicePushInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

- (void)initViewData {
    self.pushStartTime = 0;
    self.pushEndTime = 24;
}

- (void)performScanViewController {
    YYScanViewController *scanVC = [[YYScanViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kProfilePushSettingSegueID]) {
        YYProfilePushSettingViewController *pushSetVC = (YYProfilePushSettingViewController *)segue.destinationViewController;
        pushSetVC.startTime = _pushStartTime;
        pushSetVC.endTime = _pushEndTime;
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYProfileSectionTypeMe) {
        // 头像
        return 80.0;
    }
    return 50.0;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView {
    return YYProfileSectionTypeAll;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YYProfileSectionTypeMe) {
        // 个人信息
        YYProfileMeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileMeTableViewCellID];
        [cell.titleTextLab setText:[YYMediaSDKEngine sharedInstance].userModel.userNickName];
        [cell.detailTextLab setText:[YYMediaSDKEngine sharedInstance].userModel.userID];
        
        return cell;
    }
//    else if (indexPath.section == YYProfileSectionTypeMute) {
//        // 静默／听筒
//        YYProfileSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileSwitchTabelViewCellID];
//        [cell.titleTextLab setText:@"听筒模式"];
//        
//        return cell;
//    }
//    else if (indexPath.section == YYProfileSectionTypeScan) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileScanTableViewCellID];
//        if (!cell) {
//            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kProfileScanTableViewCellID];
//        }
//        [cell.textLabel setText:@"扫一扫"];
//        
//        return cell;
//    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kProfileSubstype2TabelViewCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kProfileSubstype2TabelViewCellID];
        }
        if (indexPath.section == YYProfileSectionTypePush) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [cell.textLabel setText:@"push提醒时段"];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld-%ld", _pushStartTime, _pushEndTime]];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.textLabel setText:@"版本信息"];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"V %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
        }
        
        return cell;
    }
    
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == YYProfileSectionTypePush ) { //|| indexPath.section == YYProfileSectionTypeScan) {
//        return YES;
//    }
//    return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == YYProfileSectionTypePush) {
        [self performSegueWithIdentifier:kProfilePushSettingSegueID sender:nil];
    } else if (indexPath.section == YYProfileSectionTypeVersion) {
        YYVersionViewController *versionVC = [[YYVersionViewController alloc]init];
        [self.navigationController pushViewController:versionVC animated:YES];
    }
//    else if (indexPath.section == YYProfileSectionTypeScan) {
//        [self performScanViewController];
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - Network

- (void)getDevicePushInfo {
    WEAKSELF
    [self showHUD];
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK deviceInfoWithCompletionHandler:^(NSDictionary *deviceInfo, NSError *requestError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (requestError) {
                [weakSelf showHUDErrorWithStatus:requestError.localizedDescription];
            } else {
                weakSelf.pushStartTime = [[deviceInfo objectForKey:@"start_time"] integerValue];
                weakSelf.pushEndTime = [[deviceInfo objectForKey:@"end_time"] integerValue];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:YYProfileSectionTypePush] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf dismissHUD];
            }
        });
    }];
}

@end
