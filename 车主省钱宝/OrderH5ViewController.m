//
//  OrderH5ViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/6/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "OrderH5ViewController.h"
#import "Lloadview.h"
#import "Utils.h"
#import "OrderSecccessViewController.h"
@interface OrderH5ViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property(nonatomic,retain)Lloadview *loadview;

@end

@implementation OrderH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        [self loadWebPageWithString:[self.url stringByReplacingOccurrencesOfString:@"ios=" withString:@""]];
    // Do any additional setup after loading the view.
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"urlString%@",urlString);
    if ([urlString containsString:@"ios"]) {
        NSLog(@"urlString%@",urlString);
        NSArray* canshu = [urlString componentsSeparatedByString:@"&"];
        NSString* ios = [canshu lastObject];
        NSString* urlString1 = [ios stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSArray* ioscanshu = [urlString1 componentsSeparatedByString:@"="];
        NSString* iosh5canshu = [ioscanshu lastObject];
        NSDictionary* ioscanshudic =  [self dictionaryWithJsonString:iosh5canshu];
        if([[ioscanshudic objectForKey:@"openWindow"] isEqualToString:@"1"]){
            [self performSegueWithIdentifier:@"Ordersecess" sender:urlString];
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


- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Ordersecess"]) {
        OrderSecccessViewController* ovc = segue.destinationViewController;
        ovc.url = sender;
    }
}


@end
