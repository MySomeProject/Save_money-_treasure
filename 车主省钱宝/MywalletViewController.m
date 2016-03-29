//
//  MywalletViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MywalletViewController.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import <CommonCrypto/CommonDigest.h>
#import "Walletinfo.h"
#import "MywalletTableViewCell.h"
#import "Lloadview.h"
#import "AppDelegate.h"
#import "Checkshuju.h"
#import "GetmoneyTableViewController.h"
@interface MywalletViewController ()
@property (weak, nonatomic) IBOutlet UILabel *moeny;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSMutableArray *wallets;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,retain)Lloadview *loadview;
@end

@implementation MywalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.totle) {
        [self.moeny setText:self.totle];
    }else{
        [self.moeny setText:@"0"];
    }

    self.wallets = [NSMutableArray array];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self mywalletforhttp];
    // Do any additional setup after loading the view.
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
- (IBAction)Getmoney:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Getmoney" sender:self.moeny.text];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)mywalletforhttp{
    [self delayView];
    [self.wallets removeAllObjects];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"types":@[@{@"type":@"1"}]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/cashledger/findmembercashledgerlist",BaseUrl];
    NSLog(@"getcodejson%@",getcodejson);
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"mywalletforhttp%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            
            NSArray* wallets = [[[json objectForKey:@"datas"] objectForKey:@"memberCashLedger"] objectForKey:@"content"];
            for (NSDictionary* walletdic in wallets) {
                Walletinfo* walletinfo = [[Walletinfo alloc]init];
                walletinfo.title = [NSString stringWithFormat:@"%@",[walletdic objectForKey:@"desca"]];
                walletinfo.time = [NSString stringWithFormat:@"%@",[walletdic objectForKey:@"createTime"]];
                walletinfo.balance = [NSString stringWithFormat:@"余额:%@",[Checkshuju checkshuju:[walletdic objectForKey:@"balance"] ]];
                if ([[NSString stringWithFormat:@"%@",[walletdic objectForKey:@"inCome"]] floatValue]>0) {
                    walletinfo.info = [NSString stringWithFormat:@"+%@",[Checkshuju checkshuju:[walletdic objectForKey:@"inCome"] ]];
                }
                if ([[NSString stringWithFormat:@"%@",[walletdic objectForKey:@"expenditure"]] floatValue]>0) {
                    walletinfo.info = [NSString stringWithFormat:@"-%@",[Checkshuju checkshuju:[walletdic objectForKey:@"expenditure"] ]];
                }
                [self.wallets addObject:walletinfo];

            }
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
                        al.delegate =self;
            [al show];
        }
        [self.tableview reloadData];
        [self deleteView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"myeee%@",error);
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
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wallets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MywalletTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Walletinfo* wallet = self.wallets[indexPath.row];
    cell.kind.text = wallet.title;
    cell.time.text = wallet.time;
    cell.money.text = wallet.balance;
    if ([[wallet.info substringToIndex:1] isEqualToString:@"-"]) {
        [cell.info setTextColor:[UIColor colorWithRed:242.0/255 green:88.0/255 blue:88.0/255 alpha:1]];
    }else{
        [cell.info setTextColor:[UIColor colorWithRed:111.0/255 green:182.0/255 blue:73.0/255 alpha:1]];
    }
    cell.info.text = wallet.info;
    return cell;
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
    if ([segue.identifier isEqualToString:@"Getmoney"]) {
        GetmoneyTableViewController* gvc = [segue destinationViewController];
        gvc.money = sender;
    }
}


@end
