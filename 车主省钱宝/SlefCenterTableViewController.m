//
//  SlefCenterTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/2/12.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "SlefCenterTableViewController.h"
#import "Utils.h"
#import "DLYTableViewController.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "Userinfo.h"
#import "UIbuttonStyle.h"
#import "AppDelegate.h"
#import "Lloadview.h"
#import "WritecarinfoTableViewController.h"
@interface SlefCenterTableViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *userphonenumber;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)Userinfo *userinfo;
@property(nonatomic,copy)NSString *memberCarsCount;
@property(nonatomic,copy)NSString *memberOrderCount;
@property(nonatomic,copy)NSString *newmessageCount;
@property(nonatomic,retain)Lloadview *loadview;
@end

@implementation SlefCenterTableViewController


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];    
    self.userinfo = [Userinfo shareUserinfo];
    //显示用户电话
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]) {
        NSString* phone = [userinfo valueForKey:@"userphone"];
        NSString *h = [phone substringToIndex:3];
        NSString *m = [phone substringWithRange:NSMakeRange(3,4)];
        NSString *l = [phone substringFromIndex:7];
        NSString* userphone  = [NSString stringWithFormat:@"%@ %@ %@",h,m,l];
        
        [self.userphonenumber setTitle:userphone forState:UIControlStateNormal];
        self.userphonenumber.userInteractionEnabled = NO;
        [self.userphonenumber.layer setBorderColor:[UIColor clearColor].CGColor];//边框颜色
        [self.userphonenumber.titleLabel setFont:[UIFont systemFontOfSize:20]];
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if ([userinfo valueForKey:@"logincode"]) {
        [self Userinfoforhttp];
    }
}
- (IBAction)back:(UIButton *)sender {
        [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)delayView{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Lloadview" owner:nil options:nil]; //&1
    self.loadview = [views lastObject];
    self.loadview.frame = Screen.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadview];
}
-(void)deleteView{
    [self.loadview removeFromSuperview];
}


-(void)cancelimage:(UIView*)pointimage{
    pointimage.transform = CGAffineTransformMakeScale(1.0, 1.0);//将要显示的view按照正常比例显示出来
    [UIView animateWithDuration:1.0f animations:^
     {
         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];  //InOut 表示进入和出去时都启动动画
         pointimage.transform=CGAffineTransformMakeScale(0.6, 0.6);//先让要显示的view最小直至消失
     }completion:^(BOOL finished){
         [pointimage removeFromSuperview];
     }];
    
    
}
//MD5加密
-(NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];//转换成utf-8
    unsigned char result[16];//开辟一个16字节（128位：md5加密出来就是128位/bit）的空间（一个字节=8字位=8个二进制数）
    CC_MD5( cStr, strlen(cStr), result);
    /*
     extern unsigned char *CC_MD5(const void *data, CC_LONG len, unsigned char *md)官方封装好的加密方法
     把cStr字符串转换成了32位的16进制数列（这个过程不可逆转） 存储到了result这个空间中
     */
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
    /*
     x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
     NSLog("%02X", 0x888);  //888
     NSLog("%02X", 0x4); //04
     */
}
-(void)Userinfoforhttp{
    //[self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/member/memberinfo",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            self.userinfo.userid = [NSString stringWithFormat:@"%@",[[[json objectForKey:@"datas"] objectForKey:@"member"] objectForKey:@"id"]];
            self.newmessageCount = [NSString stringWithFormat:@"%@",[[[json objectForKey:@"datas"] objectForKey:@"member"] objectForKey:@"newMsgCount"]];
            if ([self.newmessageCount intValue]>0) {
                self.newspoint.hidden = NO;
            }
            [userinfo synchronize];
            [self deleteView];
        }else if ([[json objectForKey:@"status"] intValue] == -6){
            [userinfo removeObjectForKey:@"logincode"];
            [self deleteView];
            [self.userphonenumber.layer setMasksToBounds:YES];
            [self.userphonenumber.layer setCornerRadius:1.0]; //设置矩形四个圆角半径
            [self.userphonenumber.layer setBorderWidth:0.5]; //边框宽度
            [self.userphonenumber.layer setBorderColor:[UIColor colorWithRed:242.0/255 green:88.0/255 blue:88.0/255 alpha:1].CGColor];//边框颜色
            
            [UIbuttonStyle UIbuttonStyleNO:self.userphonenumber];
            [self.userphonenumber setTitle:@"马上登录" forState:UIControlStateNormal];
            [self.userphonenumber.titleLabel setFont:[UIFont systemFontOfSize:14]];
            self.userphonenumber.userInteractionEnabled = YES;
            self.newspoint.hidden = YES;
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
                        al.delegate =self;
            [al show];
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
            [self deleteView];
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
        [userinfo removeObjectForKey:@"logincode"];
        [userinfo removeObjectForKey:@"session"];
        [userinfo synchronize];
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate.carlist removeAllObjects];

        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


////登录与否
//- (IBAction)Login:(UIButton *)sender {
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.6f;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = @"rippleEffect";
//    transition.subtype = kCATransitionFromRight;
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//    [self performSegueWithIdentifier:@"Selfcentertolongin" sender:nil];
//    //开启自定义左baritem的手势返回
//    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
//    //隐藏下部导航
//    self.tabBarController.tabBar.hidden = YES;
//
//}

//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else{
        return Screen.bounds.size.height/35;
    }
}
//布局静态表格信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if (indexPath.row == 0&&indexPath.section == 2) {
//        NSLog(@"我的车辆");
//        if ([userinfo valueForKey:@"logincode"]) {
//            [self performSegueWithIdentifier:@"Mycar" sender:@"车辆"];
//
//        }else{
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.6f;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = @"rippleEffect";
//            transition.subtype = kCATransitionFromRight;
//            transition.delegate = self;
//            [self.navigationController.view.layer addAnimation:transition forKey:nil];
//            [self performSegueWithIdentifier:@"Selfcentertolongin" sender:@"我的车辆"];
//            
//
//        }
        [self performSegueWithIdentifier:@"Mycar" sender:nil];

    }else if (indexPath.row == 0&&indexPath.section == 1){
//        NSLog(@"我的账户");
//        if ([userinfo valueForKey:@"logincode"]) {
//            [self performSegueWithIdentifier:@"Myaccont" sender:nil];
//        }else{
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.6f;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = @"rippleEffect";
//            transition.subtype = kCATransitionFromRight;
//            transition.delegate = self;
//            [self.navigationController.view.layer addAnimation:transition forKey:nil];
//            [self performSegueWithIdentifier:@"Selfcentertolongin" sender:@"我的账户"];
//        }
        [self performSegueWithIdentifier:@"Myaccont" sender:nil];
    }else if (indexPath.row == 1&&indexPath.section == 2){
//        NSLog(@"我的订单");
//        if ([userinfo valueForKey:@"logincode"]) {
//            [self performSegueWithIdentifier:@"Myorder" sender:nil];
//            
//        }else{
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.6f;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = @"rippleEffect";
//            transition.subtype = kCATransitionFromRight;
//            transition.delegate = self;
//            [self.navigationController.view.layer addAnimation:transition forKey:nil];
//            [self performSegueWithIdentifier:@"Selfcentertolongin" sender:@"我的订单"];
//        }
        [self performSegueWithIdentifier:@"Myorder" sender:nil];
    }else if (indexPath.row == 2&&indexPath.section == 2){
//        NSLog(@"我的消息");
//        if ([userinfo valueForKey:@"logincode"]) {
//            [self cancelimage:self.newspoint];
//            [self performSegueWithIdentifier:@"Mymessage" sender:nil];
//        }else{
//            CATransition *transition = [CATransition animation];
//            transition.duration = 0.6f;
//            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//            transition.type = @"rippleEffect";
//            transition.subtype = kCATransitionFromRight;
//            transition.delegate = self;
//            [self.navigationController.view.layer addAnimation:transition forKey:nil];
//            [self performSegueWithIdentifier:@"Selfcentertolongin" sender:@"我的消息"];
//        }
        [self cancelimage:self.newspoint];
        [self performSegueWithIdentifier:@"Mymessage" sender:nil];
    }else if (indexPath.row == 0&&indexPath.section == 3){
        [self performSegueWithIdentifier:@"Set" sender:nil];
    }
    
    if (indexPath.section!=0) {
        
        //开启自定义左baritem的手势返回
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Addcar"]){
        WritecarinfoTableViewController* wvc = [segue destinationViewController];
        wvc.isaddcar = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
