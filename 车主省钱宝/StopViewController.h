//
//  StopViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZhongJinShu <NSObject>

-(void)chuanzhi:(NSString *)str;

@end

@interface StopViewController : UIViewController<UIAlertViewDelegate>

@property(nonatomic,copy)NSString* carnumber;
@property(nonatomic,copy)NSString* comefrom;
@property(nonatomic,copy)NSString* carid;
@property(nonatomic,copy)NSString* caridforhttp;

@property(nonatomic)id<ZhongJinShu> delegate123;


@end
