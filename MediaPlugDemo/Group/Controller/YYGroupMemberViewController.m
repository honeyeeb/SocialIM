//
//  YYGroupMemberViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/7.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupMemberViewController.h"
#import "YYGroupListTableViewCell.h"
#import "YYContactsViewController.h"

#import "YYGroupModel.h"
#import "YYUserModel.h"

static NSString *const kGroupMemberTableViewCellID              = @"kGroupMemberTableViewCellID";

NSString *const kGroupMemberNearbaySegueID                      = @"yy_group_member_neaybay_segue_id";


@interface YYGroupMemberViewController ()<UIAlertViewDelegate>


@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) BOOL isRequesting;

@end

@implementation YYGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"群成员"];
    [self.tableView registerNib:[YYGroupListTableViewCell nib] forCellReuseIdentifier:kGroupMemberTableViewCellID];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataSource {
    if (_isRequesting) {
        return;
    }
    self.isRequesting = YES;
    WEAKSELF
    [self showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYGroupManage *groupManage = [[YYGroupManage alloc]init];
        [groupManage getGroupMember:_groupID completion:^(NSArray *members, NSError *err) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (err) {
                    [weakSelf showHUDErrorWithStatus:err.localizedDescription];
                } else {
                    [weakSelf dismissHUD];
                }
                weakSelf.dataSource = [[NSMutableArray alloc]initWithArray:members];
                if (weakSelf.dataSource.count > 0) {
                    [weakSelf.navigationItem setTitle:[NSString stringWithFormat:@"群成员(%d)", (int)weakSelf.dataSource.count]];
                }
                [weakSelf.tableView reloadData];
            });
            weakSelf.isRequesting = NO;
        }];
        
    });
}

- (void)deleteGroupMember {
    if (_isRequesting) {
        return;
    }
    [self showHUD];
    self.isRequesting = YES;
    WEAKSELF
    if (_indexPath.row < self.dataSource.count) {
        YYUserModel *user = self.dataSource[_indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            YYGroupManage *groupManage = [[YYGroupManage alloc]init];
            [groupManage groupRemoveMember:_groupID members:@[user.userID] completion:^(NSError *err) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (err) {
                        [weakSelf showHUDErrorWithStatus:err.localizedDescription];
                    } else {
                        [weakSelf dismissHUD];
                    }
                    [weakSelf.dataSource removeObject:user];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.tableView reloadData];
                    [weakSelf.navigationItem setTitle:[NSString stringWithFormat:@"群成员(%d)", (int)weakSelf.dataSource.count]];
                });
                weakSelf.isRequesting = NO;
            }];
            
        });
    }
}

- (IBAction)inviteBarBtnAction:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kGroupMemberNearbaySegueID sender:nil];
}

- (void)showDeleteAlertViewMessage:(NSString *)msg {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                       message:msg
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles:@"确定", nil];
    [alertView show];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kGroupMemberNearbaySegueID]) {
        // 附近的人
        YYContactsViewController *detailVC = segue.destinationViewController;
        detailVC.fromType = YYContactsFromTypeGroup;
        detailVC.groupID = _groupID;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            
            break;
            
        case 1:
            [self deleteGroupMember];
            break;
            
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYGroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupMemberTableViewCellID];
    if (indexPath.row < self.dataSource.count) {
        YYUserModel *user = self.dataSource[indexPath.row];
        [cell configCellInfo:user];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        // 群主不可以删除
        YYUserModel *user = self.dataSource[indexPath.row];
        BOOL canDelete = user.roleType != YYGroupMemberRoleTypeRoot;
        return (canDelete ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone);
    }
    return UITableViewCellEditingStyleNone;
}

//ios8以上系统增加的可自定义编辑功能效果
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                             // 删除
                                                                             self.indexPath = indexPath;
                                                                             [self showDeleteAlertViewMessage:@"确认删除成员吗?"];
                                                                             
                                                                         }];
    
    NSArray *arr = @[rowAction];
    return arr;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        // 删除
        self.indexPath = indexPath;
        [self showDeleteAlertViewMessage:@"确认删除成员吗?"];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
