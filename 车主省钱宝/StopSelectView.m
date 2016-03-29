//
//  StopSelectView.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/25.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "StopSelectView.h"
#import "Utils.h"
#import "MainInfo.h"
#import "AppDelegate.h"
#import "UIButton+cbut.h"
@implementation StopSelectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    self.backgroundColor = [UIColor lightGrayColor];
    
    self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UIScrollView *sc = [[UIScrollView alloc] init];
    if ((appdelegate.carlist.count*(Screen.bounds.size.width/8)+64)>=Screen.bounds.size.height) {
        sc.frame = CGRectMake(0, 0, Screen.bounds.size.width, Screen.bounds.size.height-64);
        
    }else{
        sc.frame = CGRectMake(0, 0, Screen.bounds.size.width, appdelegate.carlist.count*(Screen.bounds.size.width/8));
    }
    sc.showsHorizontalScrollIndicator = NO;
    sc.showsVerticalScrollIndicator = NO;
    for (int i = 0; i<appdelegate.carlist.count; i++) {
            MainInfo* m = appdelegate.carlist[i];
        UIButton* carbut = [[UIButton alloc]initWithFrame:CGRectMake(0, i*Screen.bounds.size.width/8, Screen.bounds.size.width, Screen.bounds.size.width/8-0.5)];
        [carbut setTitle:m.carnumber forState:UIControlStateNormal];
        carbut.carid = m.carid;
        carbut.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [carbut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [carbut addTarget:self action:@selector(selectsave:) forControlEvents:UIControlEventTouchUpInside];
        [sc addSubview:carbut];
    }
    sc.contentSize = CGSizeMake(Screen.bounds.size.width, (Screen.bounds.size.width/8)*appdelegate.carlist.count);
    [self addSubview:sc];
    
    
}
-(void)selectsave:(UIButton*)sender{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.delegate StopSelectViewMenumehod:[NSString stringWithFormat:@"%@-%@",sender.titleLabel.text,sender.carid]];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, -appdelegate.carlist.count*(Screen.bounds.size.width/8), Screen.bounds.size.width, appdelegate.carlist.count*(Screen.bounds.size.width/8));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
