//
//  YouhuiquanTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "YouhuiquanTableViewController.h"
#import "YouhuiquanTableViewCell.h"
#import "Utils.h"
#import <AFHTTPRequestOperationManager.h>
#import <CommonCrypto/CommonDigest.h>
#import "Lloadview.h"
#import "Youhuiquaninfo.h"
#import "NullView.h"
#import "youhuijuanShuoming.h"
@interface YouhuiquanTableViewController ()
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSMutableArray *youhuiquans;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)NullView* nullview;
@end

@implementation YouhuiquanTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.youhuiquans = [NSMutableArray array];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self youhuiquanforhttp];
    
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
//调用弹框视图
- (void)addnullpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NullView" owner:nil options:nil]; //&1
    self.nullview = [views lastObject];
    [self.nullview addpopview:self.nullview andtitle:title andbutitle:nil];
    [self.view addSubview:self.nullview];
    
}
-(void)youhuiquanforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/member/getcoupons",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"youhuiquan%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            NSArray* coupons = [[json objectForKey:@"datas"] objectForKey:@"coupons"];
            for (NSDictionary* youhuiquan in coupons) {
                Youhuiquaninfo* yinfo = [[Youhuiquaninfo alloc]init];
                yinfo.name = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"name"]];
                yinfo.detail = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"detail"]];
                yinfo.money = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"money"]];
                yinfo.overdue = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"overdue"]];
                yinfo.useAmount = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"useAmount"]];
                yinfo.createTime = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"createTime"]];
                yinfo.expiryDate = [NSString stringWithFormat:@"%@",[youhuiquan objectForKey:@"expiryDate"]];
                [self.youhuiquans addObject:yinfo];
            }
        }
        [self.tableView reloadData];
        if (self.youhuiquans.count == 0) {
            [self addnullpopview:@"还没有可用的优惠券哦~"];
        }else{
            [self.nullview removeFromSuperview];
        }
        [self deleteView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
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
    return self.youhuiquans.count;
}

- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YouhuiquanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Youhuiquaninfo* yinfo = self.youhuiquans[indexPath.row];
    cell.money.text = yinfo.money;
    cell.zhucesong.text = yinfo.name;
    cell.usekind.text = yinfo.detail;
    cell.time.text = [NSString stringWithFormat:@"有效期:%@至%@",yinfo.createTime,yinfo.expiryDate];
    if ([yinfo.overdue intValue] == 1) {
        cell.bgimage.image = [UIImage imageNamed:@"TICKET-FAIL"];
        cell.isguoqi.hidden = NO;
        cell.money.textColor = [UIColor lightGrayColor];
        cell.zhucesong.textColor = [UIColor lightGrayColor];
        cell.usekind.textColor = [UIColor lightGrayColor];
        cell.time.textColor = [UIColor lightGrayColor];
        cell.yuan.textColor = [UIColor lightGrayColor];
    }else{
        cell.bgimage.image = [UIImage imageNamed:@"TICKET-USE"];
        cell.isguoqi.hidden = YES;
        cell.money.textColor = [UIColor colorWithRed:251.0/255 green:88.0/255 blue:88.0/255 alpha:1];
        cell.zhucesong.textColor = [UIColor colorWithRed:251.0/255 green:88.0/255 blue:88.0/255 alpha:1];
        cell.usekind.textColor = [UIColor blackColor];
        cell.time.textColor = [UIColor blackColor];
        cell.yuan.textColor = [UIColor colorWithRed:251.0/255 green:88.0/255 blue:88.0/255 alpha:1];
    }
    
    return cell;
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}
#pragma mark 优惠劵规则按钮
- (IBAction)youhuijuanshuoming:(UIButton *)sender {
    
    NSArray *youhuijuanView = [[NSBundle mainBundle] loadNibNamed:@"youhuijuanShuoming" owner:nil options:nil]; //&1
    youhuijuanShuoming* youhui = [youhuijuanView lastObject];
    youhui.frame = self.view.frame;
    [self.view addSubview:youhui];
    
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
