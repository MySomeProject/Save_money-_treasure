//
//  OrderTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/17.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol OrderTableViewCelldelegate <NSObject>

-(void)OrderTableViewCellcancelMenumehod:(NSString*)ordernumber;
-(void)OrderTableViewCellpayMenumehod:(NSString*)ordernumber;

@end
@interface OrderTableViewCell : UITableViewCell
@property(weak,nonatomic)id<OrderTableViewCelldelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *ordernumber;
@property (weak, nonatomic) IBOutlet UILabel *orderstauts;
@property (weak, nonatomic) IBOutlet UILabel *carnumber;
@property (weak, nonatomic) IBOutlet UILabel *totelprice;
@property (weak, nonatomic) IBOutlet UIImageView *cplogin;
@property (weak, nonatomic) IBOutlet UILabel *cpname;
@property(nonatomic)BOOL istic;
@property (weak, nonatomic) IBOutlet UIButton *cacel;
@property (weak, nonatomic) IBOutlet UIButton *pay;
@property(nonatomic,copy)NSString* shangyexianbaodanhao;
@end
