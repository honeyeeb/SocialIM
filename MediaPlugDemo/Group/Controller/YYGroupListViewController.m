//
//  YYGroupListViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupListViewController.h"
#import "YYGroupListTableViewCell.h"
#import "YYIMChatViewController.h"

#import "YYGroupModel.h"
#import "YYMediaSDKEngine.h"

static NSString *const kGroupListTableViewCellID    = @"kGroupListTableViewCellID";

NSString *const kGroupListCreateSugueID             = @"yy_group_list_create_sugue_id";

NSString *const kGroupListSearchSugueID             = @"yy_group_List_search_group_sugue_id";

NSString *const kGroupListChatIMSegueID             = @"yy_group_list_chat_segue_id";


@interface YYGroupListViewController ()<UIActionSheetDelegate>

@property (nonatomic, strong) YYGroupManage *groupList;

@end


@implementation YYGroupListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[YYGroupListTableViewCell nib] forCellReuseIdentifier:kGroupListTableViewCellID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (YYGroupManage *)groupList {
    if (!_groupList) {
        _groupList = [[YYGroupManage alloc]init];
    }
    return _groupList;
}

- (void)loadDataSource {
    WEAKSELF;
    [self showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf.groupList getGroupListHandler:^(NSArray *groups, NSError *err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (err) {
                    [weakSelf showHUDErrorWithStatus:err.localizedDescription];
                } else {
                    [weakSelf dismissHUD];
                }
                weakSelf.dataSource = [NSMutableArray arrayWithArray:groups];
                [weakSelf.tableView reloadData];
            });
        }];
    });
}

- (IBAction)addBarBtnitemAction:(UIBarButtonItem *)sender {
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建群", nil];
    [action showInView:self.view];
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
    YYGroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupListTableViewCellID];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    YYGroupListTableViewCell *cells = (YYGroupListTableViewCell *)cell;
    if (indexPath.row < self.dataSource.count) {
        YYGroupModel *model = self.dataSource[indexPath.row];
        [cells configCellInfo:model];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.dataSource.count) {
        YYGroupModel *model = self.dataSource[indexPath.row];
        [self performSegueWithIdentifier:kGroupListChatIMSegueID sender:model];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kGroupListCreateSugueID]) {
        
    } else if ([segue.identifier isEqualToString:kGroupListSearchSugueID]) {
        
    } else if ([segue.identifier isEqualToString:kGroupListChatIMSegueID]) {
        YYGroupModel *model = sender;
        if (model) {
            YYIMChatViewController *chatVC = (YYIMChatViewController *)segue.destinationViewController;
            chatVC.targetType = YYChatTargetTypeGroup;
            chatVC.targetid = model.groupID;
            chatVC.targetName = model.groupName;
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) {
        // 搜索群
//        [self performSegueWithIdentifier:kGroupListSearchSugueID sender:nil];
    } else if (buttonIndex == 0) {
        // 创建群
        [self performSegueWithIdentifier:kGroupListCreateSugueID sender:nil];
    }
}

@end
