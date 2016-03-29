//
//  DLYTableViewController.h
//  车主省钱宝
//
//  Created by chenghao on 15/2/13.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import "Popview.h"
@interface DLYTableViewController : UITableViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property(nonatomic,retain)Popview* popview;
@property (weak, nonatomic) IBOutlet UITextField *Username;
@property (weak, nonatomic) IBOutlet UITextField *Code;
@property (weak, nonatomic) IBOutlet UIButton *GetCode;
@property (weak, nonatomic) IBOutlet UIButton *xieyi;
@property (weak, nonatomic) IBOutlet UIButton *login;
@property(nonatomic,retain)NSString *gotopurpose;
@property(nonatomic,retain)NSString *comefrom;

@end
