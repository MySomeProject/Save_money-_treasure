//
//  PayView.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/31.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "PayView.h"
#import "UIbuttonStyle.h"
@implementation PayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [UIbuttonStyle UIbuttonStyleDI:self.cancel];
    [UIbuttonStyle UIbuttonStyleNO:self.pay];
}
- (IBAction)cancel:(UIButton *)sender {
    [self.delegate PayViewcancelMenumehod];
}
- (IBAction)pay:(UIButton *)sender {
    [self.delegate PayViewpayMenumehod];
}
@end
