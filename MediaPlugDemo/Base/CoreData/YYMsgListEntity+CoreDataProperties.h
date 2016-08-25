//
//  YYMsgListEntity+CoreDataProperties.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/5.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YYConversationEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYConversationEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *convid;
@property (nullable, nonatomic, retain) NSString *convName;
@property (nullable, nonatomic, retain) NSString *detailName;
@property (nullable, nonatomic, retain) NSNumber *time;
@property (nullable, nonatomic, retain) NSNumber *unreadNum;
@property (nullable, nonatomic, retain) NSNumber *msgMediaType;
@property (nullable, nonatomic, retain) NSNumber *msgDirectionType;
@property (nullable, nonatomic, retain) NSNumber *msgTargetType;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *userid;

@end

NS_ASSUME_NONNULL_END
