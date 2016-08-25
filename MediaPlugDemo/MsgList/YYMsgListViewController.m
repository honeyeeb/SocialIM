//
//  YYMsgListViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/1.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMsgListViewController.h"

#import "YYIMChatViewController.h"
#import "YYMsgListTableViewCell.h"
#import "YYNotifyViewController.h"

#import "UtilsDefine.h"
#import "YYMsgManager.h"
#import "YYConversationEntity.h"
#import "YYMediaCoreData.h"



static NSString *kMsgListVCTableViewCellID = @"kMsgListVCTableViewCellID";

NSString *const kMsgListChatSegueID       = @"yy_chatlist_chat_suge_id";

NSString *const kMsgListNotifySegueID       = @"yy_chatlist_notify_segue_id";

@interface YYMsgListViewController ()



@end

@implementation YYMsgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"消息"];
    
    [self.tableView registerNib:[YYMsgListTableViewCell nib] forCellReuseIdentifier:kMsgListVCTableViewCellID];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[YYMsgManager sharedInstance]addMessageListener:self];
    
    [self loadDataSource];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[YYMsgManager sharedInstance] removeMessageListener:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadDataSource {
    WEAKSELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *err;
        NSArray *convManager = [[YYMsgManager sharedInstance] getAllConversations:&err];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.dataSource = [NSMutableArray arrayWithArray:convManager];
            [weakSelf.tableView reloadData];
        });
    });
}

- (IBAction)notifiLeftBarBtnAction:(UIBarButtonItem *)sender {
//    [self performSegueWithIdentifier:kMsgListNotifySegueID sender:nil];
}

- (void)deleteConversionWithIndex:(NSInteger)row {
    WEAKSELF;
    __block NSError *err;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYConversationEntity *entity = self.dataSource[row];
        [[YYMsgManager sharedInstance] clearAllMessages:entity.convid error:&err];
        [[YYMsgManager sharedInstance] deleteConversationWithID:entity.convid error:&err];
        if (err) {
            NSLog(@"===%s===error: %@", __FUNCTION__, err);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeObjectAtIndex:row];
            [weakSelf.tableView reloadData];
        });
    });
    
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
    YYMsgListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMsgListVCTableViewCellID];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    YYMsgListTableViewCell *cells = (YYMsgListTableViewCell *)cell;
    YYConversationEntity *entity = self.dataSource[indexPath.row];
    [cells configMsgListCell:entity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YYConversationEntity *entity = self.dataSource[indexPath.row];
    [self performSegueWithIdentifier:kMsgListChatSegueID sender:entity];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// iOS 8
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                                                                             // 删除
                                                                             [self deleteConversionWithIndex:indexPath.row];
                                                                             
                                                                         }];
    
    NSArray *arr = @[rowAction];
    return arr;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([kMsgListChatSegueID isEqualToString:segue.identifier]) {
        if ([sender isKindOfClass:[YYConversationEntity class]]) {
            YYConversationEntity *entity = sender;
            YYIMChatViewController *chatVC = segue.destinationViewController;
            chatVC.targetid = entity.convid;
            chatVC.targetName = entity.convName;
            chatVC.targetType = [entity.msgTargetType integerValue];
        }
    }
}


#pragma mark - MessageManage

- (void)conversationAdded:(YYConversationModel*)conversation {
    [self loadDataSource];
}
- (void)conversationDeleted:(YYConversationModel*)conversation {
//    [self loadDataSource];
}
- (void)conversationUpdate:(YYConversationModel*)conversation {
    [self loadDataSource];
}
- (void)conversationsClear {
    [self loadDataSource];
}
- (void)conversationClearAllMsgs:(YYConversationModel*)conversation {
    [self loadDataSource];
}
- (void)conversationUnreadedNumChange:(YYConversationModel*)conversation {
    [self loadDataSource];
}

@end
