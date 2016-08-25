//
//  YYGroupListTableViewCell.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/6.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYGroupListTableViewCell.h"
#import "YYGroupModel.h"
#import "YYUserModel.h"

@implementation YYGroupListTableViewCell

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
    if ([model isKindOfClass:[YYGroupModel class]]) {
        YYGroupModel *group = (YYGroupModel *)model;
        [self.badgeImg setHidden:YES];
        if (![group.groupName isEmptyString]) {
            [self.titleTextLab setText:group.groupName];
        }
        if (![group.groupDesc isEmptyString]) {
            [self.detailTextLab setText:group.groupDesc];
        }
        if (group.groupMemberRole == YYGroupMemberRoleTypeRoot) {
            [self.extTextLab setText:@"已创建"];
        } else {
            [self.extTextLab setText:@"已加入"];
        }
    } else if ([model isKindOfClass:[YYUserModel class]]) {
        YYUserModel *user = (YYUserModel *)model;
        [self.badgeImg setHidden:YES];
        if (![user.userNickName isEmptyString]) {
            [self.titleTextLab setText:user.userNickName];
        }
        if (![user.userID isEmptyString]) {
            [self.detailTextLab setText:user.userID];
        }
        if (user.roleType == YYGroupMemberRoleTypeRoot) {
            [self.extTextLab setText:@"群主"];
        } else if (user.roleType == YYGroupMemberRoleTypeAdmin) {
            [self.extTextLab setText:@"管理员"];
        } else {
            [self.extTextLab setText:@"成员"];
        }
    }
}

@end
