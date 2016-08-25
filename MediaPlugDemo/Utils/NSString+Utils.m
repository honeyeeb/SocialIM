//
//  NSString+Utils.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL)isEmptyString {
    if ((self && ![@"" isEqualToString : self] && ![self isKindOfClass:[NSNull class]] && ![@"NULL" isEqualToString : self] && ![@"(null)" isEqualToString : self])) {
        return NO;
    }
    return YES;
}

@end
