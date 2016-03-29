//
//  TellmeTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "TellmeTableViewController.h"
#import "Utils.h"
#import "Popview.h"
#import <CommonCrypto/CommonDigest.h>
#import <AFHTTPRequestOperationManager.h>
#import <Foundation/NSJSONSerialization.h>
#import "Lloadview.h"
@interface TellmeTableViewController ()
@property(nonatomic,retain)Popview* popview;
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property(nonatomic,retain)Lloadview *loadview;
@end

@implementation TellmeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self TapcancelKeyboard];
    [self TextviewInit];
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
-(void)tellmeforhttp{
    [self delayView];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    NSString* session = [NSString stringWithFormat:@"%@",[userinfo objectForKey:@"session"]];
    NSDictionary* parameter = @{@"content":self.Tellmetext.text};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString* code = [NSString stringWithFormat:@"parameter=%@%@",jsonString,session];
    
    NSString* md5code = [self md5:code];
    NSString* lowercode = [md5code lowercaseString];
    NSDictionary* getcodejson = @{@"sign_type":@"MD5",@"sign":lowercode,@"parameter":jsonString,@"session":session};
    NSString *url = [NSString stringWithFormat:@"%@/propose/put",BaseUrl];
    [self.manager POST:url parameters:getcodejson success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        NSLog(@"systems%@",json);
        if ([[json objectForKey:@"status"] intValue] == 0) {
             [self deleteView];
            self.Tellmetext.text = @"";
            //[self addpopview:@"感谢您的吐槽!"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
}
- (IBAction)send:(UIButton *)sender {

    if ([self.Tellmetext.text length] <= 8) {
       [self addpopview:@"多写两句吧"];
    }else{
        [self tellmeforhttp];
    }
}
//textview初始化
-(void)TextviewInit{
    self.textheard.text = @"建议与吐槽神马的，在这儿告诉我们吧";
    self.textheard.enabled = NO;//lable必须设置为不可用
    self.textheard.backgroundColor = [UIColor clearColor];
    self.Tellmetext.layer.contents = (id)[UIImage imageNamed:@"KUANG"].CGImage; //给图层添加背景图片
    [self.Tellmetext becomeFirstResponder];
}
//tableview里面加手势取消键盘
-(void)TapcancelKeyboard{
    //tableview里面加手势取消键盘
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidenKeyboard:)];
    tapGR.delegate = self;
    tapGR.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapGR];
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Screen.bounds.size.height/35;
}
- (IBAction)back:(UIButton *)sender {
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)hidenKeyboard:(UITapGestureRecognizer *)tapGR
{
    //放弃第一响应者身份
    [self.view endEditing:YES];
}
-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        self.textheard.text = @"建议与吐槽神马的，在这儿告诉我们吧";
    }else{
        self.textheard.text = @"";
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //判断加上输入的字符，是否超过界限
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (str.length > 500)
    {
        textView.text = [textView.text substringToIndex:500];
        return NO;
    }
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.textheard.text = @"建议与吐槽神马的，在这儿告诉我们吧";
    }else{
        self.textheard.text = @"";
    }
    if (textView.text.length >=500) {
        textView.text = [textView.text substringToIndex:500];
    }
}

//调用弹框视图
- (void)addpopview:(NSString*)title{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"Popview" owner:nil options:nil]; //&1
    self.popview = [views lastObject];
    [self.popview addpopview:self.popview andtitle:title];
    [self.view addSubview:self.popview];
    [self.popview cancelpopview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
