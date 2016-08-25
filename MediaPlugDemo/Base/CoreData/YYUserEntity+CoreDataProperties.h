//
//  YYUserEntity+CoreDataProperties.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/5.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YYUserEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYUserEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *userid;
@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSNumber *gender;
@property (nullable, nonatomic, retain) NSNumber *birthday;
@property (nullable, nonatomic, retain) NSString *icon;
@property (nullable, nonatomic, retain) NSString *phoneNum;
@property (nullable, nonatomic, retain) NSString *email;

@end

NS_ASSUME_NONNULL_END
