//
//  XIeyiViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "XIeyiViewController.h"
#import "Utils.h"
#import "Lloadview.h"
@interface XIeyiViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property(nonatomic,retain)Lloadview *loadview;

@end

@implementation XIeyiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebPageWithString:@"http://static.ebaochina.cn/html/xieyi.html"];
    // Do any additional setup after loading the view.
}
- (void)loadWebPageWithString:(NSString*)urlString
{
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}
//回退
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
