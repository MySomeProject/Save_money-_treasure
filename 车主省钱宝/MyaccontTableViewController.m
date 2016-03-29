//
//  MyaccontTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/14.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MyaccontTableViewController.h"
#import "Lloadview.h"
#import "Utils.h"
#import "MyredpaperViewController.h"
#import "MywalletViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "Checkshuju.h"
#import "AppDelegate.h"
@interface MyaccontTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *redpaper;
@property (weak, nonatomic) IBOutlet UILabel *wallet;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;

@end

@implementation MyaccontTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self Userinfoforhttp];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
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
    [self delayView];
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
            self.wallet.text = [NSString stringWithFormat:@"%@",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"money"] ]];
            self.redpaper.text = [NSString stringWithFormat:@"%@",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"redbag"] ]];
            
            [self deleteView];
        }else if([[json objectForKey:@"status"] intValue] == -6){
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

//布局静态表格信息
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Redpaper" sender:self.redpaper.text];
    }else if (indexPath.row == 1){
        [self performSegueWithIdentifier:@"Wallet" sender:self.wallet.text];
    }else{
        [self performSegueWithIdentifier:@"Yingxiao" sender:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Wallet"]){
        MywalletViewController* wvc = [segue destinationViewController];
        wvc.totle = sender;
    }
}


@end
