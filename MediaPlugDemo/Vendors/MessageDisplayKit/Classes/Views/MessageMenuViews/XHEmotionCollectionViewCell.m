//
//  XHEmotionCollectionViewCell.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionCollectionViewCell.h"

@interface XHEmotionCollectionViewCell ()

/**
 *  显示表情封面的控件
 */
@property (nonatomic, weak) UIImageView *emotionImageView;

/**
 *  emoji 表情
 */
@property (nonatomic, weak) UILabel *emojiLabel;

/**
 *  配置默认控件和参数
 */
- (void)setup;
@end

@implementation XHEmotionCollectionViewCell

#pragma setter method

- (void)setEmotion:(XHEmotion *)emotion {
    _emotion = emotion;
    
    // TODO:
    if (XHBubbleEmotionTypeEmoji == emotion.emotionType) {
        if (emotion.emotionPath) {
            self.emojiLabel.text = emotion.emotionPath;
        }
    } else if(XHBubbleEmotionTypeGif == emotion.emotionType) {
        self.emotionImageView.image = emotion.emotionConverPhoto;
    }
    
}

#pragma mark - Life cycle

- (void)setup {
    if (!_emotionImageView) {
        UIImageView *emotionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kXHEmotionImageViewSize, kXHEmotionImageViewSize)];
        emotionImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:emotionImageView];
        self.emotionImageView = emotionImageView;
    }
    
    if (!_emojiLabel) {
        UILabel *emoji = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kXHEmotionEmojiSize, kXHEmotionEmojiSize)];
        emoji.textAlignment = NSTextAlignmentCenter;
        emoji.backgroundColor = [UIColor clearColor];
        [self addSubview:emoji];
        self.emojiLabel = emoji;
    }
}

- (void)awakeFromNib {
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotion = nil;
}

@end
