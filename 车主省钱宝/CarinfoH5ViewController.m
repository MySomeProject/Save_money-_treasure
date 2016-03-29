//
//  CarinfoH5ViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CarinfoH5ViewController.h"
#import "Lloadview.h"
#import "Utils.h"
#import "SelectxianzhongViewController.h"
@interface CarinfoH5ViewController ()
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end

@implementation CarinfoH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* code = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    if (![code isEqualToString:@"(null)"]) {
          NSString* xieyi = [NSString stringWithFormat:@"http://58.135.80.72:8080/yuxianbao/H5/insure/addcar?session=%@&parameter=%@",code,[self dictionaryToJson:self.carinfo]];
        NSString *str = [xieyi stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        [self loadWebPageWithString:str];

    }else{
        NSString* xieyi = [NSString stringWithFormat:@"http://58.135.80.72:8080/yuxianbao/H5/insure/addcar?session=&parameter=%@",[self dictionaryToJson:self.carinfo]];
        NSString *str = [xieyi stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"%@",str);
        [self loadWebPageWithString:str];

    }


    

    
    // Do any additional setup after loading the view.
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *urlString = [[request URL] absoluteString];
     if ([urlString containsString:@"ios"]) {
        NSLog(@"urlString%@",urlString);
        NSArray* canshu = [urlString componentsSeparatedByString:@"&"];
        NSString* ios = [canshu lastObject];
        NSString* urlString1 = [ios stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray* ioscanshu = [urlString1 componentsSeparatedByString:@"="];
        NSString* iosh5canshu = [ioscanshu lastObject];
        NSDictionary* ioscanshudic =  [self dictionaryWithJsonString:iosh5canshu];
        if ([[ioscanshudic objectForKey:@"openWindow"] isEqualToString:@"1"]) {
            [self performSegueWithIdentifier:@"Selectxianzhong" sender:urlString];
        }
        return NO;
    }else{
        return YES;
    }

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
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self delayView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self deleteView];
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
-(void)dealloc{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Selectxianzhong"]) {
        SelectxianzhongViewController* svc = segue.destinationViewController;
        svc.url = sender;
    }

}


@end
