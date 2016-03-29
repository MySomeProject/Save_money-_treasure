//
//  OrderTableViewCell.m
//  车主省钱宝
//
//  Created by chenghao on 15/3/17.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "OrderTableViewCell.h"
#import "UIbuttonStyle.h"
@implementation OrderTableViewCell

- (void)awakeFromNib {
    [UIbuttonStyle UIbuttonStyleNO:self.pay];
    [UIbuttonStyle UIbuttonStyleDI:self.cacel];
    [self.carnumber.layer setMasksToBounds:YES];
    [self.carnumber.layer setCornerRadius:2.0]; //设置矩形四个圆角半径
    // Initialization code
}
- (IBAction)cancelorder:(UIButton *)sender {
    [self.delegate OrderTableViewCellcancelMenumehod:self.ordernumber.text];
}
- (IBAction)payorder:(UIButton *)sender {
    [self.delegate OrderTableViewCellpayMenumehod:[NSString stringWithFormat:@"%@-%@",self.ordernumber.text,self.shangyexianbaodanhao]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
