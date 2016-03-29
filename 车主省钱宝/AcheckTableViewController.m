//
//  AcheckTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/21.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "AcheckTableViewController.h"
#import "Utils.h"
#import "CarKeyBoardview.h"
#import "Lloadview.h"
#import "HintView.h"
#import "Popview.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "CheckinfoTableViewController.h"
@interface AcheckTableViewController ()
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)Popview* popview;
@property (weak, nonatomic) IBOutlet UITextField *carnumber;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *fadongjihao;
@property (weak, nonatomic) IBOutlet UITextField *chejiahao;
@property (weak, nonatomic) IBOutlet UIButton *check;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property(nonatomic,copy)NSString* shengcode;
@property (weak, nonatomic) IBOutlet UIButton *carnumberheard;
@property(nonatomic,copy)NSString* shicode;
@property(nonatomic,copy)NSString* classa;
@property(nonatomic,copy)NSString* engine;
@property(nonatomic,retain)NSDictionary* parameter;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@end

@implementation AcheckTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self tapCancelKeyboard];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Ctocitytongzhi:) name:@"Ctocity" object:nil];
    //监听输入框内容的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoAction)name:UITextFieldTextDidChangeNotification object:nil];

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
//转换成大写
-(void)infoAction{
    NSString* text = self.chejiahao.text;
    [self.chejiahao setText:[text uppercaseString]];
    NSString* text1 = self.fadongjihao.text;
    [self.fadongjihao setText:[text1 uppercaseString]];
    NSString* text2 = self.carnumber.text;
    [self.carnumber setText:[text2 uppercaseString]];
}
- (void)Ctocitytongzhi:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"Ccity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.shengcode = citys[0];
    self.shicode = citys[1];
    self.city.text = citys[2];
    self.classa = citys[3];
    self.engine = citys[4];
    [self.tableView reloadData];
}
-(void)Menumehod:(NSString *)text{
    NSString* title = [NSString stringWithFormat:@"%@",text];
    [self.carnumberheard setTitle:title forState:UIControlStateNormal];
    [self.carnumber becomeFirstResponder];
}
- (IBAction)selectcarnumberheard:(UIButton *)sender {
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
- (IBAction)selectcity:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Atoselect" sender:nil];
    
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }else if (section == 3){
        return 0.01;
    }else if (section == 2){
        return 0.01;
    }else{
        return Screen.bounds.size.height/35;
    }
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooderInSection:(NSInteger)section{
    return 0.01;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==3) {
        if ([self.classa isEqualToString:@"0"]) {
            return [super tableView:tableView numberOfRowsInSection:section] - 1;
        }else{
            return [super tableView:tableView numberOfRowsInSection:section];
        }
    }else if (section ==2){
        if ([self.engine isEqualToString:@"0"]) {
            return [super tableView:tableView numberOfRowsInSection:section] - 1;
        }else{
            return [super tableView:tableView numberOfRowsInSection:section];
        }
    }else{
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)checkweizhang:(UIButton *)sender {
    if ([self isvalidateCarNo:[NSString stringWithFormat:@"%@%@",self.carnumberheard.titleLabel.text,self.carnumber.text]]) {
        for (int i = 0; i<self.name.text.length; i++) {
            unichar c = [self.name.text characterAtIndex:i];
            if (c >=0x4E00 && c <=0x9FA5)
            {
                if ([self.city.text length]>0) {
                    if ([self.classa isEqualToString:@"0"]&&[self.engine isEqualToString:@"0"]) {
                        self.parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard,self.carnumber],@"engineNumber":@"",@"vehicleIdentificationNumber":@""};
                    }else if([self.classa isEqualToString:@"0"]&&(![self.engine isEqualToString:@"0"])){
                        if ([self.fadongjihao.text length]>3) {
                            self.parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard,self.carnumber],@"engineNumber":self.fadongjihao.text,@"vehicleIdentificationNumber":@""};
                        }else{
                            //定义弹框次数
                            if (self.popview.superview == nil) {
                                [self addpopview:@"请输入正确的发动机号"];
                            }
                        }
                    }else if([self.engine isEqualToString:@"0"]&&(![self.classa isEqualToString:@"0"])){
                        if ([self isvalidatetheframenumber:self.chejiahao.text]) {
                            self.parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard,self.carnumber],@"engineNumber":@"",@"vehicleIdentificationNumber":self.chejiahao.text};
                        }else{
                            //定义弹框次数
                            if (self.popview.superview == nil) {
                                [self addpopview:@"请输入正确的车架号"];
                            }
                        }
                    }else{
                        if ([self.fadongjihao.text length]>3) {
                            if ([self isvalidatetheframenumber:self.chejiahao.text]) {
                                self.parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard,self.carnumber],@"engineNumber":self.fadongjihao.text,@"vehicleIdentificationNumber":self.chejiahao.text};
                            }else{
                                //定义弹框次数
                                if (self.popview.superview == nil) {
                                    [self addpopview:@"请输入正确的车架号"];
                                }
                            }
                            
                        }else{
                            //定义弹框次数
                            if (self.popview.superview == nil) {
                                [self addpopview:@"请输入正确的发动机号"];
                            }
                        }
                    }
                }else{
                    //定义弹框次数
                    if (self.popview.superview == nil) {
                        [self addpopview:@"您还没有选择查询区域"];
                    }
                }
                
            }else{
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"车主姓名不正确"];
                }
            }
        }
    }else{
        //定义弹框次数
        if (self.popview.superview == nil) {
            [self addpopview:@"请输入正确的车牌号"];
        }
    }
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

//添加车辆
-(void)Addcarinfoforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    
    NSDictionary* parameter = @{@"platesNumber":[NSString stringWithFormat:@"%@%@",self.carnumberheard.titleLabel.text,self.carnumber.text],@"commonAreaCode":self.shicode,@"commonArea":self.city.text,@"ownerName":self.name.text,@"vehicleLdentificationNumber":[self.parameter objectForKey:@"vehicleLdentificationNumber"],@"engineNumber":[self.parameter objectForKey:@"engineNumber"],@"type":@"1"};
    
    NSString* jsondata = [NSString stringWithFormat:@"parameter=%@",parameter];
    NSString* md5codetotle = [NSString stringWithFormat:@"%@%@",parameter,session];
    NSString* md5code = [self md5:md5codetotle];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsondata,@"session":session};
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
            
            [self performSegueWithIdentifier:@"Acheck" sender:self.parameter];
            
            
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//判断输入框输入字符数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.chejiahao == textField)
    {
        if ([toBeString length] > 17) {
            return NO;
        }
    }else if(self.fadongjihao == textField){
        if ([toBeString length] > 20) {
            return NO;
        }
    }else if(self.carnumber == textField){
        if ([toBeString length] > 6) {
            return NO;
        }
    }
    return YES;
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

- (IBAction)shuoming:(UIButton *)sender {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"HintView" owner:nil options:nil]; //&1
    HintView* hv = [views lastObject];
    hv.frame = Screen.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:hv];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Acheck"]) {
        CheckinfoTableViewController* cvc = segue.destinationViewController;
        cvc.canshu = sender;
    }

}


@end
