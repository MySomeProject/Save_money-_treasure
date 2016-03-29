//
//  MYMessageinfoViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MYMessageinfoViewController.h"
#import "MYMessageview.h"
#import "MYMessageviewbar.h"
#import "Messageinfo.h"
#import "RedPoint.h"

@interface MYMessageinfoViewController ()<MYMessageviewbarDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) MYMessageviewbar *topBar;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (weak,   nonatomic) UIScrollView *observingScrollView;
@property (strong, nonatomic) MYMessageview *pageIndicatorView;

@property(nonatomic,retain)UIImageView* borderView;

@property (assign, nonatomic) BOOL shouldObserveContentOffset;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;
- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;
@end

@implementation MYMessageinfoViewController


#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [self stopObservingContentOffset];
}

- (void)setUp
{
    _selectedIndex = 0;
    _topBarHeight = 40;
    //背景颜色
    _topBarBackgroundColor = [UIColor whiteColor];
    // 字号
    _topBarItemLabelsFont = [UIFont boldSystemFontOfSize:17];
    _pageIndicatorViewSize = CGSizeMake(60, 3.5f);
    
    _topBarItemsTitleColor = [UIColor darkGrayColor];
    _topBarItemsSelectedTitleColor = [UIColor colorWithRed:255/255 green:30/255 blue:0/255 alpha:1];
    
}


#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.shouldObserveContentOffset = YES;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                     self.topBarHeight,
                                                                     CGRectGetWidth(self.view.frame),
                                                                     CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    
    [self.view addSubview:self.scrollView];
    [self startObservingContentOffsetForScrollView:self.scrollView];
    
    self.topBar = [[MYMessageviewbar alloc] initWithFrame:CGRectMake(0.,
                                                                           0.,
                                                                           CGRectGetWidth(self.view.frame),
                                                                           self.topBarHeight)];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.delegate = self;
    [self.view addSubview:self.topBar];
    
    self.pageIndicatorView = [[MYMessageview alloc] initWithFrame:CGRectMake(0.,
                                                                                   self.topBarHeight,
                                                                                   self.pageIndicatorViewSize.width,
                                                                                   self.pageIndicatorViewSize.height)];
    // [self.pageIndicatorView setColor:_pageIndicatorColor];
    [self.view addSubview:self.pageIndicatorView];

    self.topBar.backgroundColor = self.pageIndicatorView.color = self.topBarBackgroundColor;
    
    RedPoint *share = [RedPoint shareRedPoint];
    
    //添加newpoint
    for (NSString *str  in share.AccountArray) {
        if ([str isEqualToString:@"0"]) {
            [self accountnotice];
            break;
        }
    }
    
    for (NSString *str in share.SystemArray) {
        if ([str isEqualToString:@"0"]) {
            [self systemnotice];
            break;
        }
    }
    
}

-(void)cancelimage:(UIView*)pointimage{
    pointimage.transform = CGAffineTransformMakeScale(1.0f, 1.0f);//将要显示的view按照正常比例显示出来
    [UIView animateWithDuration:1.0f animations:^
    {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];  //InOut 表示进入和出去时都启动动画
        pointimage.transform=CGAffineTransformMakeScale(0.01f, 0.01f);//先让要显示的view最小直至消失
    }completion:^(BOOL finished){
        [pointimage removeFromSuperview];
    }];
    
    
}
//账户通知红点
-(void)accountnotice{
    //加redPoint
    if (Screen.applicationFrame.size.width<=320) {
       CGFloat x = 2*Iphone5MessageItemsOffset;
            UIImageView* pointimage = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 10, 10)];
        pointimage.image = [UIImage imageNamed:@"PC-REDPOINT"];
        
        pointimage.tag = 1;
        
        [self.view addSubview:pointimage];
        
        RedPoint *share = [RedPoint shareRedPoint];
        BOOL flag = NO;
        for (NSString *str  in share.AccountArray) {
            if ([str isEqualToString:@"0"]) {
                flag =NO;
                break;
            }else{
                flag = YES;
            }
        }
        if (flag) {
            [self cancelimage:pointimage];
        }
        
        
        
    }else{
       CGFloat x = 2.5*MessageItemsOffset;
        UIImageView* pointimage = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 10, 10)];
        pointimage.image = [UIImage imageNamed:@"PC-REDPOINT"];
        
        pointimage.tag = 1;
        
        [self.view addSubview:pointimage];
        
        RedPoint *share = [RedPoint shareRedPoint];
        BOOL flag = NO;
        for (NSString *str  in share.AccountArray) {
            if ([str isEqualToString:@"0"]) {
                flag =NO;
                break;
            }else{
                flag = YES;
            }
        }
        if (flag) {
            [self cancelimage:pointimage];
        }

        
       // [self cancelimage:pointimage];
        

    }
}

//系统通知红点
-(void)systemnotice{
    //加redPoint
    if (Screen.applicationFrame.size.width<=320) {
        CGFloat x = 4.1*Iphone5MessageItemsOffset;
        UIImageView* pointimage = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 10, 10)];
        pointimage.image = [UIImage imageNamed:@"PC-REDPOINT"];
        pointimage.tag = 3;
        
        [self.view addSubview:pointimage];
        
        
    }else{
        CGFloat x = 4.6*MessageItemsOffset;
        UIImageView* pointimage = [[UIImageView alloc]initWithFrame:CGRectMake(x, 5, 10, 10)];
        pointimage.image = [UIImage imageNamed:@"PC-REDPOINT"];
        
        pointimage.tag = 3;
    
        [self.view addSubview:pointimage];
        

    }
}

- (void)viewDidUnload
{
    [self stopObservingContentOffset];
    self.scrollView = nil;
    self.topBar = nil;
    self.pageIndicatorView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutSubviews];
}

#pragma mark - Public

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    
    if (selectedIndex == _selectedIndex) {
        [previosSelectdItem setTitleColor:[UIColor colorWithRed:255/255 green:30/255 blue:0/255 alpha:1] forState:UIControlStateNormal];
        return;
    }
    
    if (self.delegate) {
        [self.delegate itemChangeFrom:self.selectedIndex To:selectedIndex DAPagesContainer:self];
    }
    
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    NSLog(@"nextSelectdItem%@",nextSelectdItem.titleLabel.text);
    if ([nextSelectdItem.titleLabel.text isEqualToString:@"系统通知"]){
        for (UIView* view in self.view.subviews) {
            if (view.tag == 3) {
               
//                [self cancelimage:view];
                RedPoint *share = [RedPoint shareRedPoint];
                BOOL flag = NO;
                for (NSString *str  in share.SystemArray) {
                    if ([str isEqualToString:@"0"]) {
                        flag =NO;
                        break;
                    }else{
                        flag = YES;
                    }
                }
                if (flag) {
                    [self cancelimage:view];
                }

                
            }
        }
    }
    
    if (abs(self.selectedIndex - selectedIndex) <= 1) {
        [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
        if (selectedIndex == _selectedIndex) {
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        self.pageIndicatorView.center.y);
        }
        [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [previosSelectdItem setTitleColor:_topBarItemsTitleColor forState:UIControlStateNormal];
             [nextSelectdItem setTitleColor:_topBarItemsSelectedTitleColor forState:UIControlStateNormal];
             
             
         } completion:nil];
    } else {
        // This means we should "jump" over at least one view controller
        self.shouldObserveContentOffset = NO;
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);
        UIViewController *leftViewController = self.viewControllers[MIN(self.selectedIndex, selectedIndex)];
        UIViewController *rightViewController = self.viewControllers[MAX(self.selectedIndex, selectedIndex)];
        leftViewController.view.frame = CGRectMake(0., 0., self.scrollWidth, self.scrollHeight);
        rightViewController.view.frame = CGRectMake(self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollWidth, self.scrollHeight);
        
        CGPoint targetOffset;
        if (scrollingRight) {
            self.scrollView.contentOffset = CGPointZero;
            targetOffset = CGPointMake(self.scrollWidth, 0.);
        } else {
            self.scrollView.contentOffset = CGPointMake(self.scrollWidth, 0.);
            targetOffset = CGPointZero;
            
        }
        [self.scrollView setContentOffset:targetOffset animated:YES];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        self.pageIndicatorView.center.y);
            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
            [previosSelectdItem setTitleColor:_topBarItemsTitleColor forState:UIControlStateNormal];
            [nextSelectdItem setTitleColor:_topBarItemsSelectedTitleColor forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
                UIViewController *viewController = self.viewControllers[i];
                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
                [self.scrollView addSubview:viewController.view];
            }
            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
            self.scrollView.userInteractionEnabled = YES;
            self.shouldObserveContentOffset = YES;
        }];
    }
    _selectedIndex = selectedIndex;
}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setPageIndicatorViewSize:(CGSize)size
{
    if (!CGSizeEqualToSize(self.pageIndicatorView.frame.size, size)) {
        _pageIndicatorViewSize = size;
        [self layoutSubviews];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    _topBarBackgroundColor = topBarBackgroundColor;
    self.topBar.backgroundColor = topBarBackgroundColor;
    self.pageIndicatorView.color = topBarBackgroundColor;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setPageIndicatorColor:(UIColor *)aPageIndicatorColor
{
    if (_pageIndicatorColor != aPageIndicatorColor) {
        _pageIndicatorColor = aPageIndicatorColor;
        
        [self.pageIndicatorView setColor:_pageIndicatorColor];
    }
}


- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        for (UIViewController *viewController in viewControllers) {
            [viewController willMoveToParentViewController:self];
            viewController.view.frame = CGRectMake(0., 0., CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            [viewController didMoveToParentViewController:self];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    self.pageIndicatorView.center.y);
    }
}

#pragma mark - Private

- (void)layoutSubviews
{
    self.topBar.frame = CGRectMake(0., 0., CGRectGetWidth(self.view.bounds), self.topBarHeight);
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    
    self.scrollView.contentSize = CGSizeMake(x, self.scrollHeight);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0.) animated:YES];
    
    self.pageIndicatorView.frame = CGRectMake(0.,
                                              self.topBarHeight,
                                              self.pageIndicatorViewSize.width+10,
                                              0.5);
    [self.pageIndicatorView setBackgroundColor:[UIColor colorWithRed:255/255 green:30/255 blue:0/255 alpha:1]];
    
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                self.pageIndicatorView.center.y);
    
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    self.scrollView.userInteractionEnabled = YES;
    
    //self.borderView.frame = CGRectMake(0.,self.topBarHeight ,CGRectGetWidth(self.view.bounds),1);
    
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - self.topBarHeight;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

#pragma mark - DAPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(MYMessageviewbar *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            
            
            
            
            //            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            //            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            //            [previosSelectedItem setTitleColor:_topBarItemsTitleColor forState:UIControlStateNormal];
            //            [nextSelectedItem setTitleColor:_topBarItemsSelectedTitleColor forState:UIControlStateNormal];
            
            
            
            
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            self.pageIndicatorView.center.y);
                
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                                            (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            self.pageIndicatorView.center.y);
            }
        }
    }
}


@end
