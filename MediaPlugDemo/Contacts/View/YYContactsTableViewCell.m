//
//  YYContactsTableViewCell.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYContactsTableViewCell.h"
#import "YYUserModel.h"


@implementation YYContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellInfo:(YYBaseModel *)model {
    if (!model) {
        return;
    }
    if ([model isKindOfClass:[YYUserModel class]]) {
        YYUserModel *info = (YYUserModel*)model;
        if (![info.userNickName isEmptyString]) {
            [self.titleTextLab setText:info.userNickName];
        }
        if (![info.userID isEmptyString]) {
            [self.detailTextLab setText:info.userID];
        }
        if (![info.distance isEmptyString]) {
            [self.distanceTextLab setText:[NSString stringWithFormat:@"%@米以内", info.distance]];
        }
        [self.iconImg setImage:[UIImage imageNamed:@"iconImg"]];
    }
}

@end
