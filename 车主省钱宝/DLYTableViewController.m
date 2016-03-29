//
//  DLYTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/2/13.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "DLYTableViewController.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "UIbuttonStyle.h"
#import "Lloadview.h"
#import "SetobijiaViewController.h"
@interface DLYTableViewController ()<UIGestureRecognizerDelegate>
@property(nonatomic,retain)NSTimer* countTimer;
@property(nonatomic,assign)int seccount;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,copy)NSString *carid;

@end

@implementation DLYTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.xieyi setSelected:YES];
    [self tapCancelKeyboard];
    self.login.userInteractionEnabled = NO;
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [UIbuttonStyle UIbuttonStyleNO:self.GetCode];
    [UIbuttonStyle UIbuttonStyleBigDI:self.login];

}
- (IBAction)xieyi:(UIButton *)sender {
    [self performSegueWithIdentifier:@"xieyi" sender:nil];
}
//tableview里面加手势取消键盘
-(void)tapCancelKeyboard{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenKeyboard:)];
    tapGR.delegate = self;
    tapGR.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGR];
}


//校验登录按钮状态
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.xieyi.selected&&[self isValidateMobile:self.Username.text]) {
        self.login.userInteractionEnabled = YES;
        [UIbuttonStyle UIbuttonStyleBig:self.login];

    }else{
        self.login.userInteractionEnabled = NO;
        [UIbuttonStyle UIbuttonStyleBigDI:self.login];

    }
}

-(void)hidenKeyboard:(UITapGestureRecognizer *)tapGR
{
    //放弃第一响应者身份
    [self.view endEditing:YES];
}

//协议勾选是否
- (IBAction)XieYiEvent:(UIButton *)sender {
    if(sender.selected)
    {
        [sender setSelected:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"LOGIN－off"] forState:UIControlStateNormal];
    }else{
        [sender setSelected:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"LOGIN－in"] forState:UIControlStateNormal];
    }
    if (self.xieyi.selected&&[self isValidateMobile:self.Username.text]) {
        self.login.userInteractionEnabled = YES;
        [UIbuttonStyle UIbuttonStyleBig:self.login];
    }else{
        self.login.userInteractionEnabled = NO;
        [UIbuttonStyle UIbuttonStyleBigDI:self.login];
    }
}

//登录
- (IBAction)Login:(UIButton *)sender {
    
    if ([self isValidateMobile:self.Username.text]) {
        NSLog(@"手机号正确");
        if ([self.Code.text length]) {
            [self loginforhttp];
            NSLog(@"验证码正确");
        }else{
            NSLog(@"验证码错误");
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"验证码有误"];
            }
        }
    }else{
        NSLog(@"手机号有误");
        //定义弹框次数
        if (self.popview.superview == nil) {
            [self addpopview:@"手机号有误"];
        }
    }
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

//登录接口
-(void)loginforhttp{
    [self.view endEditing:YES];
    
    [self delayView];
    
    NSDictionary* parameter = @{@"phone":self.Username.text,@"authcode":self.Code.text};
    NSDictionary* comback = @{@"phone":self.Username.text,@"authcode":self.Code.text};
    NSError *error;
    NSData *parameterData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *parameterString = [[NSString alloc] initWithData:parameterData encoding:NSUTF8StringEncoding];
    NSData *combackData = [NSJSONSerialization dataWithJSONObject:comback options:NSJSONWritingPrettyPrinted error:&error];
    NSString *combackString = [[NSString alloc] initWithData:combackData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"comback=%@parameter=%@",parameterString,combackString];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* login = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":parameterString,@"comback":combackString};
    NSString *url = [NSString stringWithFormat:@"%@/member/login",BaseUrl];
    [self.manager POST:url parameters:login success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
            [userinfo setObject:[json objectForKey:@"status"] forKey:@"logincode"];
            [userinfo setObject:[[[json objectForKey:@"datas"] objectForKey:@"member"] objectForKey:@"phone"] forKey:@"userphone"];
            [userinfo setObject:[[[json objectForKey:@"datas"] objectForKey:@"member"] objectForKey:@"session"] forKey:@"session"];
            [userinfo synchronize];
            [self deleteView];
            [self Logintopurpose];
        }else{
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"验证码错误"];
            }
            [self deleteView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
}
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSString *str = [formatter stringFromDate:date];
    return str;
}

-(void)Logintopurpose{

    CATransition *transition = [CATransition animation];
    transition.duration = 0.6f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"rippleEffect";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    if ([self.gotopurpose isEqualToString:@"我的"]) {
        [self performSegueWithIdentifier:@"Logintocenter" sender:nil];
    }else if ([self.gotopurpose isEqualToString:@"首页"]){
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录后首页",@"loginmain", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"logintomain" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if ([self.gotopurpose isEqualToString:@"停驶"]){
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录后停驶",@"loginstop", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"logintostop" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self performSegueWithIdentifier:@"Logintostop" sender:nil];
    }else if ([self.gotopurpose containsString:@"ios"]){
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录后首页",@"loginmain", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"logintomain" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
        NSString* session = [userinfo objectForKey:@"session"];
        NSArray* ses = [self.gotopurpose componentsSeparatedByString:@"?"];
        NSString* url = [NSString stringWithFormat:@"%@?session=%@&%@",ses[0],session,ses[1]];
        [self performSegueWithIdentifier:@"Logintobijia" sender:url];
    }else{
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录后首页",@"loginmain", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"logintomain" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
//返回
- (IBAction)back:(UIButton *)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.6f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"rippleEffect";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];

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
//获取验证码
- (IBAction)GetCodeNumber:(UIButton *)sender {
    if ([self isValidateMobile:self.Username.text]) {
        [self Getcodeforhttp];
        [UIbuttonStyle UIbuttonStyleDI:self.GetCode];
        self.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
        self.seccount = 60;
        [sender setEnabled:NO];
        [UIbuttonStyle UIbuttonStyleDI:self.GetCode];
        [sender setTitle:[NSString stringWithFormat:@"%d秒后重新发送",self.seccount] forState:UIControlStateDisabled];
    }else{
        //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"手机号有误"];
            }
    }
}
//调用弹框视图
- (void)addpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
}
//验证码接口
-(void)Getcodeforhttp{
//  UInt64 sptime = [[NSDate date] timeIntervalSince1970]*1000;
    NSDictionary* parameter = @{@"phone":self.Username.text};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@",jsonString];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString};
    NSString *url = [NSString stringWithFormat:@"%@/member/getauthcode",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}
//验证码读秒方法
-(void)timeFireMethod{
    [self.GetCode setTitle:[NSString stringWithFormat:@"%d秒后重新发送",self.seccount -1 ] forState:UIControlStateDisabled];
    self.seccount--;
    if (self.seccount == 0) {
        [self.GetCode setEnabled:YES];
        [UIbuttonStyle UIbuttonStyleNO:self.GetCode];
        [self.GetCode setTitle:@"验证码" forState:UIControlStateNormal];
        [self.countTimer invalidate];
    }
}
//判断输入框输入字符数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.Username == textField)
    {
        if ([toBeString length] > 11) {
            return NO;
        }
    }else if (self.Code == textField){
        if ([toBeString length] > 6) {
            return NO;
        }
    }
    return YES;
    
}
//验证1开头的11位手机号
-(BOOL) isValidateMobile:(NSString *)mobile
{
    NSString *phoneRegex = @"1\\d{10}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Logintobijia"]) {
        SetobijiaViewController* svc = segue.destinationViewController;
        svc.url = sender;
    }
}


@end
