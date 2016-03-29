//
//  AppDelegate.m
//  车主省钱宝
//
//  Created by chenghao on 15/1/29.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "AppDelegate.h"
#import "BPush.h"
#import "JSONKit.h"
#import "OpenUDID.h"
#import "BaiduMobStat.h"
#import <AdSupport/ASIdentifierManager.h>


@interface AppDelegate ()

@end

@implementation AppDelegate
//程序错误转码
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }
    //让启动画面显示久一点
    [NSThread sleepForTimeInterval:2.0];
    self.carlist = [NSMutableArray array];
    
    //集成百度推送
    [BPush setupChannel:launchOptions];
    [BPush setDelegate:self];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //[application setApplicationIconBadgeNumber:0];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
    {
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert
         | UIRemoteNotificationTypeBadge
         | UIRemoteNotificationTypeSound];
    }
    
    UIRemoteNotificationType types;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    }
    else
    {
        types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }
    NSString* tongzhiID = [NSString stringWithFormat:@"%d",types];

    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    [userinfo setObject:tongzhiID forKey:@"tongzhiID"];

    [userinfo synchronize];
    
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    //集成百度统计
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = YES;
    statTracker.logStrategy = BaiduMobStatLogStrategyCustom;
    statTracker.logSendInterval = 1;
    statTracker.logSendWifiOnly = YES;
    statTracker.sessionResumeInterval = 30;
    statTracker.shortAppVersion = nowVersion;
    statTracker.enableDebugOn = NO;
    [statTracker startWithAppId:@"75fc590556"];
    
    //sharesdk分享
    [self sharesdk];
    // Override point for customization after application launch.
    return YES;
}
-(void)sharesdk{
    [ShareSDK registerApp:@"62c48e5b8a62"];//字符串api20为您的ShareSDK的AppKey
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台
    [ShareSDK  connectSinaWeiboWithAppKey:@"568898243"
                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                              redirectUri:@"http://www.sharesdk.cn"
                              weiboSDKCls:[WeiboSDK class]];
    //添加QQ应用  注册网址  http://open.qq.com/
    [ShareSDK connectQQWithQZoneAppKey:@"1103597174"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    //添加微信应用 注册网址 http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wx81ebddff5ee2c5e9"   //微信APPID
                           appSecret:@"82f9a57ab6d768871bcbda643f189698"  //微信APPSecret
                           wechatCls:[WXApi class]];
    
    
}
//sharesdk分享
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}




- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    
    [BPush registerDeviceToken: deviceToken];
    NSString *devicetoken = [[[[deviceToken description]
                               
                               stringByReplacingOccurrencesOfString:@"<" withString:@""]
                              
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             
                             stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    NSString* baiduchannelid = [BPush getChannelId];
    NSString* baiduappid = [BPush getAppId];
    NSString* baiduuserid = [BPush getUserId];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    [userinfo setObject:devicetoken forKey:@"devicetoken"];
    [userinfo setObject:baiduchannelid forKey:@"baiduchannelid"];
    [userinfo setObject:baiduappid forKey:@"baiduappid"];
    [userinfo setObject:baiduuserid forKey:@"baiduuserid"];
    [userinfo synchronize];
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}
// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    
    NSUserDefaults* res = [NSUserDefaults standardUserDefaults];
    if ([BPushRequestMethod_Bind isEqualToString:method]) {
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        
        if (returnCode == BPushErrorCode_Success) {
            // 在内存中备份，以便短时间内进入可以看到这些值，而不需要重新bind
            self.appId = appid;
            self.channelId = channelid;
            self.userId = userid;
        }
    } else if ([BPushRequestMethod_Unbind isEqualToString:method]) {
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if (returnCode == BPushErrorCode_Success) {
            
        }
    }
    
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Receive Notify: %@", [userInfo JSONString]);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@", alert]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [application setApplicationIconBadgeNumber:0];
    
    [BPush handleNotification:userInfo];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "cn.ebaochina._____" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"_____" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"_____.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
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
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
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

@end
