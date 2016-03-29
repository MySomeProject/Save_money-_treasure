//
//  OrderinfoTableViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Orderinfo.h"
@interface OrderinfoTableViewController : UITableViewController<UIAlertViewDelegate>
@property(nonatomic,retain)Orderinfo* orderinfo;
@end
