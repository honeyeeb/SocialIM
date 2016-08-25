# 游云 iOS MediaPlusSDK 开发指南

## 简介

游云通讯VoIP

## 集成说明

在使用`MediaPlusSDK`之前，请前往 [官方网站](http://www.17youyun.com) 注册开发者帐号。注册时，您需要提供真实的邮箱和手机号，以方便我们向您发送重要通知并在紧急时刻能够联系到您。如果您没有提供正确可用的邮箱和手机号，我们随时可能关闭您的应用。

注册了开发者账号之后，在进行开发 App 之前，您需要请前往 [开发者控制台](http://www.17youyun.com) 创建应用。您创建完应用之后，在您的应用中，会自动创建两套的环境，即：开发环境和生产环境。创建应用成功后会生成对应开发环境的App唯一的 `ClientID`和 `Secret`。

### 包含文件

- include/MediaPlusSDK.h
- include/MediaPlusSDK+IM.h
- include/MediaPlusSDK+VoIP.h
- include/MediaPlusSDKDelegate.h
- include/WChatCommon.h
- include/public.der
- include/Resource/hold.wav // 等待提示音
- include/Resource/msg.caf // 提醒
- include/Resource/msg.wav // 提醒
- include/Resource/ring.caf // 来电
- include/Resource/ring.wav // 来电
- include/Resource/ringback.wav // 播出等待提示音
- libMediaPlusSDK.a

### 要求

- iOS 7.0 +

- 依赖库

  如果您使用的是 Xcode 6.x 版本，则需要将上面的动态库 *.tbd 的后缀改为 *.dylib。

  - Security.framework
  - AVFoundation.framework
  - CoreVideo.framework
  - CoreMedia.framework
  - libresolv.tbd
  - libsqlite3.tbd
  - CoreTelephony.framework
  - QuartzCore.framework
  - OpenGLES.framework
  - CoreGraphics.framework
  - CFNetwork.framework
  - SystemConfiguration.framework
  - AudioToolbox.framework
  - MediaPlayer.framework
  - UIKit.framework
  - Foundation.framework

- 在 `Xcode` 选中工程，在 `Build Settings` 中搜索 `Other Linker Flags`，增加 `-ObjC` 链接选项。

- 支持HTTP

  iOS 9 中，Apple 引入了新特性 App Transport Security (ATS)，默认要求 App 必须使用 https 协议。详情：[What's New in iOS 9](https://developer.apple.com/library/prerelease/ios/releasenotes/General/WhatsNewIniOS/Articles/iOS9.html#//apple_ref/doc/uid/TP40016198-DontLinkElementID_13)。SDK 在 iOS9 上需要使用 HTTP，您需要设置在 App 中使用 HTTP。在 App 的 *Info.plist 中添加 NSAppTransportSecurity 类型Dictionary。在 NSAppTransportSecurity 下添加 NSAllowsArbitraryLoads 类型 Boolean，值设为 YES。

- Enable Bitcode -> NO

# 接口调用

