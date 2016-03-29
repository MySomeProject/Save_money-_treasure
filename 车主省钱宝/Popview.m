//
//  Popview.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/18.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "Popview.h"
#import "Utils.h"
@implementation Popview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)addpopview:(UIView*)view andtitle:(NSString*)title{
    view.frame = CGRectMake(Screen.bounds.size.width/2-Screen.bounds.size.width/2.5/2, Screen.bounds.size.height/3, Screen.bounds.size.width/2.5, Screen.bounds.size.width/10);
    [self.title setText:title];
    self.layer.shadowColor= [UIColor blackColor].CGColor;
    self.layer.shadowOffset=CGSizeMake(0,0);
    self.layer.shadowOpacity=0.5;
    self.layer.shadowRadius=5.0;
    self.layer.cornerRadius = 8.0;

}
-(void)cancelpopview{

    [UIView animateWithDuration:0.3 // 动画时长
                          delay:1.0 // 动画延迟
                        options:UIViewAnimationOptionTransitionCurlUp // 动画过渡效果
                     animations:^{
                         // code...
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         // 动画完成后执行
                         // code...
                        [self removeFromSuperview];
                     }];
}
@end
