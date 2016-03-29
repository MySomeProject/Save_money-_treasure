//
//  CheckinfoTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/21.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CheckinfoTableViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
#import "Utils.h"
#import "MJRefresh.h"
#import "CheckinfoTableViewCell.h"
#import "Weizhanginfo.h"
#import "Noweizhang.h"
@interface CheckinfoTableViewController ()
@property(nonatomic,retain)Noweizhang* noweizhang;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)NSMutableArray *weizhanginfos;
@property(nonatomic,copy)NSString *shengcode;
@property(nonatomic,copy)NSString *shicode;
@property(nonatomic,copy)NSString *carnmuber;
@property(nonatomic,copy)NSString *chejiahao;
@property(nonatomic,copy)NSString *fadongjihao;
@property(nonatomic)int page;
@property (weak, nonatomic) IBOutlet UILabel *uplabel;
@end

@implementation CheckinfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    // 2.集成刷新控件
    [self setupRefresh];
    self.weizhanginfos = [NSMutableArray array];
    self.carnmuber = [self.canshu objectForKey:@"platesNumber"];
    self.chejiahao = [self.canshu objectForKey:@"vehicleIdentificationNumber"];
    self.fadongjihao = [self.canshu objectForKey:@"engineNumber"];
    self.shengcode = [self.canshu objectForKey:@"provinceCode"];
    self.shicode = [self.canshu objectForKey:@"cityCode"];
    NSString* carheard = [self.carnmuber substringToIndex:2];
    NSString* carfoot = [self.carnmuber substringFromIndex:2];
    self.navigationItem.title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Ctocitytongzhi:) name:@"Ctocity" object:nil];
    
    [self newcarcheckweizhang];

}
//调用弹框视图
- (void)addnullpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Noweizhang" owner:nil options:nil]; //&1
    self.noweizhang = [views lastObject];
    [self.noweizhang addpopview:self.noweizhang andtitle:title];
    [self.view addSubview:self.noweizhang];
    
}
/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    //    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    // dateKey用于存储刷新时间，可以保证不同界面拥有不同的刷新时间
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing) dateKey:@"table"];
    //[self.tableView headerBeginRefreshing];
    
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉刷新更多数据";
    self.tableView.headerReleaseToRefreshText = @"松开马上刷新";
    self.tableView.headerRefreshingText = @"刷新中...";
    
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载";
    self.tableView.footerRefreshingText = @"加载中...";
}
#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    
    // 1.添加假数据
    self.page = 1;
    self.canshu = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnmuber,@"engineNumber":self.fadongjihao,@"vehicleIdentificationNumber":self.chejiahao,@"page":[NSString stringWithFormat:@"%d",self.page]};
    [self.weizhanginfos removeAllObjects];
    [self newcarcheckweizhang];
    
}

- (void)footerRereshing
{
    // 1.添加假数据
    self.page ++;
    self.canshu = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnmuber,@"engineNumber":self.fadongjihao,@"vehicleIdentificationNumber":self.chejiahao,@"page":[NSString stringWithFormat:@"%d",self.page]};
    [self newcarcheckweizhang];
}
- (void)Ctocitytongzhi:(NSNotification *)text{
    [self.weizhanginfos removeAllObjects];
    self.page = 1;
    NSString* city = [text.userInfo objectForKey:@"Ccity"];
    NSArray* citys = [city componentsSeparatedByString:@"-"];
    self.shengcode = citys[0];
    self.shicode = citys[1];
    self.canshu = @{@"provinceCode":self.shengcode,@"cityCode":self.shicode,@"platesNumber":self.carnmuber,@"engineNumber":self.fadongjihao,@"vehicleIdentificationNumber":self.chejiahao,@"page":[NSString stringWithFormat:@"%d",self.page]};
    [self newcarcheckweizhang];
}
- (IBAction)selectcheck:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Selectcheck" sender:nil];
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
//新车查违章
-(void)newcarcheckweizhang{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.canshu options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/violation/query",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"check%@",json);
        NSLog(@"%@",[json objectForKey:@"message"]);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* weizhanginfo = [[[json objectForKey:@"datas"] objectForKey:@"violations"] objectForKey:@"content"];
            
            if (weizhanginfo.count==5) {
                self.uplabel.text = @"上拉加载更多违章信息";
            }else{
                self.uplabel.text = @"已经是全部违章信息";
            }
            
            for (NSDictionary* weiinfo in weizhanginfo) {
                Weizhanginfo* wio = [[Weizhanginfo alloc]init];
                wio.time = [NSString stringWithFormat:@"%@",[weiinfo objectForKey:@"time"]];
                wio.info = [NSString stringWithFormat:@"%@",[weiinfo objectForKey:@"area"]];
                wio.kind = [NSString stringWithFormat:@"%@",[weiinfo objectForKey:@"act"]];
                wio.score = [NSString stringWithFormat:@"%@/%@",[weiinfo objectForKey:@"money"],[weiinfo objectForKey:@"fen"]];
                [self.weizhanginfos addObject:wio];
            }
            
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            [al show];
        }
        [self.tableView reloadData];
        if (self.page == 1) {
            if (self.weizhanginfos.count == 0) {
                [self addnullpopview:@"~您没有违章信息~"];
            }else{
                [self.noweizhang removeFromSuperview];
            }
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView headerEndRefreshing];
        }else{
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
        }
        [self deleteView];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
    }];
}

//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
//返回tabeview尾的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooderInSection:(NSInteger)section{
    return 0.01;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.weizhanginfos.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckinfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Weizhanginfo* w = self.weizhanginfos[indexPath.row];
    cell.time.text = w.time;
    cell.info.text = w.info;
    cell.kind.text = w.kind;
    cell.scoe.text = w.score;
    return cell;
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
