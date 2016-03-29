//
//  OrderinfoTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "OrderinfoTableViewController.h"
#import "Utils.h"
#import "PayView.h"
#import "Checkshuju.h"
#import "Popview.h"
#import "PutareadyTableViewController.h"
#import "PutorderTableViewController.h"
#import "Lloadview.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import <CommonCrypto/CommonDigest.h>
@interface OrderinfoTableViewController ()<PayViewdelegate,UIAlertViewDelegate>
@property(nonatomic)BOOL uiisopen;
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UIImageView *uap;
@property(nonatomic,retain)PayView* payview;
@property(nonatomic,retain)Popview* popview;
@property (weak, nonatomic) IBOutlet UILabel *orderstats;
@property (weak, nonatomic) IBOutlet UILabel *orderid;
@property (weak, nonatomic) IBOutlet UIImageView *baoxiangongsiimage;
@property (weak, nonatomic) IBOutlet UILabel *baoxiangongsiname;
@property (weak, nonatomic) IBOutlet UILabel *totleprice;
@property (weak, nonatomic) IBOutlet UILabel *carnumber;
@property (weak, nonatomic) IBOutlet UILabel *ownername;
@property (weak, nonatomic) IBOutlet UILabel *owncard;
@property (weak, nonatomic) IBOutlet UILabel *area;
@property (weak, nonatomic) IBOutlet UILabel *baoxianqixian;
@property (weak, nonatomic) IBOutlet UILabel *toubaoren;
@property (weak, nonatomic) IBOutlet UILabel *beibaoxianren;
@property (weak, nonatomic) IBOutlet UILabel *shoujianren;
@property (weak, nonatomic) IBOutlet UILabel *shoujianrenphone;
@property (weak, nonatomic) IBOutlet UILabel *shoujianrenaddress;
@property (weak, nonatomic) IBOutlet UILabel *uptotleprice;
@property (weak, nonatomic) IBOutlet UILabel *usered;
@property (weak, nonatomic) IBOutlet UILabel *youhuiquan;
@property (weak, nonatomic) IBOutlet UILabel *xiadanshijian;
@property (weak, nonatomic) IBOutlet UIView *xianzhongview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@end

@implementation OrderinfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.uiisopen = YES;
    
    if ([self.orderinfo.orderstats isEqualToString:@"1"]) {
        self.orderstats.text = @"提交成功";
    }else if ([self.orderinfo.orderstats isEqualToString:@"2"]){
        self.orderstats.text = @"出单成功";
    }else{
        self.orderstats.text = @"已取消";
    }
    self.orderid.text = [NSString stringWithFormat:@"订单号:%@",self.orderinfo.ordernumber];
    self.totleprice.text = [NSString stringWithFormat:@"￥%@",[Checkshuju checkshuju:self.orderinfo.orderpriace]];
    self.uptotleprice.text = [Checkshuju checkshuju:self.orderinfo.orderpriace];
    self.carnumber.text = self.orderinfo.ordercarnumber;
    self.ownername.text = self.orderinfo.ordercarownname;
    self.owncard.text = self.orderinfo.ordercarownid;
    self.area.text = self.orderinfo.orderarea;
    
    self.toubaoren.text = self.orderinfo.ordertoubaoren;
    self.beibaoxianren.text = self.orderinfo.orderbeitoubaoren;
    self.shoujianren.text = self.orderinfo.ordershoujianren;
    
    self.shoujianrenphone.text = self.orderinfo.orderphone;
    self.shoujianrenaddress.text = self.orderinfo.orderaddress;
    
    
    if ([self.orderinfo.useRedAmount length]>0) {
       self.usered.text = [Checkshuju checkshuju:self.orderinfo.useRedAmount];
    }else{
        self.usered.text = @"0.00";
    }
    if ([self.orderinfo.useAmount length]>0) {
        self.youhuiquan.text = [Checkshuju checkshuju:self.orderinfo.useAmount];
    }else{
        self.youhuiquan.text = @"0.00";
    }
    
    self.xiadanshijian.text = [NSString stringWithFormat:@"下单时间:%@",self.orderinfo.orderxiadanshijian];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* inputDate = [inputFormatter dateFromString:self.orderinfo.orderbaoxianqixian];
    NSInteger leng = [self getNumberOfDaysOneYear:inputDate];
    NSDate *nextyear = [NSDate dateWithTimeIntervalSinceNow:leng*24*60*60];
    NSString* date = [self stringFromFomate:nextyear formate:@"yyyy-MM-dd"];
    
    self.baoxianqixian.text = [NSString stringWithFormat:@"%@至%@",self.orderinfo.orderbaoxianqixian,date];

    for (int i = 0; i<self.orderinfo.xianzhongname.count; i++) {
        UIImageView* logo = [[UIImageView alloc]initWithFrame:CGRectMake(15, i*20, 20, 20)];
        UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(Screen.bounds.size.width/4, i*20, 100, 20)];
        name.text = self.orderinfo.xianzhongname[i];
        UILabel* price = [[UILabel alloc]initWithFrame:CGRectMake(Screen.bounds.size.width/2, i*20, 100, 20)];
        price.text = self.orderinfo.xianzhongprice[i];
        [self.xianzhongview addSubview:logo];
        [self.xianzhongview addSubview:name];
        [self.xianzhongview addSubview:price];
        
    }


}
-(void)PayViewcancelMenumehod{
    UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"是否取消订单?" delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    al.delegate =self;
    [al show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self canceldingdan];
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
-(void)canceldingdan{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/order/update/%@",BaseUrl,[self.orderid.text substringFromIndex:4]];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"cancel%@",[json objectForKey:@"message"]);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"订单已取消"];
            }
            //添加 字典，将label的值通过key值设置传递
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"取消订单",@"cancelorder", nil];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"canceltoorder" object:nil userInfo:dict];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
            [self.navigationController popViewControllerAnimated:YES];
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
-(void)PayViewpayMenumehod{
    if ([self.orderinfo.shangyexianbaodanhao length]>0) {
        [self performSegueWithIdentifier:@"Infotonobaodan" sender:[NSString stringWithFormat:@"%@-%@",self.orderinfo.ordernumber,self.orderinfo.shangyexianbaodanhao]];
    }else{
        [self performSegueWithIdentifier:@"Infotochudan" sender:[NSString stringWithFormat:@"%@-%@",self.orderinfo.ordernumber,self.orderinfo.shangyexianbaodanhao]];
    }
}
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSString *str = [formatter stringFromDate:date];
    
    return str;
}
-(NSInteger)getNumberOfDaysOneYear:(NSDate *)date{
    NSCalendar *calender = [NSCalendar currentCalendar];
    NSRange range = [calender rangeOfUnit:NSDayCalendarUnit inUnit:NSCalendarUnitYear forDate:date];
    return range.length - 1;
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1&&indexPath.row == 0){
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/9;
        }else if (Screen.bounds.size.height==568){
            
            //self.orderinfo.xianzhongname.count
            return Screen.bounds.size.height/10;
        }else{
            return Screen.bounds.size.height/12;
        }
    }else if (indexPath.section == 3&&indexPath.row == 0){
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/9;
        }else if (Screen.bounds.size.height==568){
            return Screen.bounds.size.height/10;
        }else{
            return Screen.bounds.size.height/12;
        }
    }else if (indexPath.section == 4&&indexPath.row == 2){
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/9;
        }else if (Screen.bounds.size.height==568){
            return Screen.bounds.size.height/10;
        }else{
            return Screen.bounds.size.height/12;
        }
    }else if (indexPath.section == 0&&indexPath.row == 0){
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/9;
        }else if (Screen.bounds.size.height==568){
            return Screen.bounds.size.height/10;
        }else{
            return Screen.bounds.size.height/12;
        }
    }else if (indexPath.section == 5&&indexPath.row == 1){
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/6;
        }else if (Screen.bounds.size.height==568){
            return Screen.bounds.size.height/7;
        }else{
            return Screen.bounds.size.height/9;
        }
    }else{
        if (Screen.bounds.size.height==480){
            return Screen.bounds.size.height/11;
        }else if (Screen.bounds.size.height==568){
            return Screen.bounds.size.height/12.5;
        }else{
            return Screen.bounds.size.height/15;
        }
    }
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell8 = [self.tableView dequeueReusableCellWithIdentifier:@"cell8"];
    UITableViewCell* cell9 = [self.tableView dequeueReusableCellWithIdentifier:@"cell9"];
    UITableViewCell* cell10 = [self.tableView dequeueReusableCellWithIdentifier:@"cell10"];
    if (indexPath.section == 2&&indexPath.row == 0){
        self.uiisopen = !self.uiisopen;
        if (self.uiisopen) {
            [cell8 setHidden:YES];
            [cell9 setHidden:YES];
            [cell10 setHidden:YES];
            [self.uap setImage:[UIImage imageNamed:@"close"]];
            [self.tableView reloadData];
        }else{
            [cell8 setHidden:NO];
            [cell9 setHidden:NO];
            [cell10 setHidden:NO];
            [self.uap setImage:[UIImage imageNamed:@"open"]];
            [self.tableView reloadData];
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    if ([self.orderstats.text isEqualToString:@"提交成功"]) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PayView" owner:nil options:nil]; //&1
        self.payview = [views lastObject];
        self.payview.delegate = self;
        self.payview.frame = CGRectMake(0, Screen.bounds.size.height, Screen.bounds.size.width, Screen.bounds.size.height/15);
        [[UIApplication sharedApplication].keyWindow addSubview:self.payview];
        [UIView animateWithDuration:0.2 animations:^{
            self.payview.frame = CGRectMake(0, Screen.bounds.size.height-Screen.bounds.size.height/15, Screen.bounds.size.width, Screen.bounds.size.height/15);
        }];
    }

}

-(void)viewWillDisappear:(BOOL)animated{
    if ([self.orderstats.text isEqualToString:@"提交成功"]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.payview.frame = CGRectMake(0, Screen.bounds.size.height, Screen.bounds.size.width, Screen.bounds.size.height/15);
        } completion:^(BOOL finished) {
            [self.payview removeFromSuperview];
        }];
    }

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section ==1) {
        return 4+2;
    }else if(self.uiisopen&&section ==2){
        return [super tableView:tableView numberOfRowsInSection:section] - 3;
    }else{
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Infotonobaodan"]) {
        PutareadyTableViewController* pavc = segue.destinationViewController;
        pavc.orderid = sender;
    }else if ([segue.identifier isEqualToString:@"Infotochudan"]){
        PutorderTableViewController* povc = segue.destinationViewController;
        povc.ordernumber = sender;
    }
}


@end
