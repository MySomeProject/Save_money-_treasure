//
//  Userinfo.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/7.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "Userinfo.h"
static Userinfo *_userinfo;
@implementation Userinfo
+(Userinfo *)shareUserinfo{
    if (!_userinfo) {
        _userinfo = [[Userinfo alloc]init];
    }
    return _userinfo;
}
@end
