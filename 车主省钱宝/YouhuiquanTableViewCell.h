//
//  YouhuiquanTableViewCell.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YouhuiquanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgimage;
@property (weak, nonatomic) IBOutlet UILabel *zhucesong;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *isguoqi;
@property (weak, nonatomic) IBOutlet UILabel *yuan;

@property (weak, nonatomic) IBOutlet UILabel *usekind;
@end
