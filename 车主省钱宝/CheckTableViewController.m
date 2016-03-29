//
//  CheckTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/21.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CheckTableViewController.h"
#import "AppDelegate.h"
#import "MainInfo.h"
#import "FcheckTableViewController.h"
#import "Utils.h"
#import "CheckTableViewCell.h"
@interface CheckTableViewController ()

@end

@implementation CheckTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appdelegate.carlist.count - 1;
    
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    MainInfo* m = appdelegate.carlist[indexPath.row];
    // Configure the cell...
    NSString* carheard = [m.carnumber substringToIndex:2];
    NSString* carfoot = [m.carnumber substringFromIndex:2];
    [cell.carnumber setText:[NSString stringWithFormat:@"%@•%@",carheard,carfoot]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    MainInfo* m = appdelegate.carlist[indexPath.row];
    [self performSegueWithIdentifier:@"Fcheckadd" sender:m.carnumber];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Fcheckadd"]) {
        FcheckTableViewController* fvc = segue.destinationViewController;
        fvc.carnumbertitle = sender;
    }
}


@end
