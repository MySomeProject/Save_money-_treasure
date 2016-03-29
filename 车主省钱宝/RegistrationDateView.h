//
//  RegistrationDateView.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/24.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RegistrationDateViewdelegate <NSObject>

-(void)RegistrationDateViewMenumehod:(NSString*)text;

@end
@interface RegistrationDateView : UIView
@property(weak,nonatomic)id<RegistrationDateViewdelegate> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *timepicker;
@end
