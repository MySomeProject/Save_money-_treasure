//
//  NewimagesTableViewCell.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/24.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "NewimagesTableViewCell.h"

@implementation NewimagesTableViewCell

- (void)awakeFromNib {
    [self.image.layer setMasksToBounds:YES];
    [self.image.layer setCornerRadius:2.0]; //设置矩形四个圆角半径

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
