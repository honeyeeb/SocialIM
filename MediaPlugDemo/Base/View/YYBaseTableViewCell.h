//
//  YYBaseTableViewCell.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YYBaseModel;

@interface YYBaseTableViewCell : UITableViewCell

/**
 *  获取与自身名称相同的View的Nib文件
 *
 *  @return
 */
+ (UINib *)nib;

- (void)configCellInfo:(YYBaseModel *)model;

@end
