//
//  MainInfo.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/12.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainInfo : NSObject
@property(nonatomic,copy)NSString* shouyi;
@property(nonatomic,copy)NSString* buttitle;
@property(nonatomic,copy)NSString* carnumber;
@property(nonatomic)BOOL frist;
@property(nonatomic,copy)NSString* totleredpaper;
@property(nonatomic,copy)NSString* carid;
@property(nonatomic,copy)NSString* uplabelinfo;

@property(nonatomic,assign)NSInteger tomorrowexpected;
@property(nonatomic,copy)NSString *yesterdayaverage;
@end
