//
//  Userinfo.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/7.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Userinfo : NSObject
+(Userinfo *)shareUserinfo;
@property(nonatomic,copy)NSString* userid;
@property(nonatomic,copy)NSString* userwallet;
@property(nonatomic,copy)NSString* userredpaper;
@end
