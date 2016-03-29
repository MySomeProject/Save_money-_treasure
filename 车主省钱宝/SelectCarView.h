//
//  SelectCarView.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/7.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectCarViewdelegate <NSObject>

-(void)SelectCarViewMenumehod:(NSString*)text;

@end

@interface SelectCarView : UIView
@property (weak, nonatomic) IBOutlet UIPickerView *Picke;
@property(weak,nonatomic)id<SelectCarViewdelegate> delegate;
@end
