//
//  AppDelegate.m
//  YouYunMedia
//
//  Created by Frederic on 16/5/24.
//  Copyright © 2016年 YouYun. All rights reserved.
//

#import "AppDelegate.h"
#import "YYMediaSDKEngine.h"
#import "YYMediaCoreData.h"
#import "MediaPlusSDK+IM.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK setEnablePush:YES];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    // Fabric Crashlytics
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[YYMediaCoreData sharedInstance]saveContext];
    application.applicationIconBadgeNumber = 0;
    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK socialSetUnreadNumber:0 withTag:[YYMediaSDKEngine sharedInstance].getConnectTag error:nil];

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[YYMediaCoreData sharedInstance]saveContext];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
//    [[YYMediaSDKEngine sharedInstance].mediaPlusSDK setDeviceToken:deviceToken];
    [[YYMediaSDKEngine sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

@end
