//
//  StopViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "StopViewController.h"
#import "Utils.h"
#import "StopTableViewCell.h"
#import "UIbuttonStyle.h"
#import "DLYTableViewController.h"
#import "WritecarinfoTableViewController.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
#import "Checkshuju.h"
#import "MainInfo.h"
#import "Popview.h"
#import "StopSelectView.h"
@interface StopViewController ()<StopTableViewCelldelegate,StopSelectViewdelegate>
@property(nonatomic,retain)StopSelectView* stopSelectView;
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *shouyi;
@property(nonatomic,retain)NSMutableArray* times;
@property(nonatomic,copy)NSString* text;
@property(nonatomic,retain)NSMutableArray* vlaues;
@property(nonatomic,retain)NSMutableArray* keys;
@property(nonatomic,retain)NSArray* selects;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)NSDictionary* stopshouyi;
@property(nonatomic,retain)UIButton *titleLabel;
@property(nonatomic,retain)UIImageView *jiantou;
@property (weak, nonatomic) IBOutlet UILabel *yuqizongshouyi;
@end

@implementation StopViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bar640X128"] forBarMetrics:UIBarMetricsDefault];
    if ([self.titleLabel.titleLabel.text length]>0) {
        self.titleLabel.userInteractionEnabled = YES;
    }else{
        self.titleLabel.userInteractionEnabled = NO;
    }
    if ([self.titleLabel.titleLabel.text length]>0) {
        self.jiantou.hidden = NO;
    }else{
        self.jiantou.hidden = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self Naviinit];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.vlaues = [NSMutableArray array];
    self.keys = [NSMutableArray array];
    for (int i = 24; i<169; i+=24) {
        NSDate *time = [NSDate dateWithTimeIntervalSinceNow:i*60*60];
        NSString* day = [self stringFromFomate:time formate:@"yyyy-MM-dd"];
        [self.keys addObject:day];
    }
    [self timecount];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logintomaintostoptongzhi:) name:@"logintomaintostop" object:nil];
    
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0) {
        MainInfo* m = appdelegate.carlist[0];
        if ([userinfo objectForKey:@"logincode"]&&[m.carid length]>0) {
            [self getstopforhttp];
        }
    }

    [self getshouyiseven];
    // Do any additional setup after loading the view.
}
- (void)logintomaintostoptongzhi:(NSNotification *)text{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0) {
        MainInfo* m = appdelegate.carlist[0];
        if ([m.carnumber length]>0) {
            NSString *carnumber1 = [m.carnumber substringToIndex:2];
            NSString *carnumber2 = [m.carnumber substringWithRange:NSMakeRange(2,5)];
            NSString* car = [NSString stringWithFormat:@"%@•%@",carnumber1,carnumber2];
            [self.titleLabel setTitle:car forState:UIControlStateNormal];
            self.caridforhttp = m.carid;
            [self getstopforhttp];
            if ([self.titleLabel.titleLabel.text length]>0) {
                self.titleLabel.userInteractionEnabled = YES;
                self.jiantou.hidden = NO;
            }else{
                self.titleLabel.userInteractionEnabled = NO;
                self.jiantou.hidden = YES;
            }
        }else{
            [self.titleLabel setTitle:@"" forState:UIControlStateNormal];
        }
    }

}
-(void)getshouyiseven{
    if (!self.loadview) {
           [self delayView];
    }
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/member/stop/getexpectedearningdata",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"stopdddddd%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            self.stopshouyi = [[json objectForKey:@"datas"] objectForKey:@"earn"];
            [self StopTableViewCellMenumehod];
        }
        [self deleteView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
}
-(void)StopTableViewCellMenumehod{
    StopTableViewCell* cell1 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    StopTableViewCell* cell2 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    StopTableViewCell* cell3 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    StopTableViewCell* cell4 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    StopTableViewCell* cell5 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    StopTableViewCell* cell6 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    StopTableViewCell* cell7 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    NSArray* stopdays = @[cell1,cell2,cell3,cell4,cell5,cell6,cell7];
    int i = 0;
    for (StopTableViewCell* cell in stopdays) {
        if (cell.stopbtu.selected) {
            i++;
        }
    }
    switch (i) {
        case 0:
            [self.yuqizongshouyi setText:@"预期总收益(元):0.00"];
            [self.shouyi setText:@"0.00"];
            break;
        case 1:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"one"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"one"]] floatValue]]]];
            break;
        case 2:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"two"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"two"]] floatValue]/2]]];

            break;
        case 3:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"three"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"three"]] floatValue]/3]]];
            break;
        case 4:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"four"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"four"]] floatValue]/4]]];

            break;
        case 5:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"five"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"five"]] floatValue]/5]]];

            break;
        case 6:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"six"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"six"]] floatValue]/6]]];
            break;
        case 7:
            [self.yuqizongshouyi setText:[NSString stringWithFormat:@"预期总收益(元):%@",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"seven"]]]]];
            [self.shouyi setText:[Checkshuju checkshuju:[NSString stringWithFormat:@"%lf",[[NSString stringWithFormat:@"%@",[self.stopshouyi objectForKey:@"seven"]] floatValue]/7]]];
            
            break;
            
        default:
            break;
    }
    [self.delegate123 chuanzhi:self.shouyi.text];

}

//
//调用弹框视图
- (void)addpopview:(NSString*)title{
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
}
-(void)alwgoto{
    NSMutableArray* stopdays = [NSMutableArray array];
    for (int i = 0; i<7; i++) {
        StopTableViewCell* cell = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell.stopbtu.selected) {
            [stopdays addObject:cell];
        }
    }
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    MainInfo* m = appdelegate.carlist[0];
    if ([m.carnumber length]==0) {
        if (stopdays.count==0) {
            //定义弹框次数
            if (self.popview.superview == nil) {
                [self addpopview:@"请设置停驶日期"];
            }
        }else{
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"您还没有完善车辆信息，快去完善吧!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            al.delegate =self;
            al.tag = 100;
            [al show];
        }
        
    }else{
        if (!([appdelegate.totlepaper floatValue] >0)) {
            if (stopdays.count==0) {
                //定义弹框次数
                if (self.popview.superview == nil) {
                    [self addpopview:@"还没有设置停驶计划哦"];
                }
            }else{
                [self setstopforhttp];
            }
        }

    }
}

-(void)timecount{
    self.times = [NSMutableArray array];
    for (int i = 24; i<169; i+=24) {
        NSDate *time = [NSDate dateWithTimeIntervalSinceNow:i*60*60];
        NSString* day = [self stringFromFomate:time formate:@"MM.dd"];
        NSString* week = [self weekdayStringFromDate:time];
        NSString* dayandweek = [NSString stringWithFormat:@"%@/%@",week,day];
        [self.times addObject:dayandweek];
    }
}

- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSWeekdayCalendarUnit;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}
- (NSString*) stringFromFomate:(NSDate*) date formate:(NSString*)formate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSString *str = [formatter stringFromDate:date];
    return str;
}
-(void)Naviinit{
    self.titleLabel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0 , 120, 42)];
    self.titleLabel.backgroundColor = [UIColor clearColor];  //设置Label背景透明
    self.titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:18];  //设置文本字体与大小
    self.titleLabel.titleLabel.textColor = [UIColor whiteColor];  //设置文本颜色
    [self.titleLabel addTarget:self action:@selector(selectcar:) forControlEvents:UIControlEventTouchUpInside];
    if ([self.carid length]>0) {
        NSString *carnumber1 = [self.carid substringToIndex:2];
        NSString *carnumber2 = [self.carid substringWithRange:NSMakeRange(2,5)];
        NSString* car = [NSString stringWithFormat:@"%@•%@",carnumber1,carnumber2];
        [self.titleLabel setTitle:car forState:UIControlStateNormal];
        self.caridforhttp = [self.carid substringFromIndex:8];
    }else{
        [self.titleLabel setTitle:@"" forState:UIControlStateNormal];
    }
    UIView* titleview = [[UIView alloc]initWithFrame:self.titleLabel.frame];
    [titleview addSubview:self.titleLabel];
    self.jiantou = [[UIImageView alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width, self.titleLabel.frame.origin.y+17, 10, 7)];
    self.jiantou.image = [UIImage imageNamed:@"ICON-ARR"];
    [titleview addSubview:self.jiantou];
    self.navigationItem.titleView = titleview;
    
}
-(void)StopSelectViewMenumehod:(NSString *)text{
    self.jiantou.image = [UIImage imageNamed:@"ICON-ARR"];
    self.text = text;
    if (text) {
        if ([[text substringToIndex:4] isEqualToString:@"添加车辆"]) {
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@停驶计划尚未保存,是否保存?",self.titleLabel.titleLabel.text] delegate:self cancelButtonTitle:@"不保存" otherButtonTitles:@"保存", nil];
            al.tag = 10000;
            [al show];
            
        }else{
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@停驶计划尚未保存,是否保存?",self.titleLabel.titleLabel.text] delegate:self cancelButtonTitle:@"不保存" otherButtonTitles:@"保存", nil];
            al.tag = 10001;
            [al show];

        }
    }
}
-(void)selectcar:(UIButton*)sender{
    if (!self.stopSelectView.superview) {
        //查看车辆
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSArray *stopSelectViews = [[NSBundle mainBundle] loadNibNamed:@"StopSelectView" owner:nil options:nil]; //&1
        self.stopSelectView = [stopSelectViews lastObject];
        if ((appdelegate.carlist.count*(Screen.bounds.size.width/8)+64)>=Screen.bounds.size.height) {
            self.stopSelectView.frame = CGRectMake(0, -appdelegate.carlist.count*(Screen.bounds.size.width/8), self.view.frame.size.width, Screen.bounds.size.height-64);
        
        }else{
             self.stopSelectView.frame = CGRectMake(0, -appdelegate.carlist.count*(Screen.bounds.size.width/8), self.view.frame.size.width, appdelegate.carlist.count*(Screen.bounds.size.width/8));
        }
        
        self.stopSelectView.delegate = self;
        [self.view addSubview:self.stopSelectView];
        [self.jiantou setImage:[UIImage imageNamed:@"ICON-ARR-UP"]];
        [UIView animateWithDuration:0.2 animations:^{
            self.stopSelectView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.stopSelectView.frame.size.height);
        }];
    }
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
//返回tabeview尾的高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (Screen.bounds.size.width==320) {
        return self.tableview.frame.size.height/6.5;
    }else{
       return self.tableview.frame.size.height/7;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    // Configure the cell...
    if (indexPath.row == 0) {
        cell.stopday.text = [NSString stringWithFormat:@"%@/明日",self.times[0]];
    }else{
        cell.stopday.text = self.times[indexPath.row];
    }
    if (self.vlaues.count>0) {
        
        if ([self.vlaues[indexPath.row] intValue] == 0) {
            [cell.stopbtu setSelected:NO];
        }else{
            [cell.stopbtu setSelected:YES];
        }
    }
    if(cell.stopbtu.selected)
    {
        [cell.stopbtu setTitle:@"停驶" forState:UIControlStateNormal];
        [UIbuttonStyle UIbuttonStyleNO:cell.stopbtu];
    }else{
        [cell.stopbtu setTitle:@"开车" forState:UIControlStateNormal];
        [UIbuttonStyle UIbuttonStyleDI:cell.stopbtu];
    }
    cell.delegate = self;
    
    return cell;
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

-(void)setstopforhttp{
    if (!self.loadview) {
        [self delayView];
    }
    StopTableViewCell* cell1 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    StopTableViewCell* cell2 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    StopTableViewCell* cell3 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    StopTableViewCell* cell4 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    StopTableViewCell* cell5 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    StopTableViewCell* cell6 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    StopTableViewCell* cell7 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSLog(@"self.caridforhttp%@",self.caridforhttp);
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"carId":self.caridforhttp,@"date":[self stringFromFomate:[NSDate date] formate:@"yyyy-MM-dd"],@"memberstopset":@[@{@"index":@"1",@"isflgt":[NSString stringWithFormat:@"%d",cell1.stopbtu.selected]},@{@"index":@"2",@"isflgt":[NSString stringWithFormat:@"%d",cell2.stopbtu.selected]},@{@"index":@"3",@"isflgt":[NSString stringWithFormat:@"%d",cell3.stopbtu.selected]},@{@"index":@"4",@"isflgt":[NSString stringWithFormat:@"%d",cell4.stopbtu.selected]},@{@"index":@"5",@"isflgt":[NSString stringWithFormat:@"%d",cell5.stopbtu.selected]},@{@"index":@"6",@"isflgt":[NSString stringWithFormat:@"%d",cell6.stopbtu.selected]},@{@"index":@"7",@"isflgt":[NSString stringWithFormat:@"%d",cell7.stopbtu.selected]}]};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    
    
    NSString *url = [NSString stringWithFormat:@"%@/member/stop/setstopinformation",BaseUrl];
            NSLog(@"parameter%@ %@",parameter,url);
    
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"setstophttp%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            //添加 字典，将label的值通过key值设置传递
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"停驶后刷新",@"stopupdate", nil];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"stoptoupdate" object:nil userInfo:dict];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            if (!([appdelegate.totlepaper floatValue]>0)) {
                UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"保存成功，坐等收益到账吧！停驶收益会在停驶计划日的第二天进入到红包账户哦!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                al.tag = 1000;
                [al show];
            }else{
                if (self.popview.superview == nil) {
                    [self addpopview:@"保存成功!"];
                }
                if (![self.text isEqualToString:@"加车保存"]) {
                   [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            
            [self deleteView];
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            [al show];
        }else{
            [self deleteView];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
    }];
}

-(void)getstopforhttp{
    if (!self.loadview.superview) {
          [self delayView];
    }
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"carId":self.caridforhttp};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/member/stop/getstopinformation",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"getstophttp%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            [self.vlaues removeAllObjects];
            self.selects = [[json objectForKey:@"datas"] objectForKey:@"memberStopSet"];
            for (int i = 0; i<self.selects.count; i++) {
                [self.vlaues addObject:[NSString stringWithFormat:@"%d",[[self.selects[i] objectForKey:self.keys[i]] intValue]]];
            }
        }else if([[json objectForKey:@"status"] intValue] == -6){
            UIAlertView* al = [[UIAlertView alloc]initWithTitle:@"" message:@"请重新登录" delegate:self cancelButtonTitle:@"回到首页" otherButtonTitles:@"取消", nil];
            al.delegate =self;
            [al show];
        }
        [self.tableview reloadData];
        [self StopTableViewCellMenumehod];
        [self deleteView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self savenologinstop];
            [self performSegueWithIdentifier:@"Stoptoaddcar" sender:@"停驶加车"];
        }
    }else if (alertView.tag == 1000){
        if (buttonIndex == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }else if (alertView.tag == 10000){
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"Stoptoaddcar" sender:@"添加车辆"];
        }else{
            self.text = @"加车保存";
            [self setstopforhttp];
            [self performSegueWithIdentifier:@"Stoptoaddcar" sender:@"添加车辆"];
        }
    }else if (alertView.tag == 10001){
        if (buttonIndex == 0) {
           NSArray* texts = [self.text componentsSeparatedByString:@"-"];
           NSString* carnumber = texts[0];
           self.caridforhttp = texts[1];
           NSString* carheard = [carnumber substringToIndex:2];
           NSString* carfoot = [carnumber substringFromIndex:2];
           NSString* title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
           [self.titleLabel setTitle:title forState:UIControlStateNormal];
           [self getstopforhttp];
        }else{
            NSArray* texts = [self.text componentsSeparatedByString:@"-"];
            NSString* carnumber = texts[0];
            self.caridforhttp = texts[1];
            NSString* carheard = [carnumber substringToIndex:2];
            NSString* carfoot = [carnumber substringFromIndex:2];
            NSString* title = [NSString stringWithFormat:@"%@•%@",carheard,carfoot];
            [self.titleLabel setTitle:title forState:UIControlStateNormal];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // something
                [self setstopforhttp];
                dispatch_async(dispatch_get_main_queue(), ^{
                    // something
                    [self getstopforhttp];
                });
            });
        }
    }else{
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
- (IBAction)save:(UIButton *)sender {
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]) {
        if ([self.caridforhttp length]>0) {
            [self setstopforhttp];
        }else{
            [self alwgoto];
        }
    }else{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.6f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = @"rippleEffect";
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self savenologinstop];
        [self performSegueWithIdentifier:@"Stoptologin" sender:@"停驶"];
    }
}
-(void)savenologinstop{
    StopTableViewCell* cell1 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    StopTableViewCell* cell2 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    StopTableViewCell* cell3 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    StopTableViewCell* cell4 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    StopTableViewCell* cell5 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    StopTableViewCell* cell6 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    StopTableViewCell* cell7 = (StopTableViewCell*)[self.tableview  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell1.stopbtu.selected] forKey:@"cell1"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell2.stopbtu.selected] forKey:@"cell2"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell3.stopbtu.selected] forKey:@"cell3"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell4.stopbtu.selected] forKey:@"cell4"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell5.stopbtu.selected] forKey:@"cell5"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell6.stopbtu.selected] forKey:@"cell6"];
    [userinfo setObject:[NSString stringWithFormat:@"%d",cell7.stopbtu.selected] forKey:@"cell7"];
    [userinfo synchronize];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    if ([segue.identifier isEqualToString:@"Stoptologin"]){
        DLYTableViewController* dvc = [segue destinationViewController];
        dvc.gotopurpose = sender;
    }else if ([segue.identifier isEqualToString:@"Stoptoaddcar"]){
        WritecarinfoTableViewController* wvc = segue.destinationViewController;
        wvc.comefrom = sender;
    }
}


@end
