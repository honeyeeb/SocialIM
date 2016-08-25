//
//  YYMediaCoreData.m
//  YouYunMediaDemo
//
//  Created by Frederic on 16/7/5.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "YYMediaCoreData.h"

#import "YYConversationEntity.h"
#import "YYConversationModel.h"
#import "XHMessage.h"
#import "YYUserModel.h"
#import "YYMessageEntity.h"
#import "YYUserEntity.h"



NSString *const kYYMediaCoreDataDoamin      = @"YYMediaCoreDataDomain";
/// 会话实体名称
NSString *const kConversationEntityName     = @"YYConversationEntity";
/// 聊天实体名称
NSString *const kMessageEntityName          = @"YYMessageEntity";
/// 用户实体名称
NSString *const kUserEntityName             = @"YYUserEntity";



static YYMediaCoreData *mediaCoreData = nil;

@implementation YYMediaCoreData

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediaCoreData = [[YYMediaCoreData alloc]init];
    });
    return mediaCoreData;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    @synchronized (self) {
        if (!mediaCoreData) {
            mediaCoreData = [super allocWithZone:zone];
        }
        return mediaCoreData;
    }
    return nil;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.eju.ioyouyun.yysocialdemo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"YYMediaDemo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"YYMediaDemo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YYMediaDemo_Domain" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - MsgList

- (NSArray *)getConvEntitiesWithUid:(NSString *)uid error:(NSError **)err {
    if ([uid isEmptyString]) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"uid param can not be null"}];
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kConversationEntityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userid == %@", uid]];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    request.sortDescriptors = @[descriptor];
    NSError *error = nil;
    NSArray *tmp = [_managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *results = [NSMutableArray arrayWithArray:tmp];
    
    [results sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        YYConversationEntity *entity1 = obj1;
        YYConversationEntity *entity2 = obj2;
        return [entity1.time doubleValue] < [entity2.time doubleValue];
    }];
//    for (YYConversationEntity *entity in results) {
//        if (entity.convid) {
//            NSInteger unreadCount = [self fetchUnreadMsg:entity.convid error:err];
//            entity.unreadNum = [NSNumber numberWithInteger:unreadCount];
//            if ([[self managedObjectContext] save:&error] == NO) {
//                *err = error;
//                NSLog(@"Error saving fetch all conversation context: %@\n%@", [error localizedDescription], [error userInfo]);
//            }
//        }
//    }
    if (!results) {
        NSLog(@"Error fetching all conversation objects: %@\n%@", [error localizedDescription], [error userInfo]);
        *err = error;
    }
    return results;
}

- (YYConversationEntity *)createConvEntity:(YYConversationModel *)model error:(NSError **)err {
    
    YYConversationEntity *msgList = [self fetchConvEntityConvID:model.conversationID userID:model.userID error:err];
    if (!msgList) {
        msgList = [NSEntityDescription insertNewObjectForEntityForName:kConversationEntityName inManagedObjectContext:_managedObjectContext];
    }
    if (![model.conversationID isEmptyString]) {
        [msgList setConvid:model.conversationID];
    }
    if (![model.conversationName isEmptyString]) {
        [msgList setConvName:model.conversationName];
    }
    if (![model.lastMsg.text isEmptyString]) {
        [msgList setDetailName:model.lastMsg.text];
    }
    if (![model.iconURL isEmptyString]) {
        [msgList setIcon:model.iconURL];
    }
    if (![model.userID isEmptyString]) {
        [msgList setUserid:model.userID];
    }
    if (model.lastMsg) {
        [msgList setTime:[NSNumber numberWithDouble:model.lastMsg.timestamp.timeIntervalSince1970]];
        [msgList setMsgMediaType:[NSNumber numberWithInteger:model.lastMsg.messageMediaType]];
        [msgList setMsgDirectionType:[NSNumber numberWithInteger:model.lastMsg.bubbleMessageType]];
    }
    [msgList setMsgTargetType:[NSNumber numberWithInteger:model.targetType]];
    [msgList setUnreadNum:[NSNumber numberWithInteger:model.unreadCount]];
    
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        *err = error;
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return msgList;
}

- (YYConversationEntity *)fetchConvEntityConvID:(NSString *)convID userID:(NSString *)userID error:(NSError **)err {
    if ([convID isEmptyString] || [userID isEmptyString]) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"uid and msgid param can not be null"}];
        
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kConversationEntityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"userid == %@ && convid == %@", userID, convID]];
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:err];
    YYConversationEntity *conv = [result lastObject];
    NSInteger unreadCount = [self fetchUnreadMsg:convID error:err];
    conv.unreadNum = [NSNumber numberWithInteger:unreadCount];
    if ([[self managedObjectContext] save:&error] == NO) {
        *err = error;
        NSLog(@"Error saving fetch conversation context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return conv;
}

- (void)deleteConvEntityConvID:(NSString *)convID userID:(NSString *)userID error:(NSError **)err {
    YYConversationEntity *conv = [self fetchConvEntityConvID:convID userID:userID error:err];
    if (conv) {
        // 删除
        [_managedObjectContext deleteObject:conv];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    } else {
//        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"can not find the conversation entity."}];
    }
}


#pragma mark - MessageEntity

- (NSArray *)getAllMessageEntityConversationID:(NSString *)convID offset:(NSInteger)offset error:(NSError **)err {
    if ([convID isEmptyString]) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"uid param can not be null"}];
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"conversationID == %@", convID]];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    request.sortDescriptors = @[descriptor];
    if (offset != -1) {
        request.fetchOffset = offset;
        request.fetchLimit = 20;
    }
    NSError *error = nil;
    NSArray *tmp = [_managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *results = [NSMutableArray arrayWithArray:tmp];
    
    [results sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        YYMessageEntity *entity1 = obj1;
        YYMessageEntity *entity2 = obj2;
        return [entity1.timestamp doubleValue] > [entity2.timestamp doubleValue];
    }];
    if (!results) {
        NSLog(@"Error fetching Employee objects: %@\n%@", [error localizedDescription], [error userInfo]);
        *err = error;
    }
    return results;
}

- (YYMessageEntity *)createMessageEntity:(XHMessage *)chatMsg conversationID:(NSString *)convID error:(NSError **)err {
    if ([convID isEmptyString] || !chatMsg) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"message model and conversation id can not be null" }];
        return nil;
    }
    YYMessageEntity *msgEntity = [self fetchMessageEntityMsgID:chatMsg.messageID error:err];
    if (!msgEntity) {
        msgEntity = [NSEntityDescription insertNewObjectForEntityForName:kMessageEntityName inManagedObjectContext:_managedObjectContext];
    }
    if (chatMsg) {
        [msgEntity setMsgID:chatMsg.messageID];
        if (chatMsg.audioSpanID) {
            [msgEntity setAudioSpanID:chatMsg.audioSpanID];
        }
        if (chatMsg.extContent) {
            [msgEntity setExtContent:chatMsg.extContent];
        }
        if (![chatMsg.fileID isEmptyString]) {
            [msgEntity setFileID:chatMsg.fileID];
        }
        if (![chatMsg.serverMsgID isEmptyString]) {
            [msgEntity setServerMsgID:chatMsg.serverMsgID];
        }
        [msgEntity setConversationID:convID];
        [msgEntity setFileLength:[NSNumber numberWithInteger:chatMsg.fileLength]];
        [msgEntity setFilePieceSize:[NSNumber numberWithInteger:chatMsg.filePieceSize]];
        [msgEntity setThumbnailPath:chatMsg.messageID.description];
        [msgEntity setIsLoaded:[NSNumber numberWithBool:chatMsg.isLoaded]];
        [msgEntity setMsgDirection:[NSNumber numberWithInteger:chatMsg.bubbleMessageType]];
        msgEntity.msgMediaType = [NSNumber numberWithInteger:chatMsg.messageMediaType];
        if (![chatMsg.text isEmptyString]) {
            [msgEntity setTextContent:chatMsg.text];
        }
        [msgEntity setTimestamp:[NSNumber numberWithDouble:[chatMsg.timestamp timeIntervalSince1970]]];
        [msgEntity setSended:[NSNumber numberWithBool:chatMsg.sended]];
        [msgEntity setReaded:[NSNumber numberWithBool:chatMsg.isRead]];
        if (chatMsg.voicePath && ![chatMsg.voicePath isEmptyString]) {
            [msgEntity setAudioPath:chatMsg.voicePath];
        }
        if (chatMsg.voiceDuration && ![chatMsg.voiceDuration isEmptyString]) {
            // 语音时长
            NSData *duration = [NSJSONSerialization dataWithJSONObject:@{ kVoiceDuration : chatMsg.voiceDuration } options:NSJSONWritingPrettyPrinted error:nil];
            msgEntity.extContent = duration;
        }
    }
    if (chatMsg.sender) {
        [msgEntity setSenderID:chatMsg.senderID];
        [msgEntity setSenderName:chatMsg.sender];
    }
    NSError *error = nil;
    if ([[self managedObjectContext] save:&error] == NO) {
        *err = error;
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    
    return msgEntity;
}

- (YYMessageEntity *)fetchMessageEntityMsgID:(NSString *)msgID error:(NSError **)err {
    if ([msgID isEmptyString]) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{ NSLocalizedDescriptionKey : @"message id param can not be null"}];
        
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"msgID == %@", msgID]];
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
    YYMessageEntity *msgEntity = [result lastObject];
    
    return msgEntity;
}

- (NSInteger)fetchUnreadMsg:(NSString *)convID error:(NSError *__autoreleasing *)err {
    if (!convID) {
        return 0;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntityName];
    [request setPredicate:[NSPredicate predicateWithFormat:@"readed == 0 && conversationID == %@", convID]];
    NSError *error;
    NSInteger count = [_managedObjectContext executeFetchRequest:request error:&error].count;
    return count;
}

- (YYMessageEntity *)updateMsgEntityReaded:(NSString *)msgID error:(NSError *__autoreleasing *)err {
    YYMessageEntity *entity = [self fetchMessageEntityMsgID:msgID error:err];
    if (entity) {
        entity.readed = [NSNumber numberWithBool:YES];
        NSError *error = nil;
        if ([[self managedObjectContext] save:&error] == NO) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
    return entity;
}

- (void)updateAllMsgToReaded:(NSString *)convID error:(NSError *__autoreleasing *)err {
    if (convID) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kMessageEntityName];
        [request setPredicate:[NSPredicate predicateWithFormat:@"readed == 0 && conversationID == %@", convID]];
        NSError *error = nil;
        NSMutableArray *result = [NSMutableArray arrayWithArray:[_managedObjectContext executeFetchRequest:request error:&error]];
        for (YYMessageEntity *msg in result) {
            if (msg) {
                msg.readed = [NSNumber numberWithBool:YES];
            }
        }
        if ([[self managedObjectContext] save:&error] == NO) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

- (YYMessageEntity *)updateMsgEntityLoadedWithMsgID:(NSString *)msgID error:(NSError *__autoreleasing *)err {
    YYMessageEntity *entity = [self fetchMessageEntityMsgID:msgID error:err];
    if (entity) {
        
        entity.isLoaded = [NSNumber numberWithBool:YES];
        NSError *error = nil;
        if ([[self managedObjectContext] save:&error] == NO) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
    }
    return entity;
}

- (YYMessageEntity *)updateMessageServerID:(NSString *)serverID msgID:(NSString *)msgID error:(NSError **)err {
    YYMessageEntity *entity = [self fetchMessageEntityMsgID:msgID error:err];
    if (entity) {
        
        if (serverID) {
            entity.serverMsgID = serverID;
            NSError *error = nil;
            if ([[self managedObjectContext] save:&error] == NO) {
                *err = error;
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
            }
            
        }
        
    }
    return entity;
}

- (YYMessageEntity *)updateMessageFileID:(NSString *)fileID msgID:(NSString *)msgID error:(NSError **)err {
    YYMessageEntity *entity = [self fetchMessageEntityMsgID:msgID error:err];
    if (entity && fileID) {
        entity.fileID = fileID;
        NSError *error = nil;
        if ([[self managedObjectContext] save:&error] == NO) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
        
    }
    return entity;
}

- (void)deleteMessageEntityMsgID:(NSString *)msgID error:(NSError **)err {
    YYMessageEntity *msgEntity = [self fetchMessageEntityMsgID:msgID error:err];
    if (msgEntity) {
        // 删除
        [_managedObjectContext deleteObject:msgEntity];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            *err = error;
            NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

- (void)clearAllMessageEntitiesConvID:(NSString *)convID error:(NSError **)err {
    NSMutableArray *allMesg = [NSMutableArray arrayWithArray:[self getAllMessageEntityConversationID:convID offset:-1 error:err]];
    for (NSInteger i = allMesg.count - 1; i >= 0; i--) {
        [_managedObjectContext deleteObject:allMesg[i]];
    }
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        *err = error;
        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
}

#pragma mark - UserEntity

- (YYUserEntity *)createUserEntityUserModel:(YYUserModel *)userModel error:(NSError *__autoreleasing *)err {
    if (!userModel) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{NSLocalizedDescriptionKey : @"params are illegal"}];
        return nil;
    }
    YYUserEntity *entity = [self fetchUserEntityWithUserID:userModel.userID error:err];
    if (!entity) {
        entity = [NSEntityDescription insertNewObjectForEntityForName:kUserEntityName inManagedObjectContext:_managedObjectContext];
    }
    if (userModel.userID) {
        entity.userid = userModel.userID;
    }
    if (userModel.userNickName) {
        entity.userName = userModel.userNickName;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        *err = error;
        NSLog(@"Error saving userentity context: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return entity;
}

- (YYUserEntity *)fetchUserEntityWithUserID:(NSString *)userID error:(NSError *__autoreleasing *)err {
    if ([userID isEmptyString]) {
        *err = [NSError errorWithDomain:kYYMediaCoreDataDoamin code:1000 userInfo:@{NSLocalizedDescriptionKey : @"params are illegal"}];
        return nil;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kUserEntityName];
    request.predicate = [NSPredicate predicateWithFormat:@"userid == %@", userID];
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:err];
    YYUserEntity *entity = [result lastObject];
    return entity;
}

- (void)deleteUserEntity:(NSString *)userID error:(NSError *__autoreleasing *)err {
    YYUserEntity *entity = [self fetchUserEntityWithUserID:userID error:err];
    if (entity) {
        [_managedObjectContext deleteObject:entity];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            *err = error;
            NSLog(@"Error delete userentity context: %@\n%@", [error localizedDescription], [error userInfo]);
        }
    }
}

@end
