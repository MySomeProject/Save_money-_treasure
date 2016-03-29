//
//  Noweizhang.h
//  车主省钱宝
//
//  Created by chenghao on 15/6/4.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Noweizhang : UIView

@property (weak, nonatomic) IBOutlet UILabel *info;
-(void)addpopview:(UIView*)view andtitle:(NSString*)title;
@end
