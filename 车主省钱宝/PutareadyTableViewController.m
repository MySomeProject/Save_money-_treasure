//
//  PutareadyTableViewController.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "PutareadyTableViewController.h"
#import "PutorderTableViewController.h"
@interface PutareadyTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *baodanhao;
@end

@implementation PutareadyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray* strs = [self.orderid componentsSeparatedByString:@"-"];
    self.baodanhao.text = strs[1];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)chongxintijia:(UIButton *)sender {
    [self performSegueWithIdentifier:@"Editbaodan" sender:self.orderid];
}
- (IBAction)back:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Editbaodan"]) {
        PutorderTableViewController* pvc = segue.destinationViewController;
        pvc.ordernumber = sender;
    }
    
}


@end
