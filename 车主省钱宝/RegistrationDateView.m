//
//  RegistrationDateView.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/24.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "RegistrationDateView.h"
#import "Utils.h"
@implementation RegistrationDateView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    NSDate *today = [NSDate date];
    self.timepicker.maximumDate = today;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
}
- (IBAction)cancel:(UIButton *)sender {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (IBAction)save:(UIButton *)sender {
    NSDate *selected = [self.timepicker date];
    NSString* date = [self stringFromFomate:selected formate:@"yyyy-MM-dd"];
    [self.delegate RegistrationDateViewMenumehod:date];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSString *str = [formatter stringFromDate:date];
    return str;
}
@end
