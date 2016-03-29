//
//  StopTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/30.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol StopTableViewCelldelegate <NSObject>

-(void)StopTableViewCellMenumehod;

@end
@interface StopTableViewCell : UITableViewCell
@property(weak,nonatomic)id<StopTableViewCelldelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *stopday;
@property (weak, nonatomic) IBOutlet UIButton *stopbtu;

@end
