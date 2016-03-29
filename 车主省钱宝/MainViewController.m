//
//  MainViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/29.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MainViewController.h"
#import "Utils.h"
#import "StopViewController.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
#import "MainInfo.h"
#import "UIButton+cbut.h"
#import "MyredpaperViewController.h"
#import "UIImageView+WebCache.h"
#import "Checkshuju.h"
#import <ImageIO/ImageIO.h>
#import "Tip.h"
#import "TipinfoViewController.h"
@interface MainViewController ()<UIScrollViewDelegate>
@property(nonatomic)int index;
@property(nonatomic,retain)UIImageView* scrolloview;//背景图
@property(nonatomic,retain)Lloadview *loadview;//加载动画
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)UIView* upview;//上面的视图
@property(nonatomic,retain)UIView* downview;//下面的视图
@property(nonatomic,retain)UIImageView* bgimageview;//背景图片
@property(nonatomic,retain)UIButton* close;//关闭baner图按钮
@property(nonatomic,retain)UIScrollView* ScrollBaner;//baner图
@property(nonatomic,retain)NSTimer* timer;
@property(nonatomic,retain)UIButton* leftbut;//左按钮
@property(nonatomic,retain)UIButton* rightbut;//右按钮
@property(nonatomic,retain)UIButton* loginbut;//登录按钮
@property(nonatomic,retain)UIScrollView* centerscllow;//中心按钮
@property(nonatomic,retain)UILabel* centerlabel;
@property(nonatomic,retain)UIImageView* loginimage;
@property(nonatomic,retain)UIButton* shouyi;
@property(nonatomic,retain)UIButton* bijia;
@property(nonatomic,retain)UIButton* news;
@property(nonatomic,retain)UIButton* myself;
@property(nonatomic,retain)UIImageView* shouyiimage;
@property(nonatomic,retain)UIImageView* bijiaimage;
@property(nonatomic,retain)UIImageView* newsimage;
@property(nonatomic,retain)UIImageView* myselfimage;
@property(nonatomic,retain)UILabel* shouyilabel;
@property(nonatomic,retain)UILabel* bijialabel;
@property(nonatomic,retain)UILabel* newslabel;
@property(nonatomic,retain)UILabel* myselflabel;
@property(nonatomic,retain)NSMutableArray* mu;
@property(nonatomic)int count;
@property(nonatomic,copy)NSString* totleredpaper;
@property(nonatomic,retain)UIScrollView* yindaoimagesc;
@property(nonatomic,retain)UIImageView* carimage;
@property(nonatomic,retain)UIImageView *gifImageView;
@property(nonatomic,copy)NSString *redMoney;
@end

@implementation MainViewController

-(void)viewWillAppear:(BOOL)animated{    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    UIImageView* redline = [[UIImageView alloc]initWithFrame:CGRectMake(0, 44, Screen.bounds.size.width, 0.5)];
    redline.image = [UIImage imageNamed:@"bar640X128"];
    [self.navigationController.navigationBar addSubview:redline];
    //显示用户电话
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]) {
        [self.loginbut setTitle:@"个人中心" forState:UIControlStateNormal];
    }else{
        [self.loginbut setTitle:@"登录/注册" forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mu = [NSMutableArray array];
    self.index = 0;
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self initUI];
    
    //引导页
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        
        NSArray* yindaoimages = @[@"引导页1",@"引导页2",@"引导页3"];
        self.yindaoimagesc = [[UIScrollView alloc]initWithFrame:self.view.frame];
        for (int i = 0; i<yindaoimages.count; i++) {
            UIImageView* imagevc = [[UIImageView alloc]initWithImage:[UIImage imageNamed:yindaoimages[i]]];
            imagevc.frame = CGRectMake(Screen.bounds.size.width*i, 0, Screen.bounds.size.width, Screen.bounds.size.height);
            self.yindaoimagesc.pagingEnabled = YES;
            [self.yindaoimagesc addSubview:imagevc];
            if (i==2) {
                UIButton* but = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, Screen.bounds.size.width, Screen.bounds.size.height)];
                [but addTarget:self action:@selector(quxiaoyindao:) forControlEvents:UIControlEventTouchUpInside];
                [imagevc addSubview:but];
                imagevc.userInteractionEnabled = YES;
                // 读取gif图片数据
                NSData *gif = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"动画" ofType:@"gif"]];
                self.gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Screen.bounds.size.width*2+Screen.bounds.size.width/2-40, Screen.bounds.size.height*0.7, 80, 15)];
                self.gifImageView.animationImages = [self praseGIFDataToImageArray:gif]; //动画图片数组
                self.gifImageView.animationDuration = 1; //执行一次完整动画所需的时长
                self.gifImageView.animationRepeatCount = 0.2;  //动画重复次数
                [self.gifImageView startAnimating];
                [self.yindaoimagesc addSubview:self.gifImageView];
                self.carimage = [[UIImageView alloc]initWithFrame:CGRectMake(Screen.bounds.size.width*2+Screen.bounds.size.width*0.15, Screen.bounds.size.height*0.7, Screen.bounds.size.width/6, Screen.bounds.size.width/8)];
                self.carimage.image = [UIImage imageNamed:@"carimage"];
                [self.yindaoimagesc addSubview:self.carimage];
                
            }
            self.yindaoimagesc.userInteractionEnabled = YES;
            self.yindaoimagesc.bounces = NO;
            [self.yindaoimagesc setContentSize:CGSizeMake(Screen.bounds.size.width*3, Screen.bounds.size.height)];
        }
        [self.view addSubview:self.yindaoimagesc];
        
    }

    
    [self Mainforhttp];
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scrolloviewstart) userInfo:nil repeats:YES];
        //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logintongzhi:) name:@"logintoupdate" object:nil];
        //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addcartongzhi:) name:@"addcartoupdate" object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stoptongzhi:) name:@"stoptoupdate" object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginouttongzhi:) name:@"logintoout" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logintomaintongzhi:) name:@"logintomain" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deltongzhi:) name:@"deltongzhi" object:nil];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logintostoptongzhi:) name:@"logintostop" object:nil];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addcartomainupdatetongzhi:) name:@"addcartomainupdate" object:nil];
    
    
}
-(NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}
-(void)quxiaoyindao:(UIButton*)sender{
    [UIView animateWithDuration:2.0 animations:^{
        self.gifImageView.hidden = YES;
        self.carimage.frame = CGRectMake(Screen.bounds.size.width*2+Screen.bounds.size.width*0.85-self.carimage.frame.size.width, Screen.bounds.size.height*0.7, Screen.bounds.size.width/6, Screen.bounds.size.width/8);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.yindaoimagesc.alpha = 0;
            
        } completion:^(BOOL finished) {
            [self.yindaoimagesc removeFromSuperview];
        }];
    }];
    
}
- (void)addcartomainupdatetongzhi:(NSNotification *)text{
    [self Mainforhttp];
}
- (void)logintostoptongzhi:(NSNotification *)text{
    [self LMainforhttp];
}
- (void)logintongzhi:(NSNotification *)text{
    [self Mainforhttp];
}
- (void)deltongzhi:(NSNotification *)text{
    
    [self Mainforhttp];
}
- (void)logintomaintongzhi:(NSNotification *)text{
    [self Mainforhttp];
}
- (void)addcartongzhi:(NSNotification *)text{
    [self Mainforhttp];
}
- (void)stoptongzhi:(NSNotification *)text{
    [self Mainforhttp];
}
- (void)loginouttongzhi:(NSNotification *)text{
    [self Mainforhttp];
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
-(void)LMainforhttp{
    if (!self.loadview) {
        [self delayView];
    }
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson;
    getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/index/getstopmessage",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"main%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
            
            appdelegate.totlepaper = [NSString stringWithFormat:@"%@",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"totalearn"] ]];
            self.index = 0;
            [appdelegate.carlist removeAllObjects];
            NSArray* incomecars = [[json objectForKey:@"datas"] objectForKey:@"incomecar"];
            if (![userinfo valueForKey:@"logincode"]||incomecars.count == 0) {
                MainInfo* mainifo = [[MainInfo alloc]init];
                mainifo.shouyi = [NSString stringWithFormat:@"日均收益:%@元",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"yesterdayaverage"] ]];
                mainifo.buttitle = @"一键泊车";
                mainifo.carnumber = @"";
                [appdelegate.carlist addObject:mainifo];
                [self Scollviewcenter:appdelegate.carlist];
                self.leftbut.hidden = YES;
                self.rightbut.hidden = YES;
                
            }else{
                for (NSDictionary* carinfo in incomecars) {
                    MainInfo* mainifo = [[MainInfo alloc]init];
                    mainifo.yesterdayaverage = [NSString stringWithFormat:@"%@",[json objectForKey:@"yesterdayaverage"]];

                    if ([[NSString stringWithFormat:@"%@",[carinfo objectForKey:@"tomorrowexpected"]] isEqualToString:@"0"]) {
                        mainifo.buttitle = @"一键泊车";
                    }else{
                        mainifo.shouyi = @"明日预期收益";
                        //[self chuanzhi:mainifo.buttitle];
                        
                        mainifo.buttitle = [NSString stringWithFormat:@"%@元",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self.redMoney]]]];

                    }
                    
                    mainifo.carnumber = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"plateNumber"]];
                    mainifo.carid = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"carid"]];
                    mainifo.totleredpaper = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"countIncome"]];
                    if ([[NSString stringWithFormat:@"%@",[carinfo objectForKey:@"isStop"]] isEqualToString:@"1"]) {
                        mainifo.frist = YES;
                    }else{
                        mainifo.frist = NO;
                    }
                    [appdelegate.carlist addObject:mainifo];
                }
                [self Scollviewcenter:appdelegate.carlist];
                MainInfo* mainifo = [[MainInfo alloc]init];
                mainifo.carnumber = @"添加车辆";
                [appdelegate.carlist addObject:mainifo];
                if (incomecars.count==1) {
                    self.leftbut.hidden = YES;
                    self.rightbut.hidden = YES;
                }else{
                    self.leftbut.hidden = YES;
                    self.rightbut.hidden = NO;
                }
            }
            [self.mu removeAllObjects];
            Tip* tip = [[Tip alloc]init];
            NSArray* tips = [[json objectForKey:@"datas"] objectForKey:@"tips"];
            for (NSDictionary* tipdic in tips) {
                tip.idname = [tipdic objectForKey:@"id"];
                tip.name = [tipdic objectForKey:@"name"];
                [self.mu addObject:tip];
            }
            [self Scollviewbaner:self.mu];
            [self deleteView];
            //添加 字典，将label的值通过key值设置传递
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:@"登录停驶",@"loginmainstop", nil];
            //创建通知
            NSNotification *notification =[NSNotification notificationWithName:@"logintomaintostop" object:nil userInfo:dict];
            //通过通知中心发送通知
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
    }];
    
}

-(void)Mainforhttp{
    if (!self.loadview) {
        [self delayView];
    }
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson;
    getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"session":code};
    NSString *url = [NSString stringWithFormat:@"%@/index/getstopmessage",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"main%@",json);
        
        if ([[json objectForKey:@"status"] intValue] == 0) {
            
            appdelegate.totlepaper = [NSString stringWithFormat:@"%@",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"countredbag"] ]];
            self.index = 0;
            [appdelegate.carlist removeAllObjects];
            NSArray* incomecars = [[json objectForKey:@"datas"] objectForKey:@"incomecar"];
            if (![userinfo valueForKey:@"logincode"]||incomecars.count == 0) {
                MainInfo* mainifo = [[MainInfo alloc]init];
                mainifo.shouyi = [NSString stringWithFormat:@"日均收益:%@元",[Checkshuju checkshuju:[[json objectForKey:@"datas"] objectForKey:@"yesterdayaverage"]]];
                mainifo.buttitle = @"一键泊车";
                mainifo.carnumber = @"";
                [appdelegate.carlist addObject:mainifo];
                self.leftbut.hidden = YES;
                self.rightbut.hidden = YES;
                [self Scollviewcenter:appdelegate.carlist];

            }else{
                for (NSDictionary* carinfo in incomecars) {
                    MainInfo* mainifo = [[MainInfo alloc]init];
                    if ([[NSString stringWithFormat:@"%@",[carinfo objectForKey:@"tomorrowexpected"]] isEqualToString:@"0"]) {
                        mainifo.buttitle = @"一键泊车";
                    }else{
                        mainifo.shouyi = @"明日预期收益";
                        //mainifo.buttitle = [NSString stringWithFormat:@"%@元",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[[json objectForKey:@"datas"]objectForKey:@"yesterdayaverage"]]]]];
                      // NSString *str = [self chuanzhi:mainifo.buttitle];
                        mainifo.buttitle = [NSString stringWithFormat:@"%@元",[Checkshuju checkshuju:[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",self.redMoney]]]];
                    }
                    
                    mainifo.carnumber = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"plateNumber"]];
                    mainifo.carid = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"carid"]];
                    mainifo.totleredpaper = [NSString stringWithFormat:@"%@",[carinfo objectForKey:@"countIncome"]];
                    if ([[NSString stringWithFormat:@"%@",[carinfo objectForKey:@"isStop"]] isEqualToString:@"1"]) {
                            mainifo.frist = YES;
                    }else{
                            mainifo.frist = NO;
                    }

                    [appdelegate.carlist addObject:mainifo];
                }
                [self Scollviewcenter:appdelegate.carlist];
                MainInfo* mainifo = [[MainInfo alloc]init];
                mainifo.carnumber = @"添加车辆";
                [appdelegate.carlist addObject:mainifo];
                
                if (incomecars.count==1) {
                    self.leftbut.hidden = YES;
                    self.rightbut.hidden = YES;
                }else{
                    self.leftbut.hidden = YES;
                    self.rightbut.hidden = NO;
                }
            }
            [self.mu removeAllObjects];
            Tip* tip = [[Tip alloc]init];
            NSArray* tips = [[json objectForKey:@"datas"] objectForKey:@"tips"];
            for (NSDictionary* tipdic in tips) {
                tip.idname = [tipdic objectForKey:@"id"];
                tip.name = [tipdic objectForKey:@"name"];
                [self.mu addObject:tip];
            }
            [self Scollviewbaner:self.mu];
            [self deleteView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"redeee%@",error);
        [self deleteView];
    }];

}
-(void)chuanzhi:(NSString *)str{
    
    self.redMoney = str;
    
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
-(void)closebanerimage:(UIButton*)sender{
    [UIView animateWithDuration:0.4 animations:^{
        self.scrolloview.alpha = 0;
        self.close.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            
            self.upview.frame = CGRectMake(0, -self.scrolloview.bounds.size.height/2, Screen.bounds.size.width, Screen.bounds.size.height*0.65);
            self.downview.frame = CGRectMake(0, Screen.bounds.size.height*0.65-self.scrolloview.bounds.size.height/2, Screen.bounds.size.width, Screen.bounds.size.height*0.35+self.scrolloview.bounds.size.height/2);
            self.shouyi.frame = CGRectMake(0, 0.5, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25);
            self.bijia.frame = CGRectMake(self.shouyi.frame.size.width+0.5, 0.5, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25);
            self.news.frame = CGRectMake(0, self.downview.frame.size.height/2+1, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25);
            self.myself.frame = CGRectMake(self.shouyi.frame.size.width+0.5, self.downview.frame.size.height/2+1, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25);
                self.shouyiimage.center = CGPointMake(self.shouyi.center.x, self.shouyi.center.y-self.shouyiimage.bounds.size.width/2);
                self.shouyilabel.center = CGPointMake(self.shouyi.center.x, self.shouyi.center.y+self.shouyilabel.bounds.size.height);
            self.bijiaimage.center = CGPointMake(self.bijia.center.x, self.bijia.center.y-self.bijiaimage.bounds.size.width/2);
            self.bijialabel.center = CGPointMake(self.bijia.center.x, self.bijia.center.y+self.bijialabel.bounds.size.height);
            self.newsimage.center = CGPointMake(self.news.center.x, self.news.center.y-self.newsimage.bounds.size.width/2);
            self.newslabel.center = CGPointMake(self.news.center.x, self.news.center.y+self.newslabel.bounds.size.height);
            self.myselfimage.center = CGPointMake(self.myself.center.x, self.myself.center.y-self.myselfimage.bounds.size.width/2);
            self.myselflabel.center = CGPointMake(self.myself.center.x, self.myself.center.y+self.myselflabel.bounds.size.height);
            
            
        }];
        [self.scrolloview removeFromSuperview];
        [self.close removeFromSuperview];
    }];

}
-(void)initUI{
    self.upview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen.bounds.size.width, Screen.bounds.size.height*0.65)];
    
    if (Screen.bounds.size.width == 320) {
            self.bgimageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.upview.frame.size.width, self.upview.frame.size.height*0.9)];
    }else{
           self.bgimageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.upview.frame.size.width, self.upview.frame.size.height*0.88)];
    }
    
    [self.bgimageview setImage:[UIImage imageNamed:@"bg_1080-1062"]];
    [self.upview addSubview:self.bgimageview];
    [self.upview setBackgroundColor:[UIColor colorWithRed:255.0/255 green:181.0/255 blue:181.0/255 alpha:1]];
    self.ScrollBaner = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.upview.frame.size.height*0.89, self.upview.frame.size.width, self.upview.frame.size.height*0.11)];


    UIImageView* laba = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, self.ScrollBaner.bounds.size.height/3.5, self.ScrollBaner.bounds.size.height/3.5)];
    laba.center = CGPointMake(30, self.ScrollBaner.center.y);
    [laba setImage:[UIImage imageNamed:@"announce_40-40"]];
    
    [self.upview addSubview:laba];
    
    self.scrolloview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, Screen.bounds.size.width, self.upview.frame.size.height*0.12)];
    self.scrolloview.image = [UIImage imageNamed:@"aa"];
    
    self.close = [[UIButton alloc]initWithFrame:CGRectMake(Screen.bounds.size.width*0.9, self.scrolloview.bounds.size.height/2, self.scrolloview.bounds.size.height/3, self.scrolloview.bounds.size.height/3)];
    self.close.center = CGPointMake(Screen.bounds.size.width*0.95, self.scrolloview.center.y);
    [self.close setBackgroundImage:[UIImage imageNamed:@"close_40-40"] forState:UIControlStateNormal];
    [self.close addTarget:self action:@selector(closebanerimage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (Screen.bounds.size.width == 320) {
            self.centerscllow = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.upview.bounds.size.height*0.4, self.upview.bounds.size.width, self.upview.bounds.size.width/2.2)];
    }else{
           self.centerscllow = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.upview.bounds.size.height*0.4, self.upview.bounds.size.width, self.upview.bounds.size.width/2)];
    }
    

    self.centerscllow.center = CGPointMake(self.upview.center.x, self.centerscllow.center.y);
    self.centerscllow.pagingEnabled = YES;
    self.ScrollBaner.pagingEnabled = YES;
    self.centerscllow.showsVerticalScrollIndicator = FALSE;
    self.centerscllow.showsHorizontalScrollIndicator = FALSE;
    self.ScrollBaner.showsVerticalScrollIndicator = FALSE;
    self.ScrollBaner.showsHorizontalScrollIndicator = FALSE;
    self.centerscllow.delegate = self;
    
    self.leftbut = [[UIButton alloc]initWithFrame:CGRectMake(self.upview.bounds.size.width*0.1, 0, self.centerscllow.bounds.size.width/8, self.centerscllow.bounds.size.width/8)];
    self.leftbut.center = CGPointMake(self.leftbut.center.x, self.centerscllow.center.y);
    [self.leftbut setBackgroundImage:[UIImage imageNamed:@"arrow_36-86-1"] forState:UIControlStateNormal];
    [self.leftbut addTarget:self action:@selector(gotoleft:) forControlEvents:UIControlEventTouchUpInside];

    
    self.rightbut = [[UIButton alloc]initWithFrame:CGRectMake(self.upview.bounds.size.width*0.9-self.centerscllow.bounds.size.width/8, 0, self.centerscllow.bounds.size.width/8, self.centerscllow.bounds.size.width/8)];
    self.rightbut.center = CGPointMake(self.rightbut.center.x, self.centerscllow.center.y);
    [self.rightbut setBackgroundImage:[UIImage imageNamed:@"arrow_36-86-2"] forState:UIControlStateNormal];
    [self.rightbut addTarget:self action:@selector(gotoright:) forControlEvents:UIControlEventTouchUpInside];


    if (Screen.bounds.size.width==320) {
           self.loginbut = [[UIButton alloc]initWithFrame:CGRectMake(Screen.bounds.size.width*0.7, self.scrolloview.bounds.size.height*1.8, self.scrolloview.bounds.size.height*2.6, self.scrolloview.bounds.size.height/3)];
    }else{
            self.loginbut = [[UIButton alloc]initWithFrame:CGRectMake(Screen.bounds.size.width*0.75, self.scrolloview.bounds.size.height*1.8, self.scrolloview.bounds.size.height*2, self.scrolloview.bounds.size.height/3)];
    }
    
    
    [self.loginbut setTitle:@"登录/注册" forState:UIControlStateNormal];
    
    [self.loginbut setTintColor:[UIColor whiteColor]];
    [self.loginbut.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.loginbut addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    
    if (Screen.bounds.size.width==320) {
    self.loginimage  = [[UIImageView alloc]initWithFrame:CGRectMake(self.loginbut.frame.origin.x-5, 0, self.loginbut.bounds.size.width*1.1, self.scrolloview.bounds.size.height/1.5)];
    }else{
    self.loginimage  = [[UIImageView alloc]initWithFrame:CGRectMake(self.loginbut.frame.origin.x-5, 0, self.loginbut.bounds.size.width*1.1, self.scrolloview.bounds.size.height/1.7)];
    }
    
    self.loginimage.center = CGPointMake(self.loginimage.center.x, self.loginbut.center.y);
    [self.loginimage setImage:[UIImage imageNamed:@"282-82_bg"]];
    [self.upview addSubview:self.loginimage];
    [self.upview addSubview:self.centerscllow];
    [self.upview addSubview:self.scrolloview];
    [self.upview addSubview:self.close];
    [self.upview addSubview:self.ScrollBaner];
    [self.upview addSubview:self.rightbut];
    [self.upview addSubview:self.leftbut];
    [self.upview addSubview:self.loginbut];
    
    
    self.downview = [[UIView alloc]initWithFrame:CGRectMake(0, Screen.bounds.size.height*0.65, Screen.bounds.size.width, Screen.bounds.size.height*0.35)];
    [self.downview setBackgroundColor:[UIColor colorWithRed:217.0/255 green:217.0/255 blue:217.0/255 alpha:1]];
    self.shouyi = [[UIButton alloc]initWithFrame:CGRectMake(0, 0.5, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25)];
    [self.shouyi setBackgroundColor:[UIColor whiteColor]];
    self.bijia = [[UIButton alloc]initWithFrame:CGRectMake(self.shouyi.frame.size.width+0.5, 0.5, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25)];
    [self.bijia setBackgroundColor:[UIColor whiteColor]];
    self.news = [[UIButton alloc]initWithFrame:CGRectMake(0, self.downview.frame.size.height/2+1, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25)];
    [self.news setBackgroundColor:[UIColor whiteColor]];
    self.myself = [[UIButton alloc]initWithFrame:CGRectMake(self.shouyi.frame.size.width+0.5, self.downview.frame.size.height/2+1, self.downview.frame.size.width/2-0.25, self.downview.frame.size.height/2-0.25)];
    [self.myself setBackgroundColor:[UIColor whiteColor]];
    
        [self.shouyi addTarget:self action:@selector(gotoshouyi:) forControlEvents:UIControlEventTouchUpInside];
        [self.bijia addTarget:self action:@selector(gotobijia:) forControlEvents:UIControlEventTouchUpInside];
        [self.news addTarget:self action:@selector(gotonews:) forControlEvents:UIControlEventTouchUpInside];
    [self.downview addSubview:self.shouyi];
    [self.downview addSubview:self.bijia];
    [self.downview addSubview:self.news];
    [self.downview addSubview:self.myself];
    
    self.shouyiimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.shouyi.bounds.size.height/3.7, self.shouyi.bounds.size.height/3.7)];
    [self.shouyiimage setImage:[UIImage imageNamed:@"coin_86-86"]];
    self.shouyiimage.center = CGPointMake(self.shouyi.center.x, self.shouyi.center.y-self.shouyiimage.bounds.size.width/2);
    
    self.shouyilabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.shouyi.bounds.size.width/2, 20)];
    self.shouyilabel.center = CGPointMake(self.shouyi.center.x, self.shouyi.center.y+self.shouyilabel.bounds.size.height);
    self.shouyilabel.textAlignment = NSTextAlignmentCenter;
    
    [self.shouyilabel setText:@"我的收益"];
    
    [self.shouyilabel setFont:[UIFont systemFontOfSize:15]];
    
    [self.shouyilabel setTextColor:[UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1]];
    [self.downview addSubview:self.shouyiimage];
    [self.downview addSubview:self.shouyilabel];
    
    self.bijiaimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bijia.bounds.size.height/3.7, self.bijia.bounds.size.height/3.7)];
    [self.bijiaimage setImage:[UIImage imageNamed:@"compare_86-86"]];
    self.bijiaimage.center = CGPointMake(self.bijia.center.x, self.bijia.center.y-self.bijiaimage.bounds.size.width/2);
    
    self.bijialabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bijia.bounds.size.width/2, 20)];
    self.bijialabel.center = CGPointMake(self.bijia.center.x, self.bijia.center.y+self.bijialabel.bounds.size.height);
    self.bijialabel.textAlignment = NSTextAlignmentCenter;
    
    [self.bijialabel setText:@"车险比价"];
    
    [self.bijialabel setFont:[UIFont systemFontOfSize:15]];
    
    [self.bijialabel setTextColor:[UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1]];
    [self.downview addSubview:self.bijiaimage];
    [self.downview addSubview:self.bijialabel];
    
    
    self.newsimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.news.bounds.size.height/3.7, self.news.bounds.size.height/3.7)];
    [self.newsimage setImage:[UIImage imageNamed:@"dimand_86-86"]];
    self.newsimage.center = CGPointMake(self.news.center.x, self.news.center.y-self.newsimage.bounds.size.width/2);
    
    self.newslabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.news.bounds.size.width/2, 20)];
    self.newslabel.center = CGPointMake(self.news.center.x, self.news.center.y+self.newslabel.bounds.size.height);
    self.newslabel.textAlignment = NSTextAlignmentCenter;
    
    [self.newslabel setText:@"精选"];
    
    [self.newslabel setFont:[UIFont systemFontOfSize:15]];
    
    [self.newslabel setTextColor:[UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1]];
    [self.downview addSubview:self.newsimage];
    [self.downview addSubview:self.newslabel];
    
    
    self.myselfimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.myself.bounds.size.height/3.7, self.myself.bounds.size.height/3.7)];
    self.myselfimage.center = CGPointMake(self.myself.center.x, self.myself.center.y-self.myselfimage.bounds.size.width/2);
    
    self.myselflabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.myself.bounds.size.width/2, 20)];
    self.myselflabel.center = CGPointMake(self.myself.center.x, self.myself.center.y+self.myselflabel.bounds.size.height);
    self.myselflabel.textAlignment = NSTextAlignmentCenter;
    
    [self.myselflabel setText:@"我的"];
    
    [self.myselflabel setFont:[UIFont systemFontOfSize:15]];
    
    [self.myselflabel setTextColor:[UIColor colorWithRed:151.0/255 green:151.0/255 blue:151.0/255 alpha:1]];
    [self.downview addSubview:self.myselfimage];
    [self.downview addSubview:self.myselflabel];
    
    
    if (1) {
        [self.myselfimage setImage:[UIImage imageNamed:@"weizhang_86-86"]];
        [self.myselflabel setText:@"违章查询"];
        [self.myself addTarget:self action:@selector(gotoweizhang:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.myselfimage setImage:[UIImage imageNamed:@"mine_86-86"]];
        [self.myselflabel setText:@"我的"];
        [self.myself addTarget:self action:@selector(gotomyself:) forControlEvents:UIControlEventTouchUpInside];
    }

    
    
    
    [self.view addSubview:self.upview];
    [self.view addSubview:self.downview];
    
}
-(void)Scollviewbaner:(NSMutableArray*)infos{
    for (int i = 0; i<infos.count; i++) {
        Tip* tip = infos[i];
        UIButton* info = [[UIButton alloc]initWithFrame:CGRectMake(50,i*self.ScrollBaner.frame.size.height, self.view.frame.size.width*0.9, self.ScrollBaner.frame.size.height)];
        [info setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [info.titleLabel setFont:[UIFont systemFontOfSize:14]];
        info.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [info setTitle:tip.name forState:UIControlStateNormal];
        info.carid = tip.idname;
        [info addTarget:self action:@selector(gotodong:) forControlEvents:UIControlEventTouchUpInside];
        [self.ScrollBaner addSubview:info];
    }
    [self.ScrollBaner setContentSize:CGSizeMake(self.ScrollBaner.frame.size.width, self.ScrollBaner.frame.size.height*infos.count)];
}

-(void)Scollviewcenter:(NSMutableArray*)titles{
    for (int i = 0; i<titles.count; i++) {
        MainInfo* maininfo = titles[i];
        UILabel* carlabel = [[UILabel alloc]initWithFrame:CGRectMake(i*self.centerscllow.frame.size.width+self.centerscllow.frame.size.width/2-self.centerscllow.frame.size.height/3, self.centerscllow.frame.size.height/1.4, self.centerscllow.frame.size.height/1.5, 20)];
        
        UILabel* carnumber = [[UILabel alloc]initWithFrame:CGRectMake(i*self.centerscllow.frame.size.width+self.centerscllow.frame.size.width/2-self.centerscllow.frame.size.height/3, self.centerscllow.frame.size.height*0.28, self.centerscllow.frame.size.height/1.5, 20)];
        carnumber.text = maininfo.shouyi;
        carnumber.textAlignment = NSTextAlignmentCenter;
        [carnumber setTextColor:[UIColor whiteColor]];
        if (Screen.bounds.size.width==320) {
            [carnumber setFont:[UIFont systemFontOfSize:10]];
        }else{
            [carnumber setFont:[UIFont systemFontOfSize:13]];
        }
        if ([maininfo.carnumber length]>0) {
            carlabel.text = maininfo.carnumber;
            carnumber.text = maininfo.shouyi;
            carlabel.textAlignment = NSTextAlignmentCenter;
            [carlabel setTextColor:[UIColor whiteColor]];
            [carnumber setTextColor:[UIColor colorWithRed:255.0/255 green:181.0/255 blue:181.0/255 alpha:1]];
            if (Screen.bounds.size.width==320) {
                [carlabel setFont:[UIFont systemFontOfSize:12]];
            }else{
                [carlabel setFont:[UIFont systemFontOfSize:17]];
            }
        }else{
            carlabel.text = maininfo.shouyi;
            carnumber.text = maininfo.carnumber;
            carlabel.textAlignment = NSTextAlignmentCenter;
            [carlabel setTextColor:[UIColor colorWithRed:255.0/255 green:181.0/255 blue:181.0/255 alpha:1]];
            [carlabel setTextColor:[UIColor whiteColor]];
            if (Screen.bounds.size.width==320) {
                [carlabel setFont:[UIFont systemFontOfSize:10]];
            }else{
                [carlabel setFont:[UIFont systemFontOfSize:13]];
            }
        }

        UIButton* carbut = [[UIButton alloc]initWithFrame:CGRectMake(i*self.centerscllow.frame.size.width+self.centerscllow.frame.size.width/2-self.centerscllow.frame.size.height/2, 0, self.centerscllow.frame.size.height, self.centerscllow.frame.size.height)];
        carbut.carid = maininfo.carid;
        carbut.carnumber = maininfo.carnumber;
        [carbut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (Screen.bounds.size.width==320) {
            [carbut.titleLabel setFont:[UIFont systemFontOfSize:25]];
        }else{
            [carbut.titleLabel setFont:[UIFont systemFontOfSize:30]];
        }
        
        [carbut setTitle:maininfo.buttitle forState:UIControlStateNormal];
        [carbut setBackgroundImage:[UIImage imageNamed:@"red_550-550"] forState:UIControlStateNormal];
        [carbut addTarget:self action:@selector(gotomudi:) forControlEvents:UIControlEventTouchUpInside];
        [self.centerscllow addSubview:carbut];
        [self.centerscllow addSubview:carlabel];
        [self.centerscllow addSubview:carnumber];
    }
    [self.centerscllow setContentSize:CGSizeMake(self.centerscllow.frame.size.width*titles.count, self.centerscllow.frame.size.height)];
    
}

-(void)gotodong:(UIButton*)sender{
    [self performSegueWithIdentifier:@"Tipinfo" sender:sender.carid];
}
-(void)gotomudi:(UIButton*)sender{
    if ([sender.carnumber length]>0&&[sender.carid length]>0) {
        [self performSegueWithIdentifier:@"Stop" sender:[NSString stringWithFormat:@"%@-%@",sender.carnumber,sender.carid]];
    }else{
        [self performSegueWithIdentifier:@"Stop" sender:nil];
    }
}
-(void)login:(UIButton*)sender{
    if ([sender.titleLabel.text isEqualToString:@"个人中心"]) {
         [self performSegueWithIdentifier:@"Myself" sender:nil];
    }else{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.6f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = @"rippleEffect";
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self performSegueWithIdentifier:@"Login" sender:nil];
    }

}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.index = appdelegate.carlist.count - (self.centerscllow.contentSize.width - self.centerscllow.contentOffset.x)/self.centerscllow.bounds.size.width;
    
    if (self.centerscllow.contentOffset.x<=0) {
        self.leftbut.hidden = YES;
        self.rightbut.hidden = NO;
    }
    if (self.centerscllow.contentOffset.x>=self.centerscllow.bounds.size.width*(appdelegate.carlist.count-2)) {
        self.leftbut.hidden = NO;
        self.rightbut.hidden = YES;
    }
    if (self.centerscllow.contentOffset.x>0&&self.centerscllow.contentOffset.x<self.centerscllow.bounds.size.width*(appdelegate.carlist.count-2)) {
        self.leftbut.hidden = NO;
        self.rightbut.hidden = NO;
    }
}


-(void)gotoleft:(UIButton*)sender{
    if (self.centerscllow.contentOffset.x>0) {
        self.rightbut.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.centerscllow.contentOffset = CGPointMake(self.centerscllow.contentOffset.x-self.centerscllow.bounds.size.width, 0);
        }];
        self.index--;
        if (self.centerscllow.contentOffset.x<=0) {
            self.leftbut.hidden = YES;
        }
    }
 
    
}
-(void)gotoright:(UIButton*)sender{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (self.centerscllow.contentOffset.x<self.centerscllow.contentSize.width - self.centerscllow.bounds.size.width) {
        self.leftbut.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.centerscllow.contentOffset = CGPointMake(self.centerscllow.contentOffset.x+self.centerscllow.bounds.size.width, 0);
        }];
        self.index++;
        if (self.centerscllow.contentOffset.x>=self.centerscllow.bounds.size.width*(appdelegate.carlist.count-2)) {
            self.rightbut.hidden = YES;
        }

    }
}


-(void)scrolloviewstart{
    
    [UIView animateWithDuration:0.5 animations:^{
        self.ScrollBaner.contentOffset = CGPointMake(0,self.ScrollBaner.frame.size.height*self.count);
    }];
    self.count++;
    if (self.count == 1) {
        self.count = 0;
    }
    
}
-(void)gotoshouyi:(UIButton*)sender{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]){
        [self performSegueWithIdentifier:@"Maintoredpapaer" sender:nil];
    }else{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.6f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = @"rippleEffect";
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
       [self performSegueWithIdentifier:@"Login" sender:nil];
    }
}
-(void)gotobijia:(UIButton*)sender{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    MainInfo* m = appdelegate.carlist[0];
    if (m.carid) {
        [self performSegueWithIdentifier:@"Hascar" sender:nil];
    }else{
      [self performSegueWithIdentifier:@"Bijia" sender:nil];
    }
}
-(void)gotonews:(UIButton*)sender{
        [self performSegueWithIdentifier:@"News" sender:nil];
}
-(void)gotomyself:(UIButton*)sender{
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    if ([userinfo valueForKey:@"logincode"]){
        [self performSegueWithIdentifier:@"Myself" sender:@"我的"];
    }else{
        CATransition *transition = [CATransition animation];
        transition.duration = 0.6f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = @"rippleEffect";
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self performSegueWithIdentifier:@"Login" sender:nil];
    }
}
-(void)gotoweizhang:(UIButton*)sender{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appdelegate.carlist.count>0) {
           MainInfo* m = appdelegate.carlist[0];
        NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
        if ([userinfo valueForKey:@"logincode"]){
            if ([m.carid length]>0) {
                [self performSegueWithIdentifier:@"Check" sender:nil];
            }else{
                [self performSegueWithIdentifier:@"Nocar" sender:nil];
            }
        }else{
            CATransition *transition = [CATransition animation];
            transition.duration = 0.6f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = @"rippleEffect";
            transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self performSegueWithIdentifier:@"Login" sender:nil];
        }
    }

}
-(void)viewWillDisappear:(BOOL)animated{
    //开启自定义左baritem的手势返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    // 开启
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
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
    if ([segue.identifier isEqualToString:@"Stop"]){
        StopViewController* svc = [segue destinationViewController];
        svc.carid = sender;
    }else if ([segue.identifier isEqualToString:@"Tipinfo"]){
        TipinfoViewController* tvc = [segue destinationViewController];
        tvc.idname = sender;
    }


}


@end
