//
//  GetmoneySecsscTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/17.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "GetmoneySecsscTableViewController.h"
#import "Utils.h"

#import "UIbuttonStyle.h"
@interface GetmoneySecsscTableViewController ()


@end

@implementation GetmoneySecsscTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//回退
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
