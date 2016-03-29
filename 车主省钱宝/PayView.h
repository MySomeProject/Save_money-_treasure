//
//  PayView.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/31.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PayViewdelegate <NSObject>

-(void)PayViewcancelMenumehod;
-(void)PayViewpayMenumehod;

@end
@interface PayView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *pay;
@property(weak,nonatomic)id<PayViewdelegate> delegate;
@end
