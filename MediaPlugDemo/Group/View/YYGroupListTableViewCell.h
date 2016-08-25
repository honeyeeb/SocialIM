//
//  YYGroupListTableViewCell.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewCell.h"

@interface YYGroupListTableViewCell : YYBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

@property (weak, nonatomic) IBOutlet UILabel *titleTextLab;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLab;

@property (weak, nonatomic) IBOutlet UILabel *extTextLab;

@property (weak, nonatomic) IBOutlet UIImageView *badgeImg;


@end
