//
//  WritecarinfoTableViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Carinfo.h"

@interface WritecarinfoTableViewController : UITableViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *carnumberheard;
@property (weak, nonatomic) IBOutlet UITextField *carnumber;
@property (weak, nonatomic) IBOutlet UILabel *commonlyuseddriving;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property(nonatomic,copy)NSString* license_plate;
@property(nonatomic,copy)NSString* owner_name;
@property(nonatomic,retain)NSString *carid;
@property(nonatomic,retain)Carinfo *carinfo;
@property(nonatomic,retain)NSString *isaddcar;
@property(nonatomic,copy)NSString* comefrom;
@property(nonatomic,copy)NSString* httpcarid;
@end
