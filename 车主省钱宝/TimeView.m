//
//  TimeView.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/23.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "TimeView.h"
#import "Utils.h"
@implementation TimeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    NSDate *today = [NSDate date];
    
    NSTimeInterval nexttimesec;
    
    NSString* year = [self stringFromFomate:today formate:@"yyyy"];
    
    if((([year intValue]%4==0)&&([year intValue]%100!=0))||([year intValue]%400==0)){
        
        nexttimesec = 366*24*60*60  + 8*60*60;
    }else{
        
        nexttimesec = 365*24*60*60  + 8*60*60;
    }
    NSDate *nexttimedate = [NSDate dateWithTimeIntervalSinceNow:nexttimesec];

    self.timepicker.minimumDate = today;
    self.timepicker.maximumDate = nexttimedate;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    
}
- (IBAction)cancel:(UIButton *)sender {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{

        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);

    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (IBAction)save:(UIButton *)sender {
    
    NSDate *selected = [self.timepicker date];
    NSString* date = [self stringFromFomate:selected formate:@"yyyy-MM-dd"];
    [self.delegate TimeViewMenumehod:date];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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
