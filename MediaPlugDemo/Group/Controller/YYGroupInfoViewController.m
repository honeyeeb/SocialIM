//
//  YYGroupInfoViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/7.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupInfoViewController.h"
#import "YYGroupMemberViewController.h"

#import "YYGroupModel.h"
#import "YYMediaSDKEngine.h"
#import "YYMsgManager.h"


static NSString * kGroupInfoNameDescTableViewCellID                = @"kGroupInfoNameDescTableViewCellID";

static NSString * kGroupInfoMemberTableViewCellID                  = @"kGroupInfoMemberTableViewCellID";

static NSString * kGroupInfoClearLogTableViewCellID                = @"kGroupInfoClearLogTableViewCellID";

NSString *const kGroupInfoClearAllMessageNF                        = @"kGroupInfoClearAllMessageNF";


NSString *const kGroupInfoMemberSegueID                            = @"yy_group_info_group_member_segue_id";


typedef NS_ENUM(NSInteger, GroupInfoCellType) {
    GroupInfoCellTypeName       = 0,
    GroupInfoCellTypeDesc,
    GroupInfoCellTypeMember,
    GroupInfoCellTypeClearLog,
    GroupInfoCellTypeExit,
    
    GroupInfoCellTypeAll,
};

@interface YYGroupInfoViewController ()

@property (nonatomic, strong) YYGroupModel *groupModel;

@end

@implementation YYGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataSource {
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYGroupManage *groupInfo = [[YYGroupManage alloc]init];
        [groupInfo getGroupInfo:_groupID completion:^(YYGroupModel *group, NSError *err) {
            if (!err) {
                weakSelf.groupModel = group;
            } else {
                NSLog(@"===%@", err.localizedDescription);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationItem setTitle:group.groupName];
                [weakSelf.tableView reloadData];
            });
        }];
    });
}

- (void)exitGroup {
    WEAKSELF
    [self showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        YYGroupManage *manager = [[YYGroupManage alloc]init];
        [manager exitGroup:_groupID completion:^(NSError *err) {
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!err) {
                    [weakSelf dismissHUD];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                } else {
                    [weakSelf showHUDErrorWithStatus:err.localizedDescription];
                }
            });
        }];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kGroupInfoMemberSegueID]) {
        YYGroupMemberViewController *memberVC = (YYGroupMemberViewController *)segue.destinationViewController;
        memberVC.groupID = _groupID;
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return GroupInfoCellTypeAll;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == GroupInfoCellTypeName || indexPath.row == GroupInfoCellTypeDesc) {
        cell = [tableView dequeueReusableCellWithIdentifier:kGroupInfoNameDescTableViewCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kGroupInfoNameDescTableViewCellID];
        }
        if (indexPath.row == GroupInfoCellTypeName) {
            [cell.textLabel setText:@"群名称:"];
            [cell.detailTextLabel setText:_groupModel.groupName];
        } else {
            [cell.textLabel setText:@"群简介:"];
            [cell.detailTextLabel setText:_groupModel.groupDesc];
        }
    } else if (indexPath.row == GroupInfoCellTypeMember) {
        cell = [tableView dequeueReusableCellWithIdentifier:kGroupInfoMemberTableViewCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupInfoMemberTableViewCellID];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        [cell.textLabel setText:@"群成员"];
    } else if (indexPath.row == GroupInfoCellTypeClearLog) {
        cell = [tableView dequeueReusableCellWithIdentifier:kGroupInfoClearLogTableViewCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupInfoClearLogTableViewCellID];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            [label setText:@"清空聊天记录"];
            [label setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:label];
        }
        
        
    } else if (indexPath.row == GroupInfoCellTypeExit) {
        cell = [tableView dequeueReusableCellWithIdentifier:kGroupInfoClearLogTableViewCellID];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGroupInfoClearLogTableViewCellID];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
            [label setText:@"退出群组"];
            [label setTextAlignment:NSTextAlignmentCenter];
            [cell addSubview:label];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == GroupInfoCellTypeName || indexPath.row == GroupInfoCellTypeDesc) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == GroupInfoCellTypeMember) {
        // 群成员
        [self performSegueWithIdentifier:kGroupInfoMemberSegueID sender:nil];
    } else if (indexPath.row == GroupInfoCellTypeClearLog) {
        // 清除聊天记录
        [[NSNotificationCenter defaultCenter] postNotificationName:kGroupInfoClearAllMessageNF object:nil];
    } else if (indexPath.row == GroupInfoCellTypeExit) {
        // 退群
        if (_groupModel.groupMemberRole == YYGroupMemberRoleTypeRoot) {
            [self showHUDErrorWithStatus:@"您是群主，不可退群"];
        } else {
            [self exitGroup];
        }
    }
}

//- (void)clearAllMessage {
//    WEAKSELF
//    __block NSError *err;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [[YYMsgManager sharedInstance] clearAllMessages:weakSelf.groupID error:&err];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (err) {
//                NSLog(@"====%s===error:%@", __FUNCTION__, err);
//            }
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        });
//    });
//}

@end
