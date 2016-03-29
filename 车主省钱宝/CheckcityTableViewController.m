//
//  CheckcityTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/27.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "CheckcityTableViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import "Lloadview.h"
#import "Utils.h"
#import "CheckcityTableViewCell.h"
@interface CheckcityTableViewController ()
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)Lloadview *loadview;
@property(nonatomic,retain)UIImageView *isopen;
@property(nonatomic,retain)NSArray *checkeconomizes;
@property(nonatomic,retain)NSMutableDictionary *showdic;
@end

@implementation CheckcityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    self.checkeconomizes = [userinfo objectForKey:@"checkeconomizes"];
    if (!self.checkeconomizes) {
        [self selectcityforhttp];
    }

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
-(void)selectcityforhttp{
    [self delayView];
    [self.manager POST:@"http://static.ebaochina.cn/js/citys.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        self.checkeconomizes = (NSArray*)json;
        NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
        [userinfo setObject:self.checkeconomizes forKey:@"checkeconomizes"];
        [userinfo synchronize];
        [self.tableView reloadData];
        
        [self deleteView];
        NSLog(@"%@",json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
    
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* heard = [[UIView alloc]initWithFrame:CGRectMake(15, 0, Screen.bounds.size.width, Screen.bounds.size.width/14.5)];
    UIView* line;
    if (Screen.bounds.size.width==320) {
        line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen.bounds.size.width, 0.5)];
    }else{
        line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen.bounds.size.width, 0.4)];
    }
    self.isopen = [[UIImageView alloc]initWithFrame:CGRectMake(Screen.bounds.size.width*0.9, heard.bounds.size.height/1.5, Screen.bounds.size.width/30, Screen.bounds.size.width/29)];
    self.isopen.image = [UIImage imageNamed:@"arrow_down"];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    heard.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1];
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, heard.bounds.size.width, heard.bounds.size.height)];
    title.text = [self.checkeconomizes[section] objectForKey:@"province"];
    [heard addSubview:title];
    [heard addSubview:line];
    [heard addSubview:self.isopen];
    heard.tag = section;
    UITapGestureRecognizer* singletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singletap:)];
    singletap.numberOfTapsRequired = 1;
    [singletap setNumberOfTouchesRequired:1];
    [heard addGestureRecognizer:singletap];
    return heard;
}
-(void)singletap:(UITapGestureRecognizer*)recognizer{
    NSInteger didselection = recognizer.view.tag;
    if (!self.showdic) {
        self.showdic = [[NSMutableDictionary alloc]init];
    }
    NSString* key = [NSString stringWithFormat:@"%ld",didselection];
    if (![self.showdic objectForKey:key]) {
        [self.showdic setObject:@"1" forKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didselection] withRowAnimation:UITableViewRowAnimationFade];
        [self.isopen setImage:[UIImage imageNamed:@"arrow_right"]];
    }else{
        [self.showdic removeObjectForKey:key];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:didselection] withRowAnimation:UITableViewRowAnimationFade];
        [self.isopen setImage:[UIImage imageNamed:@"arrow_down"]];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (Screen.bounds.size.width == 320) {
        return Screen.bounds.size.height/12;
    }else{
        return Screen.bounds.size.height/14.5;
    }

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.showdic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
        if (Screen.bounds.size.width == 320) {
            return Screen.bounds.size.height/12;
        }else{
            return Screen.bounds.size.height/14.5;
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.checkeconomizes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary* json = self.checkeconomizes[section];
    return [(NSArray*)[json objectForKey:@"citys"] count];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckcityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset=UIEdgeInsetsZero;
    cell.clipsToBounds = YES;
    NSDictionary* json = ((NSArray*)[self.checkeconomizes[indexPath.section] objectForKey:@"citys"])[indexPath.row];
    cell.cityname.text = [json objectForKey:@"city_name"];
    cell.shengcode.text = [self.checkeconomizes[indexPath.section] objectForKey:@"province_code"];
    cell.shicode.text = [json objectForKey:@"city_code"];
    cell.classa = [NSString stringWithFormat:@"%@",[json objectForKey:@"classa"]];
    cell.engine = [NSString stringWithFormat:@"%@",[json objectForKey:@"engine"]];
    // Configure the cell...
    
    return cell;
}
- (IBAction)refresh:(UIBarButtonItem *)sender {
    [self selectcityforhttp];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //添加 字典，将label的值通过key值设置传递
    CheckcityTableViewCell* cell = (CheckcityTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@-%@-%@-%@-%@",cell.shengcode.text,cell.shicode.text,cell.cityname.text,cell.classa,cell.engine],@"Ccity", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"Ctocity" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popViewControllerAnimated:YES];
}
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
