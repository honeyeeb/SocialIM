//
//  YYMediaSDKEngine.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/5/30.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MediaPlusSDK.h"
#import "YYUserModel.h"



@interface YYMediaSDKEngine : NSObject<MediaPlusSDKDelegate>

/**
 *  游云SDK
 */
@property (nonatomic, strong) MediaPlusSDK * mediaPlusSDK;
/**
 *  用户基本信息
 */
@property (nonatomic, strong, readonly) YYUserModel *userModel;
/**
 *  设备推送Token
 */
@property (nonatomic, copy, readonly) NSString *deviceToken;


+ (YYMediaSDKEngine *)sharedInstance;

+ (NSString *)hostURL;

/**
 *  授权登录
 */
- (void)signin;
/**
 *  标记
 *
 *  @return 标记值
 */
- (NSInteger)getConnectTag;


- (void)addNoTagMediaPlusDelegate:(id)delegate;
- (void)removeNoTagMediaPlusDelegate:(id)delegate;

- (void)addAppServiceBlock:(onAppServiceBlock)block tag:(NSInteger)tag;
- (void)removeAppServiceTag:(NSInteger)tag;

- (void)addFileProgressBlock:(onMsgFileProgressBlock)block tag:(NSInteger)tag;
- (void)removeFileProgressTag:(NSInteger)tag;

- (NSString *)getImgCachePath;

/**
 *  设置推送Token
 *
 *  @param token App下发的token
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)token;

/**
 *  异步短连请求
 *
 *  @param method     POST/GET
 *  @param url        短链接URL
 *  @param params     参数(para1=%@&param2=%d)
 *  @param callbackId 回调ID
 *  @param timeout    超时时间
 *  @param handler    回调结果
 */
- (void)socialAsyncRequest:(NSString*)method
                       url:(NSString *)url
                    params:(NSString *)params
                callbackId:(NSInteger)callbackId
                   timeout:(NSTimeInterval)timeout
                completion:(void (^)(NSDictionary *json, NSError *error))handler;

@end
