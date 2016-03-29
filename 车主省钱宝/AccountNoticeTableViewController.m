//
//  AccountNoticeTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "AccountNoticeTableViewController.h"
#import "AccountNoticeTableViewCell.h"
#import "Utils.h"
#import "MJRefresh.h"
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import <CommonCrypto/CommonDigest.h>
#import "Messageinfo.h"
#import "NullView.h"
#import "RedPoint.h"
@interface AccountNoticeTableViewController ()
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSMutableArray *acconuts;
@property(nonatomic,retain)NullView* nullview;
@property(nonatomic)int page;

@end

@implementation AccountNoticeTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.acconuts = [NSMutableArray array];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.page = 1;
    [self accountnoticemessageforhttp];
    // 2.集成刷新控件
    [self setupRefresh];
}
//调用弹框视图
- (void)addpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NullView" owner:nil options:nil]; //&1
    self.nullview = [views lastObject];
    [self.nullview addpopview:self.nullview andtitle:title andbutitle:nil];
    self.nullview.but.hidden = YES;
    [self.view addSubview:self.nullview];
}
-(void)accountnoticemessageforhttp{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    RedPoint *share = [RedPoint shareRedPoint];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"msgType":@"1",@"page":[NSString stringWithFormat:@"%d",self.page]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/msg",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"acconuts%@",json);
        NSArray* acconts = [[[json objectForKey:@"datas"]objectForKey:@"msgs"]objectForKey:@"content"];
        if (acconts.count>0) {
            for (NSDictionary* messageinfo in acconts) {
                Messageinfo* message = [[Messageinfo alloc]init];
                message.time = [NSString stringWithFormat:@"%@",[messageinfo objectForKey:@"createTime"]];
                message.title = [NSString stringWithFormat:@"%@",[messageinfo objectForKey:@"title"]];
                message.content = [NSString stringWithFormat:@"%@",[messageinfo objectForKey:@"content"]];
                message.carid = [NSString stringWithFormat:@"%@",[messageinfo objectForKey:@"id"]];
                message.readFlag = [NSString stringWithFormat:@"%@",[messageinfo objectForKey:@"readFlag"]];
                
                [self.acconuts addObject:message];
                
            }
            
            [share addAccountArray:self.acconuts];
        
        }else{
            self.page--;
        }
        
        if (self.acconuts.count == 0) {
            [self addpopview:@"还没有账户通知哦~"];
        }else{
            [self.nullview removeFromSuperview];
        }
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView footerEndRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
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

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{

    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    self.tableView.footerPullToRefreshText = @"上拉加载更多数据";
    self.tableView.footerReleaseToRefreshText = @"松开马上加载";
    self.tableView.footerRefreshingText = @"加载中...";
}
- (void)footerRereshing
{
    self.page++;
    [self accountnoticemessageforhttp];
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

    return self.acconuts.count;
}

//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Messageinfo* messageinfo = self.acconuts[indexPath.row];
    cell.time.text = messageinfo.time;
    cell.title.text = messageinfo.title;
    cell.content.text = messageinfo.content;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
