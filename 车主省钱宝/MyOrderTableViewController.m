//
//  MyOrderTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/17.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MyOrderTableViewController.h"
#import "OrderTableViewCell.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "NullView.h"
#import "Lloadview.h"
#import "Checkshuju.h"
#import "Popview.h"
#import "PutorderTableViewController.h"
#import "Orderinfo.h"
#import "PutareadyTableViewController.h"
#import "OrderinfoTableViewController.h"
#import "Checkshuju.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "MainInfo.h"
#import "UIImageView+WebCache.h"
@interface MyOrderTableViewController ()<UIAlertViewDelegate,OrderTableViewCelldelegate,NullViewdelegate>
@property(nonatomic,retain)NullView* nullview;
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSMutableArray *orders;
@property(nonatomic,retain)NSDictionary *xianzhongprices;
@property(nonatomic,copy)NSString *cancelordernumber;
@property(nonatomic)int page;
@end

@implementation MyOrderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.orders = [NSMutableArray array];
    // 2.集成刷新控件
    self.page = 1;
    [self setupRefresh];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self selectcityforhttp];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logintomaintostoptongzhi:) name:@"canceltoorder" object:nil];

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
    [self myorderforhttp];
}
- (void)logintomaintostoptongzhi:(NSNotification *)text{
    [self.orders removeAllObjects];
    [self myorderforhttp];
}
//调用弹框视图
- (void)addnullpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NullView" owner:nil options:nil]; //&1
    self.nullview = [views lastObject];
    [self.nullview addpopview:self.nullview andtitle:title andbutitle:@"去下单"];
    self.nullview.delegate = self;
    [self.view addSubview:self.nullview];
    
}
-(void)NullViewMenumehod{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0) {
        MainInfo* m = appdelegate.carlist[0];
        if ([m.carnumber length]>0) {
            [self performSegueWithIdentifier:@"Carbijia" sender:nil];
        }else{
            [self performSegueWithIdentifier:@"Nocarbijia" sender:nil];
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
- (void)delayView{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Lloadview" owner:nil options:nil]; //&1
    self.loadview = [views lastObject];
    self.loadview.frame = Screen.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.loadview];
}
-(void)deleteView{
    [self.loadview removeFromSuperview];
}


-(void)selectcityforhttp{
    [self.manager POST:@"http://static.ebaochina.cn/ftp/insurances.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        self.xianzhongprices = [json objectForKey:@"insurances"];
        if (self.xianzhongprices) {
            [self myorderforhttp];
        }
                NSLog(@"json%@",self.xianzhongprices);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(void)myorderforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary*  parameter = @{@"page":[NSString stringWithFormat:@"%d",self.page]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/order/myorders",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* orders = [[[json objectForKey:@"datas"] objectForKey:@"orders"] objectForKey:@"content"];
            if (orders.count>0) {
                for (NSDictionary* orderinfodic in orders) {
                    Orderinfo* orderinfo = [[Orderinfo alloc]init];
                    orderinfo.ordernumber = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"orderId"]];
                    orderinfo.orderstats = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"orderState"]];
                    orderinfo.ordercarnumber = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"platesNumber"]];
                    orderinfo.shangyexianbaodanhao = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"bizOrderNo"]];
                    orderinfo.ordercarownname = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"ownerName"]];
                    orderinfo.orderbaoxianqixian = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"forceBeginDate"]];
                    orderinfo.orderxiadanshijian = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"createTime"]];
                    orderinfo.ordercarownid = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"ownerCard"]];
                    orderinfo.orderarea = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"memberCar"] objectForKey:@"commonArea"]];
                    orderinfo.orderbeitoubaoren = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"applicant"] objectForKey:@"name"]];
                    orderinfo.orderbeitoubaoren = [NSString stringWithFormat:@"%@",[[orderinfodic objectForKey:@"insured"] objectForKey:@"name"]];
                    orderinfo.ordershoujianren = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"addresseeName"]];
                    orderinfo.orderphone = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"addresseeMobile"]];
                    orderinfo.orderaddress = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"addresseeDetails"]];
                    orderinfo.useRedAmount = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"useRedAmount"]];
                    orderinfo.useAmount = [NSString stringWithFormat:@"%@",[orderinfodic objectForKey:@"useAmount"]];
                    
                    if ([orderinfodic objectForKey:@"rsInsuraces"]) {
                        NSDictionary* dic = [self dictionaryWithJsonString:[orderinfodic objectForKey:@"rsInsuraces"]];
                        orderinfo.orderbaoxiangongsiname = [[dic objectForKey:@"insurers"] objectForKey:@"name"];
                        orderinfo.orderbaoxiangongsiimage = [[dic objectForKey:@"insurers"] objectForKey:@"logo"];
                        orderinfo.orderpriace = [NSString stringWithFormat:@"%f",(float)[[[dic objectForKey:@"totalPremium"] objectForKey:@"totalPremium"] intValue]/100];
                        
                        NSArray* insurances = [dic objectForKey:@"insurances"];
                        NSArray* insur = [dic objectForKey:@"insur"];
                        orderinfo.xianzhongname = [NSMutableArray array];
                        orderinfo.xianzhongprice = [NSMutableArray array];
                        for (NSDictionary* xian in insurances) {
                            [orderinfo.xianzhongname addObject:[NSString stringWithFormat:@"%@(%@)",[[self.xianzhongprices objectForKey:[xian objectForKey:@"insuranceName"]] objectForKey:@"name"],[xian objectForKey:@"insuranceValue"]]];
                            [orderinfo.xianzhongprice addObject:[NSString stringWithFormat:@"%@",[xian objectForKey:@"premium"]]];
                        }
                        
                        for (NSDictionary* xian in insur) {
                            [orderinfo.xianzhongname addObject:[NSString stringWithFormat:@"%@(%@)",[xian objectForKey:@"name"],[xian objectForKey:@"value"]]];
                            [orderinfo.xianzhongprice addObject:[NSString stringWithFormat:@"%@",[xian objectForKey:@"premium"]]];
                        }
                    }
                    [self.orders addObject:orderinfo];
                    
                }
            }else{
                self.page--;
            }
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
            [self.tableView reloadData];

        }else if ([[json objectForKey:@"status"] intValue] == -6){
            [userinfo removeObjectForKey:@"logincode"];

            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            al.delegate =self;
            al.tag = 100;
            [al show];
        }
        if (self.orders.count == 0) {
            [self addnullpopview:@"还没有订单呢"];
        }else{
            [self.nullview removeFromSuperview];
        }
        
        [self deleteView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView footerEndRefreshing];
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
            [userinfo removeObjectForKey:@"logincode"];
            [userinfo removeObjectForKey:@"session"];
            [userinfo synchronize];
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            [appdelegate.carlist removeAllObjects];

            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else{
        if (buttonIndex == 0) {
            [self canceldingdan];
        }
    }

}
-(void)canceldingdan{
    
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/order/update/%@",BaseUrl,[self.cancelordernumber substringFromIndex:4]];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"cancel%@",[json objectForKey:@"message"]);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            [self.orders removeAllObjects];
            [self myorderforhttp];
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"订单已取消"];
            }
        }
        [self deleteView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
    
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//回退
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.orders.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        OrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"order" forIndexPath:indexPath];
    
    Orderinfo* o = self.orders[indexPath.section];
    cell.istic = NO;
    cell.ordernumber.text = [NSString stringWithFormat:@"订单号:%@",o.ordernumber];
    cell.totelprice.text = [Checkshuju checkshuju:o.orderpriace];
    cell.carnumber.text = [NSString stringWithFormat:@"%@•%@",[o.ordercarnumber substringToIndex:2],[o.ordercarnumber substringFromIndex:2]];
    cell.cpname.text = o.orderbaoxiangongsiname;
    [cell.cplogin setImageWithURL:[NSURL URLWithString:o.orderbaoxiangongsiimage] placeholderImage:[UIImage imageNamed:@"bG-logo"]];
    cell.shangyexianbaodanhao = o.shangyexianbaodanhao;
    if ([o.orderstats isEqualToString:@"1"]) {
        cell.orderstauts.text = @"提交成功";
    }else if ([o.orderstats isEqualToString:@"2"]){
        cell.orderstauts.text = @"出单成功";
    }else{
        cell.orderstauts.text = @"已取消";
    }
    if ([cell.orderstauts.text isEqualToString:@"提交成功"]) {
        cell.pay.hidden = NO;
        cell.cacel.hidden = NO;
    }else{
        cell.pay.hidden = YES;
        cell.cacel.hidden = YES;
    }
    
    cell.delegate = self;
    return cell;
    
    // Configure the cell...
}
-(void)OrderTableViewCellcancelMenumehod:(NSString*)ordernumber{
    self.cancelordernumber = ordernumber;
    UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"是否取消订单?" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    al.delegate =self;
    [al show];
}
-(void)OrderTableViewCellpayMenumehod:(NSString*)ordernumber{
    NSArray* strs = [ordernumber componentsSeparatedByString:@"-"];
    if ([strs[1] length]>0) {
      [self performSegueWithIdentifier:@"Nobaodan" sender:[ordernumber substringFromIndex:4]];
    }else{
        [self performSegueWithIdentifier:@"Payorder" sender:[ordernumber substringFromIndex:4]];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        if (Screen.bounds.size.height == 480) {
            return Screen.bounds.size.height/3.4;
        }else if (Screen.bounds.size.height == 568){
            return Screen.bounds.size.height/4;
        }else{
            return Screen.bounds.size.height/4.7;
        }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Orderinfo* oinfo = self.orders[indexPath.row];
    [self performSegueWithIdentifier:@"Orderinfo" sender:oinfo];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Payorder"]) {
        PutorderTableViewController* pvc = segue.destinationViewController;
        pvc.ordernumber = sender;
    }else if ([segue.identifier isEqualToString:@"Nobaodan"]){
        PutareadyTableViewController* pvc = segue.destinationViewController;
        pvc.orderid = sender;
    }else if ([segue.identifier isEqualToString:@"Orderinfo"]){
        OrderinfoTableViewController* ovc = segue.destinationViewController;
        ovc.orderinfo = sender;
    }
}


@end
