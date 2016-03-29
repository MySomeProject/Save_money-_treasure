//
//  WritecarinfoTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "WritecarinfoTableViewController.h"
#import "Utils.h"
#import "TimeView.h"
#import "CarKeyBoardview.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIbuttonStyle.h"
#import "Carinfo.h"
#import "StopViewController.h"
#import "Popview.h"
#import "Lloadview.h"
#import "AppDelegate.h"
#import "MainInfo.h"
@interface WritecarinfoTableViewController ()<TimeViewdelegate,CarKeyBoardviewdelegate>
@property (weak, nonatomic) IBOutlet UIButton *save;
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)Lloadview* loadview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,copy)NSString* cityname;
@property(nonatomic,copy)NSString* code;
@property(nonatomic,copy)NSString *parameter;
@end

@implementation WritecarinfoTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
    
}
//调用弹框视图
- (void)addpopview:(NSString*)title{

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bsselectcar:) name:@"bstocity" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bselectcar:) name:@"btocity" object:nil];
    
    if ([self.carinfo.license_plate length]>0) {
        [self.name setText:self.carinfo.owner_name];
        [self.commonlyuseddriving setText:self.carinfo.common_area];
        self.code = self.carinfo.code;
        [self.carnumber setText:[self.carinfo.license_plate substringFromIndex:1]];
        [self.carnumberheard setTitle:[self.carinfo.license_plate substringToIndex:1] forState:UIControlStateNormal];
    }
    
    [self tapCancelKeyboard];
    [UIbuttonStyle UIbuttonStyleBig:self.save];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //监听输入框内容的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoAction)name:UITextFieldTextDidChangeNotification object:nil];
    if ([self.comefrom length]!=0) {
        self.navigationItem.title = @"添加车辆";
    }else{
        self.navigationItem.title = @"编辑车辆";
        self.carnumberheard.userInteractionEnabled = NO;
        self.carnumber.userInteractionEnabled = NO;
    }
    NSLog(@"self.carinfo.car_id%@",self.carinfo.car_id);
    
}
- (void)bsselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bscity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.cityname = citys[0];
    self.code = citys[1];
    if (![self.navigationItem.title isEqualToString:@"编辑车辆"]) {
        [self.carnumberheard setTitle:[citys[2] substringToIndex:1] forState:UIControlStateNormal];
        [self.carnumber setText:[citys[2] substringFromIndex:1]];
    }
    [self.commonlyuseddriving setText:self.cityname];
    
}
- (void)bselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bcity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.cityname = citys[0];
    self.code = citys[1];
    if (![self.navigationItem.title isEqualToString:@"编辑车辆"]){
        [self.carnumberheard setTitle:[citys[2] substringToIndex:1] forState:UIControlStateNormal];
        [self.carnumber setText:[citys[2] substringFromIndex:1]];
    }
    [self.commonlyuseddriving setText:self.cityname];
    
}
//转换成大写
-(void)infoAction{
    NSString* text = self.carnumber.text;
    [self.carnumber setText:[text uppercaseString]];
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

-(void)Addcarinfoforhttp{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* parameter = [NSString stringWithFormat:@"parameter=%@",self.parameter];
    NSString* md5codetotle = [NSString stringWithFormat:@"%@%@",parameter,session];
    NSString* md5code = [self md5:md5codetotle];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":self.parameter,@"session":session};
    NSLog(@"getcodejson%@",getcodejson);
    NSString *url = [NSString stringWithFormat:@"%@/member/car",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
                NSLog(@"s%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            self.httpcarid = [[[json objectForKey:@"datas"] objectForKey:@"car"] objectForKey:@"id"];
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            if (appdelegate.carlist.count>0) {
                MainInfo* m = appdelegate.carlist[0];
                if ([m.carnumber length]==0) {
                    [self nologintosetstopforhttp];
                }else{
                    //添加 字典，将label的值通过key值设置传递
                    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"加车后刷新",@"addcarstop", nil];
                    //创建通知
                    NSNotification *notification =[NSNotification notificationWithName:@"addcartostop" object:nil userInfo:dict];
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotification:notification];
                    
                    //添加 字典，将label的值通过key值设置传递
                    NSDictionary *dictmain =[[NSDictionary alloc] initWithObjectsAndKeys:@"加车后主页刷新",@"addcarmainupdate", nil];
                    //创建通知
                    NSNotification *notificationmain =[NSNotification notificationWithName:@"addcartomainupdate" object:nil userInfo:dictmain];
                    //通过通知中心发送通知
                    [[NSNotificationCenter defaultCenter] postNotification:notificationmain];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
  
            }
            [self deleteView];

        }else if([[json objectForKey:@"status"] intValue] == -6){
            [self deleteView];
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
                        al.delegate =self;
            [al show];
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
-(void)nologintosetstopforhttp{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"carId":self.httpcarid,@"date":[self stringFromFomate:[NSDate date] formate:@"yyyy-MM-dd"],@"memberstopset":@[@{@"index":@"1",@"isflgt":[userinfo objectForKey:@"cell1"]},@{@"index":@"2",@"isflgt":[userinfo objectForKey:@"cell2"]},@{@"index":@"3",@"isflgt":[userinfo objectForKey:@"cell3"]},@{@"index":@"4",@"isflgt":[userinfo objectForKey:@"cell4"]},@{@"index":@"5",@"isflgt":[userinfo objectForKey:@"cell5"]},@{@"index":@"6",@"isflgt":[userinfo objectForKey:@"cell6"]},@{@"index":@"7",@"isflgt":[userinfo objectForKey:@"cell7"]}]};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    
    
    NSString *url = [NSString stringWithFormat:@"%@/member/stop/setstopinformation",BaseUrl];
    NSLog(@"parameter%@ %@",parameter,url);
    
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"setstophttp%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            //添加 字典，将label的值通过key值设置传递
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录后刷新",@"loginupdate", nil];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"logintoupdate" object:nil userInfo:dict];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            [self deleteView];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
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
//tableview里面加手势取消键盘
-(void)tapCancelKeyboard{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenKeyboard:)];
    tapGR.delegate = self;
    tapGR.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGR];
}
-(void)hidenKeyboard:(UITapGestureRecognizer *)tapGR
{
    //放弃第一响应者身份
    [self.view endEditing:YES];
}

-(void)Menumehod:(NSString *)text{
    NSString* title = [NSString stringWithFormat:@"%@",text];
    [self.carnumberheard setTitle:title forState:UIControlStateNormal];
    [self.carnumber becomeFirstResponder];
}
- (IBAction)carheard:(UIButton *)sender {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"CarKeyBoardview" owner:nil options:nil]; //&1
        CarKeyBoardview* carKeyboardview = [views lastObject];
        carKeyboardview.frame = CGRectMake(0, Screen.bounds.size.height, Screen.bounds.size.width, Screen.bounds.size.height/3.5);
        [carKeyboardview addcarheard];
        [[UIApplication sharedApplication].keyWindow addSubview:carKeyboardview];
        carKeyboardview.delegate = self;
        [self.view endEditing:YES];
    [UIView animateWithDuration:0.2 animations:^{
        carKeyboardview.frame = Screen.bounds;
        
    } completion:^(BOOL finished) {
        carKeyboardview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return Screen.bounds.size.height/35;

}



- (IBAction)save:(UIButton *)sender {
    NSDictionary* cardic;
        if ([self.commonlyuseddriving.text length]>0) {
            if ([self isvalidateCarNo:[NSString stringWithFormat:@"%@%@",self.carnumberheard.titleLabel.text,self.carnumber.text]]) {
                if (self.name.text.length >= 2) {
                    for (int i = 0; i<self.name.text.length; i++) {
                        unichar c = [self.name.text characterAtIndex:i];
                        if (c >=0x4E00 && c <=0x9FA5)
                        {
                            [self delayView];
                            if (self.carinfo.car_id) {
                                    cardic = @{@"id":self.carinfo.car_id,@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard.titleLabel.text,self.carnumber.text],@"commonAreaCode":self.code,@"commonArea":self.commonlyuseddriving.text,@"ownerName":self.name.text,@"type":@"2"};
                                }else{
                                    cardic = @{@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard.titleLabel.text,self.carnumber.text],@"commonAreaCode":self.code,@"commonArea":self.commonlyuseddriving.text,@"ownerName":self.name.text,@"type":@"1"};
                                }
                                NSError *error;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cardic options:NSJSONWritingPrettyPrinted error:&error];
                                NSLog(@"error%@",error);
                                self.parameter = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                [self Addcarinfoforhttp];
                                
                                return;
                            
                        }else{
                            //定义弹框次数
                            if (self.popview.superview == nil) {
                                [self addpopview:@"请输入正确车主姓名"];
                            }
                        }
                    }
                }else{
                    //定义弹框次数
                    if (self.popview.superview == nil) {
                        [self addpopview:@"请输入正确车主姓名"];
                    }
                }
            }else{
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"请输入正确车牌号"];
                }
            }
        }else{
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"请选择行驶区域"];
            }
        }
    
}
//判断输入框输入字符数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.carnumber == textField)
    {
        if ([toBeString length] > 6) {
            return NO;
        }
    }
    return YES;
}
- (IBAction)comdrive:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Selectcity" sender:nil];
}

/*车架号校验*/
- (BOOL) isvalidatetheframenumber:(NSString*)theframenumber
{
    NSString *carRegex = @"[A-Za-z0-9]{17}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:theframenumber];
}
/*车牌号验证 MODIFIED BY HELENSONG*/
- (BOOL) isvalidateCarNo:(NSString*)carNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}


@end
