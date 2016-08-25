//
//  YYContactsViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYContactsViewController.h"
#import "YYContactsTableViewCell.h"
#import "YYContactsDetailViewController.h"
#import <CoreLocation/CoreLocation.h>

#import "YYLocationServiceUtil.h"
#import "YYContactManager.h"
#import "YYUserModel.h"
#import "YYGroupModel.h"
#import "YYMsgManager.h"
#import "YYMediaSDKEngine.h"
#import "YYMediaCoreData.h"


static NSString *kContactsVCCellID      = @"kContactsVCTableViewControllerCellID";

NSString *const kContactDetailSugueID   = @"yy_contacts_detail_segue_id";

NSString *const kGetNearbayMemberNotification = @"kGetNearbayMemberNotification";



@interface YYContactsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *inviteBarBtn;

@property (assign, nonatomic) BOOL isLocationOpen;

@property (assign, nonatomic) CLLocationCoordinate2D  location;

@property (nonatomic, assign) BOOL isRequesting;

@property (nonatomic, strong) UIView *tableHeaderV;

/**
 *  群组邀请附近的人，选中的附近的人
 */
@property (nonatomic, strong) NSMutableArray *selectedNearbayUserArr;


@end


@implementation YYContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"联系人"];
    [self configTableView];
    if (_fromType == YYContactsFromTypeGroup) {
        [_inviteBarBtn setTitle:@"邀请"];
    } else if(_fromType == YYContactsFromTypeHome) {
        [_inviteBarBtn setTitle:@""];
    } else if (_fromType == YYContactsFromTypeConference) {
        UIBarButtonItem *confBar = [[UIBarButtonItem alloc]initWithTitle:@"邀请" style:UIBarButtonItemStylePlain target:self action:@selector(confrenceRightBarBtnAction)];
        [self.navigationItem setRightBarButtonItem:confBar];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startGetNearbyUsers];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)selectedNearbayUserArr {
    if (!_selectedNearbayUserArr) {
        _selectedNearbayUserArr = [NSMutableArray array];
    }
    return _selectedNearbayUserArr;
}

- (UIView *)tableHeaderV {
    if (!_tableHeaderV) {
        _tableHeaderV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self labelTextHeight])];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, [self labelTextHeight])];
        label.textAlignment = NSTextAlignmentLeft;
        label.numberOfLines = 0;
        label.text = @"为方便开发者公司内部测试，系统自动读取附近用户。";
        label.textColor = [UIColor lightGrayColor];
        [_tableHeaderV addSubview:label];
    }
    return _tableHeaderV;
}

- (void)configTableView {
    [self.tableView registerNib:[YYContactsTableViewCell nib] forCellReuseIdentifier:kContactsVCCellID];
    self.tableView.tableHeaderView = self.tableHeaderV;
}

- (void)loadDataSource {
    if (self.isRequesting) {
        return;
    }
    [self showHUD];
    self.isRequesting = YES;
    WEAKSELF;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        YYContactManager *contact = [[YYContactManager alloc]init];
        [contact getNearbayContact:_location.latitude longitude:_location.longitude range:10000 completion:^(NSArray *response, NSError *err) {
            if (err) {
                NSLog(@"%s===%@", __FUNCTION__, err.localizedDescription);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *tmp = [NSMutableArray arrayWithArray:response];
                for (NSInteger i = tmp.count - 1; i >= 0; i--) {
                    YYUserModel *model = tmp[i];
                    if ([model.userID isEqualToString:[YYMediaSDKEngine sharedInstance].userModel.userID]) {
                        [tmp removeObject:model];
                        break;
                    }
                    // 更新／创建一个用户信息
                    NSError *errPrt;
                    [[YYMediaCoreData sharedInstance] createUserEntityUserModel:model error:&errPrt];
                    if (errPrt) {
                        NSLog(@"===false create user entity :%@", errPrt);
                    }
                }
                weakSelf.dataSource = tmp;
                [weakSelf.tableView reloadData];
                [weakSelf dismissHUD];
            });
            weakSelf.isRequesting = NO;
        }];
        
    });
}

- (IBAction)inviteBarBtnAction:(UIBarButtonItem *)sender {
    if (_fromType == YYContactsFromTypeGroup && self.selectedNearbayUserArr.count > 0) {
        // 邀请
        if (self.isRequesting) {
            return;
        }
        [self showHUD];
        self.isRequesting = YES;
        WEAKSELF
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            YYGroupManage *manager = [[YYGroupManage alloc]init];
            [manager groupInviteUsers:weakSelf.selectedNearbayUserArr groupID:_groupID completion:^(NSError *err) {
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (err) {
                        [weakSelf showHUDErrorWithStatus:err.localizedDescription];
                    } else {
                        [weakSelf dismissHUD];
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                });
                weakSelf.isRequesting = NO;
            }];
            
        });
    }}

- (void)confrenceRightBarBtnAction {
    if (_fromType == YYContactsFromTypeConference) {
        // 会议邀请人员
        if (self.selectedNearbayUserArr.count > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kGetNearbayMemberNotification object:nil userInfo:@{ @"result" : self.selectedNearbayUserArr }];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kContactDetailSugueID]) {
        YYContactsDetailViewController *detailVC = segue.destinationViewController;
        detailVC.userModel = sender;
    }
}

#pragma mark - UITableViewDelegate/DataSource

- (CGFloat)labelTextHeight {
    NSString *text = @"为方便开发者公司内部测试，系统自动读取附近用户。";
    CGFloat height = ceilf([text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17] } context:nil].size.height);
    return height;
}

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
    YYContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactsVCCellID];
    YYUserModel *model = [self.dataSource objectAtIndex:indexPath.row];
    if (_fromType == YYContactsFromTypeGroup || _fromType == YYContactsFromTypeConference) {
        // 邀请
        if ([self.selectedNearbayUserArr containsObject:model.userID]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (_fromType == YYContactsFromTypeHome) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell configCellInfo:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_fromType == YYContactsFromTypeGroup || _fromType == YYContactsFromTypeConference) {
        // 群组邀请
        YYUserModel *model = [self.dataSource objectAtIndex:indexPath.row];
        if ([self.selectedNearbayUserArr containsObject:model.userID]) {
            [self.selectedNearbayUserArr removeObject:model.userID];
        } else {
            [self.selectedNearbayUserArr addObject:model.userID];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (_fromType == YYContactsFromTypeHome) {
        // 首页进入、聊天
        if (indexPath.row < self.dataSource.count) {
            YYUserModel *user = self.dataSource[indexPath.row];
            if (user) {
                [self performSegueWithIdentifier:kContactDetailSugueID sender:user];
            }
        }
    }
}

#pragma mark - Network

- (void)startGetNearbyUsers{
    if ([YYLocationServiceUtil isLocationServiceOpen]) {
        _isLocationOpen = YES;
        WEAKSELF
        [[YYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
            [weakSelf handleFailLoation];
        } location:^(CLLocation *location) {
            if (location.coordinate.latitude == -180 && location.coordinate.longitude == -180) {
                [self handleFailLoation];
                return;
            }
            weakSelf.location = [location coordinate];//当前经纬
            if ([weakSelf respondsToSelector:@selector(doGetNearbyPeople)]) {
                [weakSelf doGetNearbyPeople];
            }
        }];
    } else {
        [self handleFailLoation];
    }
}

- (void)handleFailLoation {
    CLLocationCoordinate2D oldLoc = _location;
    if (oldLoc.latitude != -180 && oldLoc.longitude != -180) {
        oldLoc.latitude = -180;
        oldLoc.longitude = -180;
        _location = oldLoc;
        
    }
    NSString *errMsg;
    if (_isLocationOpen == YES) {
        errMsg =  @"无法获取你的位置信息。\n请到手机系统的[设置]->[无线局域网]  或 [蜂窝移动网络] 中设置网络";
    } else {
        errMsg =  @"无法获取你的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务，并允许微米使用定位服务";
    }
    [self showHUDErrorWithStatus:errMsg];
}

- (void)doGetNearbyPeople {
    if (_location.longitude != -180 && _location.latitude != -180 && (_location.longitude != 0 && _location.latitude != 0)) {
        [self loadDataSource];
    } else {
        
        [self.tableView reloadData];
    }
}


@end
