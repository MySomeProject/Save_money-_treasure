//
//  BSelectcityTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/14.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "BSelectcityTableViewController.h"
#import <AFHTTPRequestOperationManager.h>
#import "Utils.h"
#import "BSTableViewCell.h"
#import "UIButton+cbut.h"
#import "Lloadview.h"
@interface BSelectcityTableViewController ()
@property(nonatomic,retain)AFHTTPRequestOperationManager *manager;
@property(nonatomic,retain)NSArray *economizes;
@property(nonatomic,retain)NSMutableDictionary *showdic;
@property (weak, nonatomic) IBOutlet UIView *hostcityview;
@property(nonatomic,retain)UIImageView *isopen;
@property(nonatomic,retain)Lloadview *loadview;
@end

@implementation BSelectcityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
    self.economizes = [userinfo objectForKey:@"economizes"];
    [self heardview];
    if (!self.economizes) {
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
    [self.manager POST:@"http://zuihui.ebaochina.cn/city.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *response = responseObject;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
        self.economizes = (NSArray*)json;
        [self heardview];
        NSUserDefaults* userinfo = [NSUserDefaults standardUserDefaults];
        [userinfo setObject:self.economizes forKey:@"economizes"];
        [userinfo synchronize];
        [self.tableView reloadData];
        [self deleteView];
        NSLog(@"%@",json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self deleteView];
    }];
    
}
- (IBAction)refreah:(UIBarButtonItem *)sender {
    [self selectcityforhttp];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (section == 0) {
        
    }else{
        title.text = [self.economizes[section] objectForKey:@"name"];
        [heard addSubview:title];
        [heard addSubview:line];
        [heard addSubview:self.isopen];
        heard.tag = section;
        UITapGestureRecognizer* singletap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singletap:)];
        singletap.numberOfTapsRequired = 1;
        [singletap setNumberOfTouchesRequired:1];
        [heard addGestureRecognizer:singletap];
    }
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
//返回tabeview头的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }else{
        if (Screen.bounds.size.width == 320) {
                    return Screen.bounds.size.height/12;
        }else{
                  return Screen.bounds.size.height/14.5;
        }

    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.economizes.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary* json = self.economizes[section];
    if (section == 0) {
        return 0;
    }else{
        return [(NSArray*)[json objectForKey:@"city"] count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.showdic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.section]]) {
        if (indexPath.section == 0) {
            return 0;
        }else{
            if (Screen.bounds.size.width == 320) {
                return Screen.bounds.size.height/12;
            }else{
                return Screen.bounds.size.height/14.5;
            }
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.separatorInset=UIEdgeInsetsZero;
        cell.clipsToBounds = YES;
    NSDictionary* json = ((NSArray*)[self.economizes[indexPath.section] objectForKey:@"city"])[indexPath.row];
    if (indexPath.section == 0) {
    }else{
        cell.city.text = [json objectForKey:@"name"];
        cell.code.text = [json objectForKey:@"code"];
        cell.cp.text = [json objectForKey:@"cp"];
    }
    return cell;
}
-(void)heardview{
    for (UIView* v in self.hostcityview.subviews) {
        [v removeFromSuperview];
    }
    for (int i = 0; i<((NSArray*)[self.economizes[0] objectForKey:@"city"]).count; i++) {
        UIButton* carheard;
        if (Screen.bounds.size.width == 320) {
            if (Screen.bounds.size.height == 480) {
                carheard = [[UIButton alloc]initWithFrame:CGRectMake((i%3)*Screen.bounds.size.width/3.5+Screen.bounds.size.width/10, (i/3)*Screen.bounds.size.height/16+Screen.bounds.size.width/22 , Screen.bounds.size.width/4.5, Screen.bounds.size.height/18)];
            }else{
                carheard = [[UIButton alloc]initWithFrame:CGRectMake((i%3)*Screen.bounds.size.width/3.5+Screen.bounds.size.width/10, (i/3)*Screen.bounds.size.height/17+Screen.bounds.size.width/30 , Screen.bounds.size.width/4.5, Screen.bounds.size.height/20)];
            }

        }else{
            carheard = [[UIButton alloc]initWithFrame:CGRectMake((i%3)*Screen.bounds.size.width/3.5+Screen.bounds.size.width/10, (i/3)*Screen.bounds.size.height/20+Screen.bounds.size.width/36 , Screen.bounds.size.width/4.5, Screen.bounds.size.height/22)];
        }
        
        [carheard.layer setMasksToBounds:YES];
        [carheard.layer setCornerRadius:4.0]; //设置矩形四个圆角半径
        [carheard.layer setBorderWidth:0.5]; //边框宽度
        [carheard.layer setBorderColor:[UIColor lightGrayColor].CGColor];//边框颜色
        [carheard setTitle:[((NSArray*)[self.economizes[0] objectForKey:@"city"])[i] objectForKey:@"name"] forState:UIControlStateNormal];
        carheard.carid = [((NSArray*)[self.economizes[0] objectForKey:@"city"])[i] objectForKey:@"code"];
        carheard.carshouyi = [((NSArray*)[self.economizes[0] objectForKey:@"city"])[i] objectForKey:@"cp"];
        [carheard setBackgroundColor:[UIColor whiteColor]];
        [carheard setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [carheard addTarget:self action:@selector(savetitle:) forControlEvents:UIControlEventTouchUpInside];
        [self.hostcityview addSubview:carheard];
    }
}
-(void)savetitle:(UIButton*)sender{
    //添加 字典，将label的值通过key值设置传递
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@-%@-%@",sender.titleLabel.text,sender.carid,sender.carshouyi],@"bscity", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"bstocity" object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //添加 字典，将label的值通过key值设置传递
    BSTableViewCell* cell = (BSTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    NSString* sheng = [self.economizes[indexPath.section] objectForKey:@"name"];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%@-%@-%@-%@",cell.city.text,cell.code.text,cell.cp.text,sheng],@"bcity", nil];
    //创建通知
    NSNotification *notification =[NSNotification notificationWithName:@"btocity" object:nil userInfo:dict];
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
