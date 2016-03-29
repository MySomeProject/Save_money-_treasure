//
//  MYMessageinfoViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MYMessageinfoViewController;

@protocol MYMessageinfoViewControllerDelegate <NSObject>
- (void)itemChangeFrom:(NSUInteger)oldIndex To:(NSUInteger)newIndex DAPagesContainer:(MYMessageinfoViewController *)container;
@end

@interface MYMessageinfoViewController : UIViewController

@property (strong, nonatomic) NSArray *viewControllers;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (assign, nonatomic) NSUInteger topBarHeight;
@property (strong, nonatomic) UIColor *pageIndicatorColor;
@property (assign, nonatomic) CGSize pageIndicatorViewSize;
@property (strong, nonatomic) UIColor *topBarBackgroundColor;
@property (strong, nonatomic) UIFont *topBarItemLabelsFont;
@property (strong, nonatomic) UIColor *pageItemsTitleColor;
@property (strong, nonatomic) UIColor *selectedPageItemColor;

@property (strong, nonatomic) UIColor *topBarItemsTitleColor;
@property (strong, nonatomic) UIColor *topBarItemsSelectedTitleColor;

@property (nonatomic, weak) id<MYMessageinfoViewControllerDelegate> delegate;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation;
@end
