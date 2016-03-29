//
//  NewinfoViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "NewinfoViewController.h"
#import "Lloadview.h"
#import "Utils.h"
#import <ShareSDK/ShareSDK.h>
@interface NewinfoViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property(nonatomic,retain)Lloadview *loadview;
@end

@implementation NewinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadWebPageWithString:[NSString stringWithFormat:@"http://58.135.80.72:8080/yuxianbao/api/new/%@",self.message.idbiaoshi]];
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
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
- (IBAction)share:(UIButton *)sender {
    
    NSString *imagePath = self.message.image;
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:self.message.title
                                       defaultContent:self.message.title
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:self.message.name
                                                  url:[NSString stringWithFormat:@"http://58.135.80.72:8080/yuxianbao/api/new/%@",self.message.idbiaoshi]
                                          description:self.message.title
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
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
