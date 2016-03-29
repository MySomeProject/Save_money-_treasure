//
//  GetmoneyTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/16.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "GetmoneyTableViewController.h"
#import "Utils.h"
#import "Popview.h"
#import "UIbuttonStyle.h"
#import "Lloadview.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import <CommonCrypto/CommonDigest.h>
@interface GetmoneyTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *getmoney;
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UILabel *bankshengshi;
@property (weak, nonatomic) IBOutlet UILabel *bankname;
@property (weak, nonatomic) IBOutlet UITextField *subbankname;
@property (weak, nonatomic) IBOutlet UITextField *bankcard;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *owerid;
@property (weak, nonatomic) IBOutlet UITextField *getmoneytext;
@end

@implementation GetmoneyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self tapCancelKeyboard];
    [UIbuttonStyle UIbuttonStyleBig:self.getmoney];
    self.getmoneytext.text = self.money;
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bsselectcar:) name:@"bstocity" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bselectcar:) name:@"btocity" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbank:) name:@"gbank" object:nil];
    
    //监听输入框内容的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoAction)name:UITextFieldTextDidChangeNotification object:nil];
}
//转换成大写
-(void)infoAction{
    NSString* text = self.owerid.text;
    [self.owerid setText:[text uppercaseString]];
}
- (void)bsselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bscity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.bankshengshi.text = citys[0];
    
}
- (void)gbank:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bank"];
    self.bankname.text = city;
    
}
- (void)bselectcar:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"bcity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.bankshengshi.text = [NSString stringWithFormat:@"%@%@",citys[3],citys[0]];
    
}
-(void)Getmoneyforhttp{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"money":self.getmoneytext.text,@"openBank":self.bankname.text,@"openBranch":self.subbankname.text,@"bankNumber":self.bankcard.text,@"accountName":self.name.text,@"identity":self.owerid.text};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/withdraw/savewithdraw",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"jjjjjjjj%@",json);

        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
        [self performSegueWithIdentifier:@"GetmoneySecces" sender:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (self.getmoneytext == textField) {
        if ([self.getmoneytext.text floatValue]>[self.money floatValue]) {
            [self.getmoneytext setText:self.money];
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
//tableview里面加手势取消键盘
-(void)tapCancelKeyboard{
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenKeyboard:)];
    tapGR.delegate = self;
    tapGR.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGR];
}
- (IBAction)savetogetout:(UIButton *)sender {

    if ([self.bankname.text length]>0) {
        if ([self.bankshengshi.text length]>0) {
            if ([self.subbankname.text length]>0) {
                if ([self.bankcard.text length]>0) {
                    if ([self.name.text length]>0) {
                        if ([self isvalidateidNo:self.owerid.text]) {
                            if ([self.getmoneytext.text floatValue]>0) {
                                [self Getmoneyforhttp];
                            }else{
                                //定义弹框次数
                                if (self.popview.superview == nil) {
                                    [self addpopview:@"可提现余额不足"];
                                }
                            }
                        }else{
                            //定义弹框次数
                            if (self.popview.superview == nil) {
                                [self addpopview:@"请输入身份证号"];
                            }
                        }
                    }else{
                        //定义弹框次数
                        if (self.popview.superview == nil) {
                            [self addpopview:@"请输入银行账户名称"];
                        }
                    }
                }else{
                    //定义弹框次数
                    if (self.popview.superview == nil) {
                        [self addpopview:@"请输入银行卡号"];
                    }
                }
            }else{
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"请输入支行名称"];
                }
            }
        }else{
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"请选择开户省市"];
            }
        }
    }else{
        //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"请选择银行名称"];
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
//调用弹框视图
- (void)addpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
}

-(void)hidenKeyboard:(UITapGestureRecognizer *)tapGR
{
    //放弃第一响应者身份
    [self.view endEditing:YES];
}
//回退
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)selectbank:(UIButton *)sender {
    [self performSegueWithIdentifier:@"GMtobank" sender:nil];
}
- (IBAction)selectkaihusheng:(id)sender {
        [self performSegueWithIdentifier:@"GMStocity" sender:nil];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return Screen.bounds.size.height/35;
}
//判断输入框输入字符数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.owerid == textField)
    {
        if ([toBeString length] > 18) {
            return NO;
        }
    }else if (self.bankcard == textField){
        if ([toBeString length] > 15) {
            return NO;
        }
    }
    return YES;
}
/*身份证验证 MODIFIED BY HELENSONG*/
- (BOOL) isvalidateidNo:(NSString*)idNo
{
    NSString *carRegex = @"^([0-9]{17}[0-9X]{1})|([0-9]{15})$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:idNo];
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
