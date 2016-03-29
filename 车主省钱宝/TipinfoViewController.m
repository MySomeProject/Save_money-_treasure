//
//  TipinfoViewController.m
//  车主省钱宝
//
//  Created by 魏强 on 15/6/9.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "TipinfoViewController.h"
#import "Lloadview.h"
#import "Utils.h"
@interface TipinfoViewController ()
@property(nonatomic,retain)Lloadview *loadview;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation TipinfoViewController
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:nil] forBarMetrics:UIBarMetricsDefault];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
        [self loadWebPageWithString:[NSString stringWithFormat:@"http://58.135.80.72:8080/yuxianbao/api/new/%@",self.idname]];
    // Do any additional setup after loading the view.
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
