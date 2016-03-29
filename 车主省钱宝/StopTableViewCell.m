//
//  StopTableViewCell.m
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "StopTableViewCell.h"
#import "UIbuttonStyle.h"
@implementation StopTableViewCell

//- (void)awakeFromNib {
//    
//    [self.stopbtu setSelected:NO];
//    [UIbuttonStyle UIbuttonStyleDI:self.stopbtu];
//    [self.stopbtu setTitle:@"开车" forState:UIControlStateNormal];
//    // Initialization code
//}
- (IBAction)stop:(UIButton *)sender {
    if(sender.selected)
    {
        [sender setSelected:NO];
        [sender setTitle:@"开车" forState:UIControlStateNormal];
        [UIbuttonStyle UIbuttonStyleDI:sender];
    }else{
        [sender setSelected:YES];
        [sender setTitle:@"停驶" forState:UIControlStateNormal];
        [UIbuttonStyle UIbuttonStyleNO:sender];
    }
    [self.delegate StopTableViewCellMenumehod];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
