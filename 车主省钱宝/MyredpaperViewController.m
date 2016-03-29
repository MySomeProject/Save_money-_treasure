//
//  MyredpaperViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/16.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MyredpaperViewController.h"
#import "Utils.h"
#import "MJRefresh.h"
#import "SelectCarView.h"
#import "NullView.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Redpaper.h"
#import "MyredpaperinfoTableViewCell.h"
#import "AppDelegate.h"
#import "Lloadview.h"
#import "MainInfo.h"
#import "CPTableViewController.h"
#import "Checkshuju.h"
#import "ShuomingRedpaper.h"
@interface MyredpaperViewController ()<SelectCarViewdelegate,NullViewdelegate>
@property (weak, nonatomic) IBOutlet UITableView *subtableview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NullView* nullview;
@property(nonatomic,retain)NSMutableArray* redpapers;
@property(nonatomic,retain)SelectCarView* selectCarView;
@property (weak, nonatomic) IBOutlet UIButton *selectdecar;
@property(nonatomic)int page;
@property(nonatomic)int carpage;
@property(nonatomic,copy)NSString* carid;
@property (weak, nonatomic) IBOutlet UILabel *redpapaerlabel;
@property (weak, nonatomic) IBOutlet UILabel *yingxiaolabel;
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UIView *downview;
@end

@implementation MyredpaperViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];

    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appdelegate.totlepaper floatValue]>0) {
        self.downview.hidden = NO;
    }else{
        self.downview.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.totlepaper) {
        [self.redpapaerlabel setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"￥%@",appdelegate.totlepaper]]];
    }else{
        [self.redpapaerlabel setText:@"￥0.00"];
    }
    if (appdelegate.carlist.count>0) {
        MainInfo* m = appdelegate.carlist[0];
        if ((appdelegate.carlist.count==2)&&([m.carnumber length]>0)) {
            MainInfo* m = appdelegate.carlist[0];
            NSString* carheard = [m.carnumber substringToIndex:2];
            NSString* carfoot = [m.carnumber substringFromIndex:2];
            NSString* title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
            [self.selectdecar setTitle:title forState:UIControlStateNormal];
            self.carid = m.carid;
            self.redpapaerlabel.text = [NSString stringWithFormat:@"￥%@",m.totleredpaper];
        }
    }
    self.redpapers = [NSMutableArray array];
    [self NaviTitle];
    self.page = 1;
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 2.集成刷新控件
    [self setupRefresh];
    [self redpaperforhttp];
    
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
-(void)SelectCarViewMenumehod:(NSString *)text{
    if (text) {
        NSArray* texts = [text componentsSeparatedByString:@"-"];
        if (texts[1]) {
            [self.redpapaerlabel setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"￥%@",texts[1]]]];
        }else{
            [self.redpapaerlabel setText:@"￥0.00"];
        }
        NSString* carnumber = [texts[0] substringToIndex:7];
        self.carid = [texts[0] substringFromIndex:7];
        NSString* carheard = [carnumber substringToIndex:2];
        NSString* carfoot = [carnumber substringFromIndex:2];
        NSString* title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
        [self.selectdecar setTitle:title forState:UIControlStateNormal];
        self.page = 1;
        [self redpaperforhttp];
        
    }
}

-(void)redpaperforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSDictionary* parameter;
    if (self.carid) {
        parameter = @{@"page":[NSString stringWithFormat:@"%d",self.page],@"types":@[@{@"type":@"2"}],@"carid":self.carid};
    }else{
        parameter = @{@"page":[NSString stringWithFormat:@"%d",self.page],@"types":@[@{@"type":@"2"}]};
    }
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/cashledger/findmembercashledgerlist",BaseUrl];
    
    NSLog(@"%@%@",url,getcodejson);
    
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"redpaperforhttp%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* redlist = [[[json objectForKey:@"datas"]objectForKey:@"memberCashLedger"] objectForKey:@"content"];
            if (redlist.count>0) {
                for (NSDictionary* repaper in redlist) {
                    Redpaper* redpaperinfo = [[Redpaper alloc]init];
                    redpaperinfo.carid = [NSString stringWithFormat:@"%@",[repaper objectForKey:@"carId"]];
                    redpaperinfo.carnumber = [NSString stringWithFormat:@"%@",[repaper objectForKey:@"carName"]];
                    redpaperinfo.time = [NSString stringWithFormat:@"%@",[repaper objectForKey:@"createTime"]];
                    redpaperinfo.title = [NSString stringWithFormat:@"%@",[repaper objectForKey:@"desca"]];
                    redpaperinfo.carnumber = [NSString stringWithFormat:@"%@",[repaper objectForKey:@"platesNumber"]];
                    if ([[NSString stringWithFormat:@"%@",[repaper objectForKey:@"inCome"]] floatValue]>0) {
                        redpaperinfo.info = [NSString stringWithFormat:@"+%@",[Checkshuju checkshuju:[repaper objectForKey:@"inCome"] ]];
                    }
                    if ([[NSString stringWithFormat:@"%@",[repaper objectForKey:@"expenditure"]] floatValue]>0) {
                        redpaperinfo.info = [NSString stringWithFormat:@"-%@",[Checkshuju checkshuju:[repaper objectForKey:@"expenditure"] ]];
                    }
                    [self.redpapers addObject:redpaperinfo];
                }  
            }else{
                self.page--;
            }
            
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
                        al.delegate =self;
            [al show];
        }

        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.subtableview footerEndRefreshing];
        if (self.redpapers.count == 0) {
                [self addpopview:@"还没有红包哦~                   绿色出行，一键泊车赚收益"];
        }else{
                [self.nullview removeFromSuperview];
        }
        // 刷新表格
        [self.subtableview reloadData];
        [self deleteView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.subtableview footerEndRefreshing];
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

//调用弹框视图
- (void)addpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NullView" owner:nil options:nil]; //&1
    self.nullview = [views lastObject];
    [self.nullview addpopview:self.nullview andtitle:title andbutitle:@"去看看"];
    self.nullview.frame = CGRectMake(0, self.subtableview.bounds.size.height/10, self.view.bounds.size.width, self.subtableview.bounds.size.height);
    self.nullview.delegate = self;
    [self.subtableview addSubview:self.nullview];

    
}
-(void)NullViewMenumehod{
    //添加 字典，将label的值通过key值设置传递
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录停驶",@"loginmainstop", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"logintomaintostop" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self performSegueWithIdentifier:@"Redpapertotingshi" sender:nil];
}
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.subtableview addFooterWithTarget:self action:@selector(footerRereshing)];
    self.subtableview.footerPullToRefreshText = @"上拉加载更多数据";
    self.subtableview.footerReleaseToRefreshText = @"松开马上加载";
    self.subtableview.footerRefreshingText = @"加载中...";
}

- (void)footerRereshing
{
    // 1.添加假数据
    self.page ++;
    [self redpaperforhttp];
}
//设置navi的标题
-(void)NaviTitle{    
    //查看车辆
    NSArray *selectCarViews = [[NSBundle mainBundle] loadNibNamed:@"SelectCarView" owner:nil options:nil]; //&1
    self.selectCarView = [selectCarViews lastObject];
    self.selectCarView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    self.selectCarView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:self.selectCarView];
    
}
//回退
- (IBAction)back:(UIButton *)sender {
    if (self.navigationController.viewControllers.count<4) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)checkmycar:(UIButton *)sender {
    [self.redpapers removeAllObjects];
    self.selectCarView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.selectCarView.frame = self.view.frame;
        
    } completion:^(BOOL finished) {
        self.selectCarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.redpapers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Redpaper* red = self.redpapers[indexPath.row];
    MyredpaperinfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subcell" forIndexPath:indexPath];
    cell.time.text = red.time;
    cell.carnumber.text = [NSString stringWithFormat:@"%@•%@",[red.carnumber substringToIndex:2],[red.carnumber substringFromIndex:2]];
    cell.score.text = red.info;
    cell.kind.text = red.title;
    return cell;

}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)gotobijia:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Redtobijia" sender:[NSString stringWithFormat:@"%@-%@",self.selectdecar.titleLabel.text,self.carid]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Redtobijia"]) {
        CPTableViewController* cvc = [segue destinationViewController];
        cvc.carinfo = sender;
    }
}
#pragma mark 红包使用按钮说明
- (IBAction)shuoming:(UIButton *)sender {
    NSArray *ShuomingRedpaperViews = [[NSBundle mainBundle] loadNibNamed:@"ShuomingRedpaper" owner:nil options:nil]; //&1
    ShuomingRedpaper* shuomingredpaper = [ShuomingRedpaperViews lastObject];
    shuomingredpaper.frame = self.view.frame;
    [self.view addSubview:shuomingredpaper];
}


@end
