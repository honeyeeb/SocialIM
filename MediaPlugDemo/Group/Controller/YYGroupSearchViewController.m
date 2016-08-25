//
//  YYGroupSearchViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/7.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupSearchViewController.h"
#import "YYGroupListTableViewCell.h"

#import "YYGroupModel.h"
#import "YYMediaSDKEngine.h"

static NSString *const kGroupSearchTableViewCellID      = @"kGroupSearchTableViewCellID";

NSString *const kGroupSearchApplyJoinSegueID            = @"yy_group_search_apply_join_segue_id";


@interface YYGroupSearchViewController ()<UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem;


@end

@implementation YYGroupSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"搜索群组"];
    [self.tableView registerNib:[YYGroupListTableViewCell nib] forCellReuseIdentifier:kGroupSearchTableViewCellID];
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

- (void)searchGroup {
    if ([_searchBarItem.text isEmptyString]) {
        return;
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
    YYGroupListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupSearchTableViewCellID];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBa {
    
}

@end
