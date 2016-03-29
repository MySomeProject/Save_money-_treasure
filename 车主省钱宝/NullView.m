//
//  NullView.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/15.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "NullView.h"
#import "Utils.h"
#import "UIbuttonStyle.h"
@implementation NullView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [self.but.layer setMasksToBounds:YES];
    [self.but.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [self.but.layer setBorderWidth:0.5]; //边框宽度
    [self.but.layer setBorderColor:[UIColor lightGrayColor].CGColor];//边框颜色
    [self.but setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}
-(void)addpopview:(UIView*)view andtitle:(NSString*)title andbutitle:(NSString*)buttile{
    view.frame = Screen.bounds;
    [self.info setText:title];
    [self.but setTitle:buttile forState:UIControlStateNormal];
    
}
- (IBAction)gto:(UIButton *)sender {
    [self.delegate NullViewMenumehod];
}
@end
