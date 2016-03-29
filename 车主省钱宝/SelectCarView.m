//
//  SelectCarView.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/7.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "SelectCarView.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "MainInfo.h"
@implementation SelectCarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return [appdelegate.carlist count] - 1;
}
-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0) {
        MainInfo* m = appdelegate.carlist[row];
        return m.carnumber;
    }else{
        return 0;
    }

}
- (IBAction)save:(UIButton *)sender {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0){
        MainInfo* m = appdelegate.carlist[[self.Picke selectedRowInComponent:0]];
        [self.delegate SelectCarViewMenumehod:[NSString stringWithFormat:@"%@%@-%@",m.carnumber,m.carid,m.totleredpaper]];
    }

    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
@end
