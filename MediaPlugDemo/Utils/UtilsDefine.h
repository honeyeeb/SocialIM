//
//  UtilsDefine.h
//  YouYunMediaDemo
//
//  Created by Frederic on 16/5/31.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#ifndef UtilsDefine_h
#define UtilsDefine_h

#ifndef WEAKSELF
#define WEAKSELF __weak __typeof(self) weakSelf = self;
#endif

/**
 *  聊天目标类型
 */
typedef NS_ENUM(NSInteger, YYChatTargetType) {
    /**
     *  单人聊天
     */
    YYChatTargetTypeSingle = 0,
    /**
     *  群组聊天
     */
    YYChatTargetTypeGroup,
};

/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger, YYMessageMediaType) {
    /**
     *  文本
     */
    YYMessageMediaTypeText = 0,
    /**
     *  图片
     */
    YYMessageMediaTypePhoto = 1,
    /**
     *  视频
     */
    YYMessageMediaTypeVideo = 2,
    /**
     *  音频
     */
    YYMessageMediaTypeVoice = 3,
    /**
     *  表情
     */
    YYMessageMediaTypeEmotion = 4,
    /**
     *  位置
     */
    YYMessageMediaTypeLocalPosition = 5,
};

/**
 *  群组成员角色
 */
typedef NS_ENUM(NSInteger, YYGroupMemberRoleType) {
    /**
     *  默认
     */
    YYGroupMemberRoleTypeDefault    = 0,
    /**
     *  普通成员
     */
    YYGroupMemberRoleTypeCommon,
    /**
     *  VIP
     */
    YYGroupMemberRoleTypeVIP,
    /**
     *  管理员
     */
    YYGroupMemberRoleTypeAdmin,
    /**
     *  群主
     */
    YYGroupMemberRoleTypeRoot,
    
};


/**
 *  屏幕宽度
 */
#define  SCREEN_WIDTH                 [UIScreen mainScreen].bounds.size.width
/**
 *  屏幕高度
 */
#define  SCREEN_HEIGHT                [UIScreen mainScreen].bounds.size.height


#define kVoiceDuration                  @"duration"

#define kUserNickName                   @"nickname"

typedef void(^onAppServiceBlock)(NSInteger tag, NSDictionary* jsonRet, NSError* err);
typedef void(^onMsgFileProgressBlock)(NSUInteger receivedSize, long long expectedSize);

#endif /* UtilsDefine_h */
