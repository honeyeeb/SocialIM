//
//  MediaPlusSDK.h
//  MediaPlusSDK
//
//  Created by Frederic on 16/5/23.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WChatCommon.h"
#import "MediaPlusSDKDelegate.h"


@class WChatSDK;
@class MediaSDK;


/**
 *  主体功能:SDK生命周期、Push功能
 */
@interface MediaPlusSDK : NSObject


/**
 *  IM实例
 */
@property (nonatomic, strong, readonly) WChatSDK *sharedWChatSDK;
/**
 *  VoIP实例
 */
@property (nonatomic, strong, readonly) MediaSDK *sharedMediaSDK;

@property (nonatomic, weak) id<MediaPlusSDKDelegate> delegate;
/**
 *  SDK使用的文件存储路径
 */
@property (nonatomic, copy, readonly) NSString *cachePath;
/**
 *  是否登录成功
 */
@property (nonatomic, assign, readonly) BOOL isAuth;
/**
 *  授权成功后游云ID
 */
@property (nonatomic, copy, readonly) NSString *userID;


#pragma mark - lifetime

/**
 *  初始化单例
 *
 *  @return 单例生成的对象
 */
+ (MediaPlusSDK *)sharedInstance;

/**
 *  @brief 释放单例
 */
+ (void)purgeSharedInstance;


#pragma mark - login/logout

/**
 *  @method 初始化SDK，登录生产环境服务器
 *
 *  @param udid     用于标识用户、设备的UDID
 *  @param client   开发者后台获取到生产环境的clientID
 *  @param secret   开发者后台获取到生产环境的key(secret)
 *
 */
- (void)startWithUDID:(NSString *)udid
             clientID:(NSString *)client
               secret:(NSString *)secret;
/**
 *  @method 初始化SDK，登录开发环境服务器
 *
 *  @param udid     用于标识用户、设备的UDID
 *  @param client   开发者后台获取到开发环境的clientID
 *  @param secret   开发者后台获取到开发环境的key(secret)
 *
 */
- (void)testStartWithUDID:(NSString *)udid
                 clientID:(NSString *)client
                   secret:(NSString *)secret;

/*! @method
 *  退出登录
 *
 */
- (void)logout;

/**
 *  @brief 重新连接
 */
- (void)socialReconnect;

/**
 *  获取游云提供的UDID
 *
 *  @return UDID
 */
+ (NSString *)getUDID;

#pragma mark - push

/**
 *  设置是否适用APNs功能，默认不使用，初始化SDK之前调用
 *
 *  @param enable Y/N
 */
- (void)setEnablePush:(BOOL)enable;

/*! @method
 *  设置设备token。
 *
 *  @note 需要在UIApplicationDelegate的回调
 *   - (void)application:didRegisterForRemoteNotificationsWithDeviceToken:中调用。
 */
- (NSString *)setDeviceToken:(NSData *)deviceToken;

/*! @method
 *  当前设备注册推送. push时段，需要登录成功后才能有效注册push.
 *
 *  @param pushToken ios注册的推送token
 *  @param startTime push时段开始时间(0~24),默认0,  如: 开始时间为9,  结束时间为20, push时段从当天9 点到 当天  20点. 传-1 上次开始时间
 *  @param endTime   push时段结束时间(0~24),默认24, 如: 开始时间为20, 结束时间为9,  push时段从当天20点到 第二天 9点. 传-1 上次结束时间
 *  @param handler   回调block (是否操作成功, 如果错误则返回错误信息)
 *
 */
- (void)deviceRegisterPush:(NSString *)pushToken
             pushStartTime:(NSInteger)startTime
                   endTime:(NSInteger)endTime
         completionHandler:(void (^)(BOOL isRegister, NSError* requestError))handler;

/*! @method
 *  取消push服务.
 *
 *  @param handler 回调block (设备信息注册信息, 如果错误则返回错误信息)
 */
- (void)deviceUnRegisterPush:(void (^)(BOOL isUnRegister, NSError* requestError))handler;

/*! @method
 *  获取设备信息.
 *
 *  @param handler 回调block (设备信息注册信息, 如果错误则返回错误信息)
 */
- (void)deviceInfoWithCompletionHandler:(void (^)(NSDictionary *deviceInfo, NSError* requestError))handler;


@end

