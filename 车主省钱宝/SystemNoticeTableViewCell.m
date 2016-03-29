//
//  SystemNoticeTableViewCell.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/9.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "SystemNoticeTableViewCell.h"

@implementation SystemNoticeTableViewCell

- (void)awakeFromNib {
    self.time.layer.cornerRadius = 3.f;
    self.time.clipsToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
