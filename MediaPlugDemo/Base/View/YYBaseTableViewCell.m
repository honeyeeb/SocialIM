//
//  YYBaseTableViewCell.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/2.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseTableViewCell.h"

@implementation YYBaseTableViewCell

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)configCellInfo:(YYBaseModel *)model {
    
}

@end
