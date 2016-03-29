//
//  PutorderTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "PutorderTableViewController.h"
#import "UIbuttonStyle.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
#import "Utils.h"
#import "Popview.h"
@interface PutorderTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *put;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UITextField *baodanhao;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)Popview* popview;

@end

@implementation PutorderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [UIbuttonStyle UIbuttonStyleBig:self.put];
    [self tapCancelKeyboard];
    NSArray* strs = [self.ordernumber componentsSeparatedByString:@"-"];
    if (strs.count>1) {
       self.baodanhao.text = strs[1];
    }else{
        self.baodanhao.text = @"";
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
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)putorder:(UIButton *)sender {
    NSArray* strs = [self.ordernumber componentsSeparatedByString:@"-"];
    if ([strs[1] isEqualToString:self.baodanhao.text]) {
        //定义弹框次数
        if (self.popview.superview == nil) {
            [self addpopview:@"工作人员正在处理，请勿重复提交!"];
        }
    }else{
        if ([self isvaliorderid:self.baodanhao.text]) {
            [self delayView];
            NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
            NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
            NSString* md5code = [self md5:code];
            NSString* lowercode = [md5code lowercaseString];
            NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
            NSString *url = [NSString stringWithFormat:@"%@/order/%@/%@",BaseUrl,strs[0],self.baodanhao.text];
            [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSData *response = responseObject;
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
                NSLog(@"stopdddddd%@",json);
                if ([[json objectForKey:@"status"] intValue] == 0) {
                    [self performSegueWithIdentifier:@"Putsecess" sender:nil];
                    
                }
                [self deleteView];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",error);
                [self deleteView];
            }];
        }else{
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"商业险保单号有误"];
            }
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
/*车架号校验*/
- (BOOL) isvaliorderid:(NSString*)theframenumber
{
    NSString *carRegex = @"[A-Za-z0-9]{10,100}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:theframenumber];
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
