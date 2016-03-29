//
//  CheckcityTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/27.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckcityTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cityname;
@property (weak, nonatomic) IBOutlet UILabel *shengcode;
@property (weak, nonatomic) IBOutlet UILabel *shicode;
@property(nonatomic,copy)NSString* classa;
@property(nonatomic,copy)NSString* engine;
@end
