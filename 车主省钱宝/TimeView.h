//
//  TimeView.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/23.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TimeViewdelegate <NSObject>

-(void)TimeViewMenumehod:(NSString*)text;

@end
@interface TimeView : UIView
@property(weak,nonatomic)id<TimeViewdelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *timepicker;
@end
