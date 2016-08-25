//
//  XHEmotionCollectionViewFlowLayout.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionCollectionViewFlowLayout.h"
#import "XHMacro.h"

@implementation XHEmotionCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(kXHEmotionEmojiSize, kXHEmotionEmojiSize);
        int count = MDK_SCREEN_WIDTH / (kXHEmotionEmojiSize + kXHEmotionEmojiMinimumLineSpacing);
        CGFloat spacing = MDK_SCREEN_WIDTH / count - kXHEmotionEmojiSize;
        self.minimumLineSpacing = spacing;
        self.sectionInset = UIEdgeInsetsMake(10, spacing/2, 0, spacing/2);
        self.collectionView.alwaysBounceVertical = YES;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

@end
