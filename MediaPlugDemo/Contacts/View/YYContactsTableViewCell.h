//
//  YYContactsTableViewCell.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewCell.h"

@interface YYContactsTableViewCell : YYBaseTableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *iconImg;

@property (weak, nonatomic) IBOutlet UILabel *titleTextLab;

@property (weak, nonatomic) IBOutlet UILabel *detailTextLab;

@property (weak, nonatomic) IBOutlet UILabel *distanceTextLab;


@end
