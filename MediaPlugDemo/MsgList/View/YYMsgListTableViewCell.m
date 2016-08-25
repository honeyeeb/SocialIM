//
//  YYMsgListTableViewCell.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMsgListTableViewCell.h"
#import "NSDate+DateTools.h"
#import "YYConversationEntity.h"
#import "YYMsgManager.h"


@implementation YYMsgListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _badgeLabel.layer.cornerRadius = 8;
    _badgeLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)configCellInfo:(YYBaseModel *)model {
//    if (model && [model isKindOfClass:[YYMsgListModel class]]) {
//        YYMsgListModel *info = (YYMsgListModel *)model;
//        if (![info.title isEmptyString]) {
//            [self.titleTextLab setText:info.title];
//        }
//        if (![info.detailTitle isEmptyString]) {
//            [self.detailTextLab setText:info.detailTitle];
//        }
//        [self.timeTextLab setText:[[NSDate dateWithTimeIntervalSince1970:info.timeTitle] timeAgoSinceNow]];
//        [self.iconImg setImage:[UIImage imageNamed:@"iconImg"]];
//    }
//}

- (void)configMsgListCell:(id)model {
    if ([model isKindOfClass:[YYConversationEntity class]]) {
        YYConversationEntity *entity = model;
        if (![entity.convName isEmptyString]) {
            [self.titleTextLab setText:entity.convName];
        }
        NSString *detailStr = entity.detailName;
        NSString *preDetailStr = @"";
        if (entity.msgDirectionType.integerValue == 1) {
            preDetailStr = @"[收到";
        } else {
            preDetailStr = @"[发送";
        }
        switch (entity.msgMediaType.integerValue) {
            case YYMessageMediaTypeText:
                preDetailStr = @"";
                break;
            case YYMessageMediaTypePhoto:
                detailStr = @"一张图片]";
                break;
            case YYMessageMediaTypeVoice:
                detailStr = @"一条语音]";
                break;
            case YYMessageMediaTypeVideo:
                detailStr = @"一段视频]";
                break;
            case YYMessageMediaTypeEmotion:
                detailStr = @"一个表情]";
                break;
            case YYMessageMediaTypeLocalPosition:
                detailStr = @"一个位置]";
                break;
            
        }
        [self.detailTextLab setText:[NSString stringWithFormat:@"%@%@", preDetailStr, detailStr]];
        [self.timeTextLab setText:[[NSDate dateWithTimeIntervalSince1970:[entity.time doubleValue]]timeAgoSinceNow]];
        [self.iconImg setImage:[UIImage imageNamed:@"iconImg"]];
        [self.badgeImg setHidden:YES];
        NSInteger count = [[YYMsgManager sharedInstance] fetchUnreadCountConvID:entity.convid];
        if (count <= 0) {
            _badgeLabel.hidden = YES;
        } else {
            _badgeLabel.hidden = NO;
            count < 100 ?( _badgeLabel.text = [NSString stringWithFormat:@"%ld", count]) : (_badgeLabel.text = @"99+");
        }
        
    }
}

@end
