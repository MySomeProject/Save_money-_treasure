//
//  MYMessageviewbar.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
@class MYMessageviewbar;

@protocol MYMessageviewbarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(MYMessageviewbar *)bar;

@end

@interface MYMessageviewbar : UIView
@property (strong, nonatomic) NSArray *itemTitles;
@property (strong, nonatomic) UIFont *font;
@property (readonly, strong, nonatomic) NSArray *itemViews;
@property (readonly, strong, nonatomic) UIScrollView *scrollView;
@property (weak, nonatomic) id<MYMessageviewbarDelegate> delegate;

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;
@end
