//
//  HintView.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/23.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "HintView.h"

@implementation HintView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
}
- (IBAction)cancelview:(UIButton *)sender {
    [self removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    if (!CGRectContainsPoint(self.image.frame, point)) {
        [self removeFromSuperview];
    }
}
@end
