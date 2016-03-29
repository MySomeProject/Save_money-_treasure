//
//  CPTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/13.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CPTableViewController.h"
#import "UIbuttonStyle.h"
#import "Utils.h"
#import "Popview.h"
#import "CarKeyBoardview.h"
#import "CarinfoH5ViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
@interface CPTableViewController ()<CarKeyBoardviewdelegate>
@property (weak, nonatomic) IBOutlet UIButton *next;
@property(nonatomic,copy)NSString* cityname;
@property (weak, nonatomic) IBOutlet UIButton *selectcar;
@property(nonatomic,copy)NSString* code;
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@end

@implementation CPTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];

    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self NaviInit];
    [self tapCancelKeyboard];
    //监听输入框内容的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoAction)name:UITextFieldTextDidChangeNotification object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bsselectcar:) name:@"bstocity" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bselectcar:) name:@"btocity" object:nil];
    [UIbuttonStyle UIbuttonStyleBig:self.next];
    [self registerForKeyboardNotifications];

}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.tableView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height);
 
}
- (void)keyboardWasShown:(NSNotification*)aNotification
{

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.5 animations:^{
            self.tableView.frame = CGRectMake(0, -kbSize.height/2, self.tableView.frame.size.width, self.tableView.frame.size.height);
    }];
    
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
//转换成大写
-(void)infoAction{
    NSString* text = self.carnumber.text;
    [self.carnumber setText:[text uppercaseString]];
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
- (void)bsselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bscity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.cityname = citys[0];
    self.code = citys[1];
    [self.selectcar setTitle:[citys[2] substringToIndex:1] forState:UIControlStateNormal];
    [self.carnumber setText:[citys[2] substringFromIndex:1]];
    self.usedrive.text = self.cityname;
    
}
- (void)bselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bcity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.cityname = citys[0];
    self.code = citys[1];
    [self.selectcar setTitle:[citys[2] substringToIndex:1] forState:UIControlStateNormal];
    [self.carnumber setText:[citys[2] substringFromIndex:1]];
    self.usedrive.text = self.cityname;
    
}
//navi初始化
-(void)NaviInit{
    [self.heardimage.layer setCornerRadius:10]; //设置矩形四个圆角半径
}

- (IBAction)gotoselectcity:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Bselectcity" sender:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)delayView{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Lloadview" owner:nil options:nil]; //&1
    self.loadview = [views lastObject];
    self.loadview.frame = Screen.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadview];
}
-(void)deleteView{
    [self.loadview removeFromSuperview];
}
//添加车辆
-(void)Addcarinfoforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    
    NSDictionary* parameter = @{@"platesNumber":[NSString stringWithFormat:@"%@%@",self.selectcar.titleLabel.text,self.carnumber.text],@"commonAreaCode":self.code,@"commonArea":self.usedrive.text,@"ownerName":self.name.text,@"type":@"1"};
    
    NSData *jsonData1 = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:nil];
    NSString* parameter1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    NSString* jsondata = [NSString stringWithFormat:@"parameter=%@",parameter1];
    NSString* md5codetotle = [NSString stringWithFormat:@"%@%@",jsondata,session];
    NSString* md5code = [self md5:md5codetotle];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":parameter1,@"session":session};
    NSLog(@"getcodejson%@",getcodejson);
    NSString *url = [NSString stringWithFormat:@"%@/member/car",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"s%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            //添加 字典，将label的值通过key值设置传递
            NSDictionary *dictmain =[[NSDictionary alloc] initWithObjectsAndKeys:@"加车后主页刷新",@"addcarmainupdate", nil];
            //创建通知
            NSNotification *notificationmain =[NSNotification notificationWithName:@"addcartomainupdate" object:nil userInfo:dictmain];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notificationmain];
            
            NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
            NSString* phone = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"userphone"]];

            NSDictionary*  dic = @{@"platesNumber":[NSString stringWithFormat:@"%@%@",self.selectcar.titleLabel.text,self.carnumber.text],@"ownerName":self.name.text,@"commonArea":self.usedrive.text,@"commonAreaCode":self.code,@"ownerMobile":phone};
            NSDictionary* carinfo = @{@"carId":[[[json objectForKey:@"datas"] objectForKey:@"car"] objectForKey:@"id"],@"car":dic};
            [self performSegueWithIdentifier:@"GotoH5info" sender:carinfo];
            
            
        }else if([[json objectForKey:@"status"] intValue] == -6){
            [self deleteView];
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            al.delegate =self;
            [al show];
        }
        
        [self deleteView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
}

- (IBAction)bijianext:(UIButton *)sender {
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([self.usedrive.text length]>0) {
        if ([self isvalidateCarNo:[NSString stringWithFormat:@"%@%@",self.selectcar.titleLabel.text,self.carnumber.text]]) {
            if (self.name.text.length >= 2) {
                for (int i = 0; i<self.name.text.length; i++) {
                    unichar c = [self.name.text characterAtIndex:i];
                    if (c >=0x4E00 && c <=0x9FA5)
                    {
                        if ([userinfo valueForKey:@"logincode"]) {
                            [self Addcarinfoforhttp];

                            break;
                        }else{
                          NSDictionary*  dic = @{@"platesNumber":[NSString stringWithFormat:@"%@%@",self.selectcar.titleLabel.text,self.carnumber.text],@"ownerName":self.name.text,@"commonArea":self.usedrive.text,@"commonAreaCode":self.code,@"ownerMobile":@""};
                            NSDictionary* carinfo = @{@"car":dic};
                            [self performSegueWithIdentifier:@"GotoH5info" sender:carinfo];
                            break;
                        }

                        
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
//调用弹框视图
- (void)addpopview:(NSString*)title{
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*车牌号验证 MODIFIED BY HELENSONG*/
- (BOOL) isvalidateCarNo:(NSString*)carNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[A-Z]{1}[A-Z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

- (IBAction)selectecar:(UIButton *)sender {
    
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

-(void)Menumehod:(NSString *)text{
    NSString* title = [NSString stringWithFormat:@"%@",text];
    [self.selectcar setTitle:title forState:UIControlStateNormal];
    [self.carnumber becomeFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GotoH5info"]) {
        CarinfoH5ViewController* cvc = segue.destinationViewController;
        cvc.carinfo = sender;
    }
}


@end
