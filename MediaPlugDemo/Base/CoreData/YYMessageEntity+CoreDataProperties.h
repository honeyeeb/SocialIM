//
//  YYMessageEntity+CoreDataProperties.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/18.
//  Copyright © 2016年 YouYun. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "YYMessageEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface YYMessageEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *audioSpanID;
@property (nullable, nonatomic, retain) NSString *audioPath;
@property (nullable, nonatomic, retain) NSData *extContent;
@property (nullable, nonatomic, retain) NSString *fileID;
@property (nullable, nonatomic, retain) NSNumber *fileLength;
@property (nullable, nonatomic, retain) NSNumber *filePieceSize;
@property (nullable, nonatomic, retain) NSNumber *msgDirection;
@property (nullable, nonatomic, retain) NSString *msgID;
@property (nullable, nonatomic, retain) NSNumber *msgMediaType;
@property (nullable, nonatomic, retain) NSString *senderID;
@property (nullable, nonatomic, retain) NSString *senderName;
@property (nullable, nonatomic, retain) NSString *textContent;
@property (nullable, nonatomic, retain) NSString *thumbnailPath;
@property (nullable, nonatomic, retain) NSNumber *timestamp;
@property (nullable, nonatomic, retain) NSString *conversationID;
@property (nullable, nonatomic, retain) NSNumber *sended;
@property (nullable, nonatomic, retain) NSNumber *readed;
@property (nullable, nonatomic, retain) NSString *serverMsgID;
@property (nullable, nonatomic, retain) NSNumber *isLoaded;

@end

NS_ASSUME_NONNULL_END
