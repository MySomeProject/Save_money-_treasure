//
//  FcheckTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/21.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "FcheckTableViewController.h"
#import "Utils.h"
#import "UIbuttonStyle.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
#import "Popview.h"
#import "HintView.h"
#import "CheckinfoTableViewController.h"
@interface FcheckTableViewController ()
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,copy)NSString* shengcode;
@property(nonatomic,copy)NSString* shicode;
@property (weak, nonatomic) IBOutlet UIButton *check;
@property (weak, nonatomic) IBOutlet UILabel *cityname;
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UITextField *chejiahao;
@property (weak, nonatomic) IBOutlet UITextField *fadongjihao;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,copy)NSString* classa;
@property(nonatomic,copy)NSString* engine;
@end

@implementation FcheckTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self tapCancelKeyboard];
    //监听输入框内容的改变
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(infoAction)name:UITextFieldTextDidChangeNotification object:nil];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString* carheard = [self.carnumbertitle substringToIndex:2];
    NSString* carfoot = [self.carnumbertitle substringFromIndex:2];
    self.navigationItem.title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
    [self getchejiahaoforhttp];
    [UIbuttonStyle UIbuttonStyleBig:self.check];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Ctocitytongzhi:) name:@"Ctocity" object:nil];

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
}
- (void)Ctocitytongzhi:(NSNotification *)text{
    NSString* city = [text.userInfo objectForKey:@"Ccity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.shengcode = citys[0];
    self.shicode = citys[1];
    self.cityname.text = citys[2];
    self.classa = citys[3];
    self.engine = citys[4];
    [self.tableView reloadData];
    
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
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
    if (section ==2) {
        if ([self.classa isEqualToString:@"0"]) {
            return [super tableView:tableView numberOfRowsInSection:section] - 1;
        }else{
            return [super tableView:tableView numberOfRowsInSection:section];
        }
    }else if (section ==1){
        if ([self.engine isEqualToString:@"0"]) {
            return [super tableView:tableView numberOfRowsInSection:section] - 1;
        }else{
            return [super tableView:tableView numberOfRowsInSection:section];
        }
    }else{
        return [super tableView:tableView numberOfRowsInSection:section];
    }
}
- (IBAction)selectcheckcity:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Checkcity" sender:nil];
}
-(void)getchejiahaoforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"platesNumber":self.carnumbertitle};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/violation/car",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"check%@",json);
        NSLog(@"%@",[json objectForKey:@"message"]);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            self.chejiahao.text = [[json objectForKey:@"datas"] objectForKey:@"vehicleIdentificationNumber"];
            self.fadongjihao.text = [[json objectForKey:@"datas"] objectForKey:@"engineNumber"];
            self.cityname.text = [[[json objectForKey:@"datas"] objectForKey:@"violationArea"] objectForKey:@"city"];
            self.shengcode = [NSString stringWithFormat:@"%@",[[json objectForKey:@"datas"] objectForKey:@"provinceCode"]];
            self.shicode = [NSString stringWithFormat:@"%@",[[json objectForKey:@"datas"] objectForKey:@"cityCode"]];
            self.classa = [NSString stringWithFormat:@"%@",[[[json objectForKey:@"datas"] objectForKey:@"violationArea"] objectForKey:@"classa"]];
            self.engine = [NSString stringWithFormat:@"%@",[[[json objectForKey:@"datas"] objectForKey:@"violationArea"] objectForKey:@"engine"]];
            
            
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            [al show];
        }else if([[json objectForKey:@"status"] intValue] == -16){
            
        }
        [self.tableView reloadData];
        [self deleteView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
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
- (void)delayView{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Lloadview" owner:nil options:nil]; //&1
    self.loadview = [views lastObject];
    self.loadview.frame = Screen.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadview];
}
-(void)deleteView{
    [self.loadview removeFromSuperview];
}
- (IBAction)checkweizhang:(UIButton *)sender {
    NSDictionary* parameter;
    if ([self.cityname.text length]>0) {
        if ([self.classa isEqualToString:@"0"]&&[self.engine isEqualToString:@"0"]) {
          parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnumbertitle,@"engineNumber":@"",@"vehicleIdentificationNumber":@""};
        [self performSegueWithIdentifier:@"Fcheck" sender:parameter];
        }else if([self.classa isEqualToString:@"0"]&&(![self.engine isEqualToString:@"0"])){
            if ([self.fadongjihao.text length]>3) {
            parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnumbertitle,@"engineNumber":self.fadongjihao.text,@"vehicleIdentificationNumber":@""};
            [self performSegueWithIdentifier:@"Fcheck" sender:parameter];
            }else{
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"请输入正确的发动机号"];
                }
            }
        }else if([self.engine isEqualToString:@"0"]&&(![self.classa isEqualToString:@"0"])){
            if ([self isvalidatetheframenumber:self.chejiahao.text]) {
                parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnumbertitle,@"engineNumber":@"",@"vehicleIdentificationNumber":self.chejiahao.text};
                [self performSegueWithIdentifier:@"Fcheck" sender:parameter];
            }else{
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"请输入正确的车架号"];
                }
            }
        }else{
            if ([self.fadongjihao.text length]>3) {
                if ([self isvalidatetheframenumber:self.chejiahao.text]) {
                    parameter  = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnumbertitle,@"engineNumber":self.fadongjihao.text,@"vehicleIdentificationNumber":self.chejiahao.text};
                    [self performSegueWithIdentifier:@"Fcheck" sender:parameter];
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
    }
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*车架号校验*/
- (BOOL) isvalidatetheframenumber:(NSString*)theframenumber
{
    NSString *carRegex = @"[A-Za-z0-9]{17}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:theframenumber];
}
//调用弹框视图
- (void)addpopview:(NSString*)title{
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
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
    if ([segue.identifier isEqualToString:@"Fcheck"]) {
        CheckinfoTableViewController* cvc = segue.destinationViewController;
        cvc.canshu = sender;
    }

}


@end
