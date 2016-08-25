//
//  YYProfileSwitchTableViewCell.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/8.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewCell.h"

@interface YYProfileSwitchTableViewCell : YYBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleTextLab;

@property (weak, nonatomic) IBOutlet UISwitch *switchItem;

@end
