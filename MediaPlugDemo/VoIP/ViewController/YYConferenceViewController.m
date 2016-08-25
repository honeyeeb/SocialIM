//
//  YYConferenceViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/22.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYConferenceViewController.h"
#import "YYContactsViewController.h"

#import "YYConferenceModel.h"
#import "YYMediaSDKEngine.h"
#import "YYUserModel.h"
#import "YYMediaCoreData.h"
#import "YYUserEntity.h"


static NSString *const kConferenceMemberTabelViewCellID             = @"kConferenceMemberTabelViewCellID";


@interface YYConferenceViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *nameIDLab;

@property (weak, nonatomic) IBOutlet UILabel *timeLab;

@property (weak, nonatomic) IBOutlet UIButton *muteBtn;

@property (weak, nonatomic) IBOutlet UIButton *speakBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *inviteBtn;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isMute;

@property (nonatomic, assign) BOOL isSpeaker;

@property (nonatomic, strong) NSTimer *countTimer;

@property (nonatomic, strong) NSDate *connectedDate;

@property (nonatomic, assign) BOOL shouldTerminate;

@end

@implementation YYConferenceViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"多人电话会议"];
    _isMute = NO;
    _isSpeaker = NO;
    
    _nameIDLab.text = [NSString stringWithFormat:@"昵称: %@  用户ID: %@", [YYMediaSDKEngine sharedInstance].userModel.userNickName, [YYMediaSDKEngine sharedInstance].userModel.userID];
                       
    if (![_confModel.roomID isEmptyString]) {
        _nameIDLab.text = [_nameIDLab.text stringByAppendingFormat:@"    房间ID: %@", _confModel.roomID];
    }
    [self addRightItemBarBtn];
    [self hideEmptyCells];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successGetNearbayUser:) name:kGetNearbayMemberNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _tableView.tableHeaderView = self.headerView;
    _shouldTerminate = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_shouldTerminate) {
        [self terminateCall];
        [self.countTimer invalidate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        UILabel *lab = [[UILabel alloc]initWithFrame:_headerView.bounds];
        lab.text = @"成员列表:";
        [_headerView addSubview:lab];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(_headerView.frame.size.width - 100, 0, 100, _headerView.frame.size.height);
        [btn setTitle:@"刷新成员" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(refreshConfrenceMemberAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:btn];
    }
    return _headerView;
}

- (NSTimer *)countTimer {
    if (!_countTimer) {
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
    }
    return _countTimer;
}

- (void)addRightItemBarBtn {
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"挂断离开" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarBtnItemAction)];
    [self.navigationItem setRightBarButtonItem:rightBtn];
}

- (IBAction)muteBtnAction:(UIButton *)sender {
    _isMute = !_isMute;
    if (_isMute) {
        [sender setImage:[UIImage imageNamed:@"yy_live_d_2"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"yy_live_d"] forState:UIControlStateNormal];
    }
    [self enabelMute:_isMute];
}

- (IBAction)speakBtnAction:(UIButton *)sender {
    _isSpeaker = !_isSpeaker;
    if (_isSpeaker) {
        [sender setImage:[UIImage imageNamed:@"yy_speak"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"yy_speak_2"] forState:UIControlStateNormal];
    }
    [self enabelSpeaker:_isSpeaker];
}

- (IBAction)inviteBtnAction:(UIButton *)sender {
    _shouldTerminate = NO;
    YYContactsViewController *nearbay = [[YYContactsViewController alloc]init];
    nearbay.fromType = YYContactsFromTypeConference;
    [self.navigationController pushViewController:nearbay animated:YES];
}

- (void)refreshConfrenceMemberAction {
    [self conferenceFetchUsersinRoom:_confModel.roomID];
}

- (void)rightBarBtnItemAction {
    [self rightBarBtnAction:0];
}

- (void)rightBarBtnAction:(NSTimeInterval)duration {
    [self.countTimer invalidate];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)hideEmptyCells {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

- (void)successGetNearbayUser:(NSNotification *)notification {
    NSArray *result = notification.userInfo[@"result"];
    if (result) {
        [self conferenceInviteUsers:result roomID:_confModel.roomID key:_confModel.key];
    }
}

- (void)successRequestConfrenceMembers:(NSArray *)members {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *userNameArr = [NSMutableArray array];
        [members enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *userID = (NSString *)obj;
            NSString *tmpName = [[YYMediaCoreData sharedInstance] fetchUserEntityWithUserID:userID error:nil].userName;
            if (tmpName) {
                [userNameArr addObject:[NSString stringWithFormat:@"%@  %@", userID, tmpName]];
            }
        }];
        _dataSource = userNameArr;
        [_tableView reloadData];
    });
    
}

- (void)countTime {
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:_connectedDate];
    int totalseconds = (int)time;
    int hour = totalseconds / (60*60);
    int min  = (totalseconds - hour * 60 * 60) / 60;
    int second = totalseconds - hour * 60 * 60 - min * 60;
    NSString *hourStr = [NSString stringWithFormat:@"%d",hour];
    if (hourStr.length < 2) {
        hourStr = [NSString stringWithFormat:@"0%@",hourStr];
    }
    NSString *minStr = [NSString stringWithFormat:@"%d",min];
    if (minStr.length < 2) {
        minStr = [NSString stringWithFormat:@"0%@",minStr];
    }
    NSString *secondStr = [NSString stringWithFormat:@"%d",second];
    if (secondStr.length < 2) {
        secondStr = [NSString stringWithFormat:@"0%@",secondStr];
    }
    _timeLab.text = [NSString stringWithFormat:@"会议时间 %@:%@:%@",hourStr,minStr,secondStr];
    
}

- (void)conferenceJoinedWith:(NSString *)roomID groupID:(NSString *)groupID users:(NSArray *)users {
    [self refreshConfrenceMemberAction];
}

- (void)conferenceMutedWith:(NSString *)roomID groupID:(NSString *)groupID fromUid:(NSString *)fromUid users:(NSArray *)users {
    
}

- (void)conferenceUnmutedWith:(NSString *)roomID groupID:(NSString *)groupID fromUid:(NSString *)fromUid users:(NSArray *)users {
    
}

- (void)conferenceKickedWith:(NSString *)roomID groupID:(NSString *)groupID fromUid:(NSString *)fromUid users:(NSArray *)users {
    [self refreshConfrenceMemberAction];
}

- (void)conferenceLeftWith:(NSString *)roomID groupID:(NSString *)groupID users:(NSArray *)users {
    [self refreshConfrenceMemberAction];
}

- (void)conferenceWillbeEndWith:(NSString *)roomID groupID:(NSString *)groupID intime:(NSInteger)second {
    [self showHUDInfoWithStatus:@"会议已结束"];
    [self rightBarBtnAction:4];
}

- (void)conferenceExpiredWithRoomID:(NSString *)roomID key:(NSString *)key {
    [self showHUDErrorWithStatus:@"会议出现问题"];
    [self rightBarBtnAction:4];
}

#pragma mark delegate

- (void)mediaCallConnectedByUser:(NSString *)userId {
    _connectedDate = [[NSDate alloc]init];
    [self.countTimer fire];
    [self refreshConfrenceMemberAction];
}
- (void)mediaCallRemotePauseByUser:(NSString *)userId {
    [self rightBarBtnAction:4];
}

- (void)mediaCallEndByUser:(NSString *)userId {
    [self rightBarBtnAction:4];
}

- (void)mediaCallError:(NSError *)error fromUser:(NSString *)userId {
    if (error.code == 101 || [error.userInfo[@"msg"] isEqualToString:@"No response."]) {
        [self showHUDErrorWithStatus:@"对方不在线，会议将自动挂断"];
    }
    [self rightBarBtnAction:4];
}


#pragma mark - UITableViewDelegate/DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kConferenceMemberTabelViewCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kConferenceMemberTabelViewCellID];
    }
    NSString *text = [NSString stringWithFormat:@"%ld.   %@", indexPath.row + 1, _dataSource[indexPath.row]];
    NSMutableAttributedString *muteAttStr = [[NSMutableAttributedString alloc]initWithString:text];
    [muteAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:28] range:NSMakeRange(0, 1)];
    
    [cell.textLabel setAttributedText:muteAttStr];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
