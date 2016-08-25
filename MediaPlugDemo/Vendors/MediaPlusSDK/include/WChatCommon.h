//
//  WChatCommon.h
//  WChat
//
//  Created by gaozhi,yongrong on 9/6/12.
//
//

#ifndef WChat_WChatCommon_h
#define WChat_WChatCommon_h

#define WChatErrorDomain @"WChatErrorDomain"

//sdk版本
#define WChatVersion @"3.9.0"

//平台切换宏
typedef NS_ENUM(NSInteger, WChatPlatform) {
    OnlinePlatform  = 1,    //线上平台
    TestPlatform    = 2,    //测试平台
};

//错误类型
typedef NS_ENUM(NSInteger, YYWChatError)
{
    WChatNoError               = 0,    // no error
    
    WChatBadParamError         = 11,   // bad param error
    WChatAuthError             = 12,   // auth error
    WChatNotRunningError       = 13,   // not running error
    WChatAlreadyLoginError     = 14,   // already login in another device
    WChatForceUpgradeError     = 15,   // force upgrade client
    WChatTokenExpiredError     = 16,   // weibo token Expired
    
    // file and directory
    WChatFileNotExistError     = 21,   // file not exist error
    WChatFileTooLargeError     = 22,   // file too large error: thumbnail is not more than 50K
    WChatGetFileError          = 23,   // get file error
    WChatNotDirectoryError     = 24,   // not directory error
    WChatFileOpenError         = 25,   // open file error
    
    // network
    WChatDisconnectError       = 31,   // disconnect error
    WChatTimeoutError          = 32,   // timedout error
    WChatReadTimeoutError      = 33,   // read timedout error
    WChatWriteTimeoutError     = 34,   // write timedout error
    WChatSocketConnectError    = 35,   // socket connect error
    
    //opensdk
    WChatRegisterError         = 41,   //请求注册失败
    
};

//消息类型
typedef NS_ENUM(NSInteger, YYWChatFileType)
{
    YYWChatFileTypeText      = 0x01,  //文本
    YYWChatFileTypeVoice     = 0x02,  //语音, 没有文件id
    YYWChatFileTypeVideo     = 0x03,  //视频
    YYWChatFileTypeImage     = 0x04,  //图片
    YYWChatFileTypeFile      = 0x05,  //文件
    
    YYWChatFileTypeOperation = 0x07,
    YYWChatFileTypeLocation  = 0x08,  // 位置
    YYWChatFileTypeProperty  = 0x09,  // to be deleted
    
    YYWChatFileTypeTextExt   = 0x0a,  // SDK文本扩展使用
    YYWChatFileTypeCustom    = 0x0b,  // 自定义消息
    
    YYWChatFileTypeHtml      = 0x10,
    YYWChatFileTypeMixed     = 0x11,  //JSON
    
    YYWChatFileTypeAudio     = 0x12,  //音频文件消息 有文件id
    
    YYWChatFileTypeSip       = 0x13,  //voip 单人电话
    YYWChatFileTypeConference= 0x14,  //接受电话会议邀请
    
    YYWChatFileTypeUnknown   = 0x0,   //未知操作
    
};
/**
 *  消息发送对象类型
 */
typedef NS_ENUM(NSInteger, WChatMsgTargetType) {
    WChatMsgTargetTypeServer        = 0,
    /**
     *  个人
     */
    WChatMsgTargetTypeSingle        = 1,
    /**
     *  群组
     */
    WChatMsgTargetTypeGroup         = 2,
    /**
     *  聊天室
     */
    WChatMsgTargetTypeChatRoom      = 3,
    
};

/**
 *  创建群组类型
 */
typedef NS_ENUM(NSInteger, WChatGroupCategary) {
    /**
     *  临时群组
     */
    WChatGroupCategaryTmp,
    /**
     *  私人群组
     */
    WChatGroupCategaryPersonal,
    /**
     *  公共群租
     */
    WChatGroupCategaryPublic,
    /**
     *  聊天室
     */
    WChatGroupCategaryChatRoom,
    
};

//小组操作类型
typedef NS_ENUM(NSInteger, WChatGroupOperationType) {
    AddMember       = 0x01, //添加组员
    RemoveMember    = 0x02, //移除组员
    QuitGroup       = 0x03, //推出小组
    
};//管理小组

//连接状态类型
typedef NS_ENUM(NSInteger, WChatConnectState) {
    Disconnected    = 1,    //未连接 (默认)
    Connected       = 2,    //已连接
    Receiving       = 3,    //正在获取消息
    Connecting      = 4,    //连接中
    SystemConfig    = 5,    //系统设置(服务器返回,需要客户端处理,如多设备登陆,强制升级)
    UnReconnect     = 6,    //不再重连
    
};//连接状态

//握手消息返回状态
typedef NS_ENUM(NSInteger, WChatHandShakeCode) {
    AlreadyLogin        = 600,  //已经在其他设备登陆
    ForceUpgrade        = 601,  //强制升级
    
};//握手状态

//notice消息类型
typedef NS_ENUM(NSInteger, WChatNoticeType) {
    Typeing         = 1,    //正在输入
    KickOff         = 2,    //踢人
    ResetRemind     = 100,  //重置提醒
    SetUnread       = 200,  //设置未读数
    DecrUnread      = 300,  //减掉未读数
    KickWeb         = 1000, //踢web客户端
    SyncSingleStatus= 1001, //同步个人消息未读状态
    SyncGroupStatus = 1002, //同步群消息未读状态
    
};//notice类型

//conference 电话会议 calback 类型
typedef NS_ENUM(NSInteger, cfcallbackType) {
    cfcallbackTypeNone              = 0,    //不是任何请求类型 用于默认设置
    cfcallbackTypeRoomRequest       = 1,    //请求房间
    cfcallbackTypeSendInvite        = 2,    //发送邀请
    cfcallbackReceiveInvite         = 3,    //收到他人的电话会议邀请
    cfcallbackTypeKick              = 4,    //踢人
    cfcallbackTypeMute              = 5,    //禁言
    cfcallbackTypeUnmute            = 6,    //解禁
    cfcallbackTypeFetch             = 7,    //获取加入电话会议的成员
    cfcallbackTypeState             = 8,    //收到的是状态通知
};

//conference 电话会议 状态变化通知 类型
typedef NS_ENUM(NSInteger, cfstateType) {
    cfstateTypeNone       = 0,    //没有状态变化 用于默认设置
    cfstateTypeJoin       = 1,    //有人加入
    cfstateTypeMute       = 2,    //有人被禁言
    cfstateTypeUnmute     = 3,    //有人被解禁
    cfstateTypeKick       = 4,    //有人被踢
    cfstateTypeLeft       = 5,    //有人离开
    cfstateTypeWillEnd    = 6,    //将要结束的通知
};
#endif
