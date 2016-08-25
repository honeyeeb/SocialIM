//
//  YYGroupCreateViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupCreateViewController.h"

#import "YYGroupModel.h"

@interface YYGroupCreateViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextFiled;

@property (weak, nonatomic) IBOutlet UITextView *descTextFiled;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;


@end

@implementation YYGroupCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"创建群组"];
    
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

- (IBAction)confirmBtnAction:(UIButton *)sender {
    YYGroupManage *group = [[YYGroupManage alloc]init];
    WEAKSELF
    [self showHUD];
    [group createGroup:_nameTextFiled.text description:_descTextFiled.text completion:^(NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                [weakSelf showHUDErrorWithStatus:err.localizedDescription];
            } else {
                [weakSelf dismissHUD];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
