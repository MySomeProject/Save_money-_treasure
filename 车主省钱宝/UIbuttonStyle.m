//
//  UIbuttonStyle.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/23.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "UIbuttonStyle.h"

@implementation UIbuttonStyle
+(void)UIbuttonStyleNO:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [sender.layer setBorderWidth:0.5]; //边框宽度
    [sender.layer setBorderColor:[UIColor colorWithRed:242.0/255 green:88.0/255 blue:88.0/255 alpha:1].CGColor];//边框颜色
    [sender setTitleColor:[UIColor colorWithRed:242.0/255 green:88.0/255 blue:88.0/255 alpha:1] forState:UIControlStateNormal];
}
+(void)UIbuttonStyleDI:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [sender.layer setBorderWidth:0.5]; //边框宽度
    [sender.layer setBorderColor:[UIColor lightGrayColor].CGColor];//边框颜色
    [sender setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}
+(void)UIbuttonStyleBig:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:1.0]; //设置矩形四个圆角半径
    [sender setBackgroundColor:[UIColor colorWithRed:242.0/255 green:88.0/255 blue:88.0/255 alpha:1]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
+(void)UIbuttonStyleBigDI:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:1.0]; //设置矩形四个圆角半径
    [sender setBackgroundColor:[UIColor lightGrayColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
+(void)UIbuttonStyleNoW:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [sender.layer setBorderWidth:0.5]; //边框宽度
    [sender.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
+(void)UIbuttonStyleBlue:(UIButton*)sender{
    [sender.layer setMasksToBounds:YES];
    [sender.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    [sender.layer setBorderWidth:0.5]; //边框宽度
    [sender.layer setBorderColor:[UIColor colorWithRed:0/255 green:169/255 blue:255/255 alpha:1].CGColor];//边框颜色
    [sender setTitleColor:[UIColor colorWithRed:0/255 green:169/255 blue:255/255 alpha:1] forState:UIControlStateNormal];
}
@end
