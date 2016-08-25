//
//  YYVersionViewController.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/8/15.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYVersionViewController.h"

@interface YYVersionViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *logoImg;

@property (nonatomic, strong) UILabel *versionLab;

@property (nonatomic, strong) UILabel *detailLab;

@property (nonatomic, strong) UILabel *copyrightLab;

@end

@implementation YYVersionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"版本信息";
    [self.view addSubview:self.scrollView];
    [_scrollView addSubview:self.logoImg];
    [_scrollView addSubview:self.versionLab];
    [_scrollView addSubview:self.detailLab];
    [_scrollView addSubview:self.copyrightLab];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(_copyrightLab.frame) + 50);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT + 1);
    }
    return _scrollView;
}

- (UIImageView *)logoImg {
    if (!_logoImg) {
        CGRect frame = CGRectMake((SCREEN_WIDTH - 90) / 2, 15, 90, 90);
        _logoImg = [[UIImageView alloc]initWithFrame:frame];
        [_logoImg setImage:[UIImage imageNamed:@"iconImg"]];
    }
    return _logoImg;
}

- (UILabel *)versionLab {
    if (!_versionLab) {
        _versionLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_logoImg.frame) + 15, SCREEN_WIDTH, 20)];
        _versionLab.textAlignment = NSTextAlignmentCenter;
        _versionLab.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return _versionLab;
}

- (UILabel *)detailLab {
    if (!_detailLab) {
        _detailLab = [[UILabel alloc]init];
        _detailLab.textAlignment = NSTextAlignmentLeft;
        NSString *text = @"版本功能:\n\n\n1、 支持基础IM功能，支持以下消息类型：文本、表情、异步语音、照片、拍照上传；\n\n2、 支持两种聊天模式：单聊和群聊；同时群聊场景下支持基础群管理操作；\n\n3、 支持一对一实时语音通话和多人语音会议功能；同时支持基础通话操作，如静音模式切换、听筒模式切换等；\n\n4、 为方便开发者测试，联系人列表支持搜索到附近1公里内用户。";
        CGFloat height = ceilf([text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 60, 0) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17] } context:nil].size.height);
        _detailLab.text = text;
        _detailLab.numberOfLines = 0;
        _detailLab.frame = CGRectMake(30, CGRectGetMaxY(_versionLab.frame) + 15, SCREEN_WIDTH - 60, height);
    }
    return _detailLab;
}

- (UILabel *)copyrightLab {
    if (!_copyrightLab) {
        _copyrightLab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_detailLab.frame) + 80, SCREEN_WIDTH, 20)];
        _copyrightLab.textColor = [UIColor lightGrayColor];
        _copyrightLab.text = @"游云通讯 版权所有";
        _copyrightLab.textAlignment = NSTextAlignmentCenter;
    }
    return _copyrightLab;
}


@end
