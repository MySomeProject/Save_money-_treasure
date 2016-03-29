//
//  MYMessageviewbar.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MYMessageviewbar.h"
@interface MYMessageviewbar ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *itemViews;

- (void)layoutItemViews;

@end
@implementation MYMessageviewbar

CGFloat const DAPagesContainerTopBarItemViewWidth = 80.;
CGFloat const DAPagesContainerTopBarItemsOffset = 28.;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.font = [UIFont systemFontOfSize:17];
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

#pragma mark * Overwritten setters

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = itemTitles;
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemView];
            [itemView setTitle:itemTitles[i] forState:UIControlStateNormal];
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    if (![_font isEqual:font]) {
        _font = font;
        for (UIButton *itemView in self.itemViews) {
            [itemView.titleLabel setFont:font];
        }
    }
}

#pragma mark - Private

- (UIButton *)addItemView
{
    CGRect frame = CGRectMake(0., 0., DAPagesContainerTopBarItemViewWidth, CGRectGetHeight(self.frame));
    UIButton *itemView = [[UIButton alloc] initWithFrame:frame];
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = self.font;
    [itemView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.scrollView addSubview:itemView];

    return itemView;
}

- (void)itemViewTapped:(UIButton *)sender
{
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = MessageItemsOffset;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        CGFloat width = [self.itemTitles[i] sizeWithFont:self.font].width;
         //CGFloat width = Screen.bounds.size.width/self.itemTitles.count;
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake(x, 0., width, CGRectGetHeight(self.frame));
        x += width + MessageItemsOffset;
        
    }
    self.scrollView.contentSize = CGSizeMake(x, CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
    if (CGRectGetWidth(self.frame) > x) {
        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
        frame.size.width = x;
    } else {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}


@end
