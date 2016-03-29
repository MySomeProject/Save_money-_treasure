//
//  MYMessageview.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MYMessageview.h"

@implementation MYMessageview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        _color = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Public

- (void)setColor:(UIColor *)color
{
    if (![_color isEqual:color]) {
        _color = color;
        [self setNeedsDisplay];//这个方法会异步自动调用下面drawRect放吧
        
    }
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillRect(context, rect);
    
}

@end
