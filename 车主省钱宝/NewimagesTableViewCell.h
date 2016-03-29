//
//  NewimagesTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/24.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewimagesTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
