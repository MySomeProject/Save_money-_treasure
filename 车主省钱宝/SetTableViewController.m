//
//  SetTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/2/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "SetTableViewController.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "DLYTableViewController.h"
#import "UIbuttonStyle.h"
@interface SetTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *getoutbutton;

@end

@implementation SetTableViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [UIbuttonStyle UIbuttonStyleBig:self.getoutbutton];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]) {
        self.getoutbutton.hidden = NO;
    }else{
        self.getoutbutton.hidden = YES;
    }

}



- (IBAction)getout:(UIButton *)sender {
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]) {
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"退出登录",@"loginout", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"logintoout" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [userinfo removeObjectForKey:@"logincode"];
        [userinfo removeObjectForKey:@"session"];
        [userinfo synchronize];
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate.carlist removeAllObjects];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//返回上级页面
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//布局静态表格信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0&&indexPath.section == 0) {
        NSLog(@"消息提醒设置");
        if ([userinfo valueForKey:@"logincode"]) {
            [self performSegueWithIdentifier:@"Messagenotice" sender:nil];
        }else{
            CATransition *transition = [CATransition animation];
            transition.duration = 0.6f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = @"rippleEffect";
            transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self performSegueWithIdentifier:@"Settologin" sender:@"消息提醒设置"];
        }
    }else if (indexPath.row == 0&&indexPath.section == 1){
        NSLog(@"反馈与建议");
        [self performSegueWithIdentifier:@"Tellme" sender:nil];
    }else if (indexPath.row == 1&&indexPath.section == 1){
        NSLog(@"版本更新");
    }else if (indexPath.row == 2&&indexPath.section == 1){
        NSLog(@"关于我们");
        [self performSegueWithIdentifier:@"Aboutus" sender:nil];
    }else if (indexPath.row == 0&&indexPath.section == 2){
        NSLog(@"用户协议");
        [self performSegueWithIdentifier:@"Xieyi" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return Screen.bounds.size.height/35;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Settologin"]) {
        DLYTableViewController* dlyvc = [segue destinationViewController];
        dlyvc.gotopurpose = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
