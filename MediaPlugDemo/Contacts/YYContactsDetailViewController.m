//
//  YYContactsDetailViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYContactsDetailViewController.h"
#import "YYIMChatViewController.h"
#import "YYPhoneCallViewController.h"

#import "YYUserModel.h"
#import "YYConferenceModel.h"


NSString *const kContactDetailIMChatSugueID                 = @"yy_contact_detail_chat_suge_id";

@interface YYContactsDetailViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

@property (weak, nonatomic) IBOutlet UILabel *nameTextLab;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLab;


@end

@implementation YYContactsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"联系人详情"];
    
    [_nameTextLab setText:_userModel.userNickName];
    [_detailTextLab setText:_userModel.userID];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)chatBtnAction:(UIButton *)sender {
    [self performSegueWithIdentifier:kContactDetailIMChatSugueID sender:nil];
}

- (IBAction)mediaBtnAction:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打电话", @"电话会议", nil];
    [actionSheet showInView:self.view];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    // yy_contact_detail_chat_suge_id
    if ([segue.identifier isEqualToString:kContactDetailIMChatSugueID]) {
        // 单聊
        YYIMChatViewController *chatVC = segue.destinationViewController;
        chatVC.targetid = _userModel.userID;
        chatVC.targetName = _userModel.userNickName;
        chatVC.targetType = YYChatTargetTypeSingle;
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // 打电话
        [self callUser:_userModel.userID userName:_userModel.userNickName];
    } else if(buttonIndex == 1) {
        // 电话会议
        [self conferenceRequestRoom];
    }
}

- (void)successRequestConferenceRoom:(YYConferenceModel *)conferenceModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self callRoom:conferenceModel.roomID withKey:conferenceModel.key error:nil];
        [self conferenceInviteUsers:@[_userModel.userID] roomID:conferenceModel.roomID key:conferenceModel.key];
        [self presentConferenceViewController:conferenceModel];
        
    });

}

@end
