//
//  MywalletTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MywalletTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *kind;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *info;

@end
