//
//  CPTableViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/13.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *carnumber;
@property (weak, nonatomic) IBOutlet UITextField *name;

@property (weak, nonatomic) IBOutlet UILabel *usedrive;
@property (weak, nonatomic) IBOutlet UIImageView *heardimage;
@property(nonatomic,copy)NSString* carinfo;
@end
