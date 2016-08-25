//
//  YYContactsModel.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/6/3.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYBaseModel.h"

/**
 *  联系人model
 */
@interface YYContactManager : YYBaseModel


/**
 *  获取附近的人
 *
 *  @param latitude  纬度
 *  @param longitude 经度
 *  @param range     距离(米)
 *  @param handler   回调
 */
- (void)getNearbayContact:(double)latitude
                longitude:(double)longitude
                    range:(long)range
               completion:(void (^)(NSArray *response, NSError *err))handler;



@end
