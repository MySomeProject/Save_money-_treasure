//
//  NewsTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/13.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "NewsTableViewController.h"
#import "NewsTableViewCell.h"
#import "NewimagesTableViewCell.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "Newmessage.h"
#import "NewinfoViewController.h"
@interface NewsTableViewController ()
@property(nonatomic,retain)NSMutableArray* news;
@property(nonatomic)int page;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@end

@implementation NewsTableViewController
-(void)viewWillAppear:(BOOL)animated{

    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.news = [NSMutableArray array];
    [self NaviInit];
    // 2.集成刷新控件
    [self setupRefresh];
}

-(void)newsforhttp{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"page":[NSString stringWithFormat:@"%d",self.page],@"typeid":@"2"};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/news/lastnews",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"acconuts%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* acconts = [[[json objectForKey:@"datas"]objectForKey:@"lastnews"]objectForKey:@"content"];
            if (acconts.count>0) {
                for (NSDictionary* newmessageinfo in acconts) {
                    Newmessage* newmess = [[Newmessage alloc]init];
                    newmess.time = [NSString stringWithFormat:@"%@",[newmessageinfo objectForKey:@"createTime"]];
                    newmess.title = [NSString stringWithFormat:@"%@",[newmessageinfo objectForKey:@"title"]];
                    newmess.idbiaoshi = [NSString stringWithFormat:@"%@",[newmessageinfo objectForKey:@"id"]];
                    newmess.image = [NSString stringWithFormat:@"%@",[newmessageinfo objectForKey:@"picUrl"]];
                    newmess.name = [NSString stringWithFormat:@"%@",[newmessageinfo objectForKey:@"name"]];
                    [self.news addObject:newmess];
                }
            }else{
                self.page--;
            }
        }

        if (self.page == 1) {
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView headerEndRefreshing];
        }else{
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
        }
        // 刷新表格
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.page == 1) {
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView headerEndRefreshing];
        }else{
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
        }
        NSLog(@"%@",error);
    }];
    
}
- (IBAction)back:(UIButton *)sender {
        [self.navigationController popViewControllerAnimated:YES];
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
    [self.tableView headerBeginRefreshing];
    
    
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
    [self.news removeAllObjects];
    [self newsforhttp];
    
}

- (void)footerRereshing
{
    // 1.添加假数据
    self.page ++;
    [self newsforhttp];
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
//navi初始化
-(void)NaviInit{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
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
    return self.news.count;
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return 0.1;
}
//返回tabeview尾的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Newmessage* new = self.news[indexPath.row];
    if ([new.image length]>0) {
        NewimagesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newimages" forIndexPath:indexPath];
        cell.title.text = new.name;
        cell.time.text = new.time;
        cell.content.text = new.title;
        [cell.image setImageWithURL:[NSURL URLWithString:new.image] placeholderImage:[UIImage imageNamed:@"bG-logo"]];
        return cell;
    }else{
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"news" forIndexPath:indexPath];
        cell.title.text = new.name;
        cell.time.text = new.time;
        cell.content.text = new.title;
        return cell;
    }

    
    // Configure the cell...
    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Newmessage* new = self.news[indexPath.row];
    if ([new.image length]>0) {
        if (Screen.bounds.size.width==320) {
            return Screen.bounds.size.height/3;
        }else{
            return Screen.bounds.size.height/4.3;
        }
    }else{
        if (Screen.bounds.size.width==320) {
            return Screen.bounds.size.height/4;
        }else{
            return Screen.bounds.size.height/6;
        }
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //开启自定义左baritem的手势返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    Newmessage* ne = self.news[indexPath.row];
    
    [self performSegueWithIdentifier:@"Newinfo" sender:ne];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Newinfo"]) {
        NewinfoViewController* new = segue.destinationViewController;
        new.message = sender;
    }
}


@end
