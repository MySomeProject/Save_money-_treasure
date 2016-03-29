//
//  StopSelectView.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/25.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol StopSelectViewdelegate <NSObject>

-(void)StopSelectViewMenumehod:(NSString*)text;

@end
@interface StopSelectView : UIView
@property(weak,nonatomic)id<StopSelectViewdelegate> delegate;
@end
