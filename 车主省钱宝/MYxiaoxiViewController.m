//
//  MYxiaoxiViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/15.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MYxiaoxiViewController.h"
#import "MYMessageinfoViewController.h"
#import "AccountNoticeTableViewController.h"
#import "SystemNoticeTableViewController.h"
@interface MYxiaoxiViewController ()
@property (strong, nonatomic) MYMessageinfoViewController *pagesContainer;

@end

@implementation MYxiaoxiViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pagesContainer = [[MYMessageinfoViewController alloc] init];
    [self.pagesContainer willMoveToParentViewController:self];
    self.pagesContainer.view.frame = CGRectMake(self.view.frame.origin.x, 64, self.view.bounds.size.width, self.view.frame.size.height);
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    [self.pagesContainer.view setBackgroundColor:[UIColor whiteColor]];
    [self.pagesContainer didMoveToParentViewController:self];
    self.pagesContainer.pageIndicatorColor = [UIColor colorWithRed:251.0/255 green:88.0/255 blue:88.0/255 alpha:1];
    
    
    AccountNoticeTableViewController *accountvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"account"];
    
    accountvc.title = @"账户通知";
    
    SystemNoticeTableViewController *systemvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"system"];
    systemvc.title = @"系统通知";
    
    self.pagesContainer.viewControllers = @[accountvc,systemvc];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
