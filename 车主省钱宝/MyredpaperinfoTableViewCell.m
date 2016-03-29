//
//  MyredpaperinfoTableViewCell.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/7.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "MyredpaperinfoTableViewCell.h"

@implementation MyredpaperinfoTableViewCell

- (void)awakeFromNib {
    [self.carnumber.layer setMasksToBounds:YES];
    [self.carnumber.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
