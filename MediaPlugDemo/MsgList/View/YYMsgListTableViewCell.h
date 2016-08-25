//
//  YYMsgListTableViewCell.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewCell.h"



@interface YYMsgListTableViewCell : YYBaseTableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLab;

@property (weak, nonatomic) IBOutlet UILabel *timeTextLab;

@property (weak, nonatomic) IBOutlet UILabel *titleTextLab;

@property (weak, nonatomic) IBOutlet UIImageView *badgeImg;

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;



- (void)configMsgListCell:(id)model;

@end
