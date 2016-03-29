//
//  AppDelegate.h
//  车主省钱宝
//
//  Created by chenghao on 15/1/29.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//分享sdk
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (strong, nonatomic) NSString *appId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic)NSMutableArray* carlist;

@property (strong, nonatomic) NSString *totlepaper;

@end

