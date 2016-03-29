//
//  Noweizhang.m
//  车主省钱宝
//
//  Created by chenghao on 15/6/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "Noweizhang.h"
#import "Utils.h"
@implementation Noweizhang

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)addpopview:(UIView*)view andtitle:(NSString*)title{
    view.frame = Screen.bounds;
    [self.info setText:title];
    
}
@end
