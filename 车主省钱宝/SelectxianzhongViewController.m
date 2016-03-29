//
//  SelectxianzhongViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/6/3.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "SelectxianzhongViewController.h"
#import "Lloadview.h"
#import "Utils.h"
#import "DLYTableViewController.h"
#import "SetobijiaViewController.h"
@interface SelectxianzhongViewController ()
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@end

@implementation SelectxianzhongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self loadWebPageWithString:[self.url stringByReplacingOccurrencesOfString:@"ios=" withString:@""]];
    
    // Do any additional setup after loading the view.
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
        if ([[ioscanshudic objectForKey:@"openWindow"] isEqualToString:@"1"]) {
            [self performSegueWithIdentifier:@"Setobijia" sender:urlString];
        }
        if ([[ioscanshudic objectForKey:@"userLogin"] isEqualToString:@"1"]) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.6f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = @"rippleEffect";
            transition.subtype = kCATransitionFromRight;
            transition.delegate = self;
            [self.navigationController.view.layer addAnimation:transition forKey:nil];
            [self performSegueWithIdentifier:@"Setologin" sender:urlString];
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
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)dealloc{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Setologin"]) {
        DLYTableViewController* dvc = segue.destinationViewController;
        dvc.gotopurpose = sender;
    }else if ([segue.identifier isEqualToString:@"Setobijia"]){
        SetobijiaViewController* sevc = segue.destinationViewController;
        sevc.url = sender;
    }
}


@end
