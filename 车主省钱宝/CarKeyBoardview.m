//
//  CarKeyBoardview.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CarKeyBoardview.h"
#import "Utils.h"
@implementation CarKeyBoardview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)addcarheard{
    NSArray* carheardarry = @[@"京",@"沪",@"津",@"渝",@"黑",@"吉",@"辽",@"蒙",@"冀",@"新",@"甘",@"青",@"陕",@"宁",@"豫",@"鲁",@"晋",@"皖",@"鄂",@"湘",@"苏",@"川",@"黔",@"滇",@"桂",@"藏",@"浙",@"赣",@"粤",@"闽",@"台",@"琼",@"港",@"澳",@"云",@"贵"];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    for (int i = 0; i<carheardarry.count; i++) {
        UIButton* carheard = [[UIButton alloc]initWithFrame:CGRectMake((i%9)*self.downview.frame.size.width/8+10, (i/9)*self.downview.frame.size.height/4+5 , self.downview.frame.size.width/9, self.downview.frame.size.height/6)];
        carheard.layer.shadowColor= [UIColor blackColor].CGColor;
        carheard.layer.shadowOffset=CGSizeMake(0,0);
        carheard.layer.shadowOpacity=0.7;
        carheard.layer.shadowRadius=1.0;
        carheard.layer.cornerRadius = 3.0;
        [carheard setTitle:carheardarry[i] forState:UIControlStateNormal];
        [carheard setBackgroundColor:[UIColor whiteColor]];
        [carheard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [carheard addTarget:self action:@selector(savetitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.downview addSubview:carheard];
    }
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
-(void)savetitle:(UIButton*)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, Screen.bounds.size.height, self.frame.size.width, self.frame.size.height);
        [self.delegate Menumehod:sender.titleLabel.text];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
@end
