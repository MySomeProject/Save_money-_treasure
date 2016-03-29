//
//  CPHascarTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/6/1.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CPHascarTableViewController.h"
#import "AppDelegate.h"
#import "MainInfo.h"
#import "CPcarTableViewCell.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "Lloadview.h"
#import "Carinfo.h"
#import "Utils.h"
#import "CarinfoH5ViewController.h"
#import "MJRefresh.h"
#import "Checkshuju.h"
@interface CPHascarTableViewController ()<UIAlertViewDelegate>
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSMutableArray* carinfos;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic)int page;
@end

@implementation CPHascarTableViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 2.集成刷新控件
    [self setupRefresh];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.carinfos = [NSMutableArray array];
    [self Usercarforhttp];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addcarmainupdate:) name:@"addcarmainupdate" object:nil];
    
}
- (void)addcarmainupdate:(NSNotification *)text{
    [self Usercarforhttp];
}
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载";
    self.tableView.footerRefreshingText = @"加载中...";
}
- (void)footerRereshing
{
    self.page++;
    [self Usercarforhttp];
}
-(void)Usercarforhttp{
    [self delayView];
    [self.carinfos removeAllObjects];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/member/cars",BaseUrl];
    NSLog(@"加密前：%@",code);
    NSLog(@"加密后：%@",getcodejson);
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"commonArea%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* cars = [[[json objectForKey:@"datas"] objectForKey:@"cars"] objectForKey:@"content"];
            if (cars.count>0) {
                for (NSDictionary* carinfo in cars) {
                    Carinfo* car = [[Carinfo alloc]init];
                    car.brand_id = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"engineNumber"]];
                    car.code = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"commonAreaCode"]];
                    car.common_area = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"commonArea"]];
                    car.car_id = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"id"]];
                    car.insurance_end = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"insuranceEnd"]];
                    car.owner_name = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"ownerName"]];
                    car.redpaper = [NSString stringWithFormat:@"%@",[Checkshuju checkshuju:[carinfo objectForKey:@"money"]]];
                    car.license_plate = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"platesNumber"]];
                    car.vehicle_ldentification_n = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"vehicleLdentificationNumber"]];
                    car.car_id = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"id"]];
                    [self.carinfos addObject:car];
                }
            }else{
                self.page--;
            }
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
            [self.tableView reloadData];
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
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.carinfos.count;
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPcarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (self.carinfos.count>0) {
        // Configure the cell...
        Carinfo* carinfo = self.carinfos[indexPath.row];
        cell.carnumber.text = [NSString stringWithFormat:@"%@•%@",[carinfo.license_plate substringToIndex:2],[carinfo.license_plate substringFromIndex:2]];
        if ([carinfo.redpaper length]==0) {
            cell.redpaper.text = @"￥0.00";
        }else{
            cell.redpaper.text = [NSString stringWithFormat:@"￥%@",carinfo.redpaper];
        }
    }
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Carinfo* carinfo = self.carinfos[indexPath.row];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* phone = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"userphone"]];
    NSDictionary*  carinfo1 = @{@"platesNumber":carinfo.license_plate,@"ownerName":carinfo.owner_name,@"commonArea":carinfo.common_area,@"commonAreaCode":carinfo.code,@"ownerMobile":phone};
    NSDictionary* carinfo2 = @{@"carId":carinfo.car_id,@"car":carinfo1};
   [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"HascartoH5" sender:carinfo2];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"HascartoH5"]) {
        CarinfoH5ViewController* cvc = segue.destinationViewController;
        cvc.carinfo = sender;
    }
}


@end
