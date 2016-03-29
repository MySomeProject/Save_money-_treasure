//
//  Popview.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/18.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Popview : UIView
@property (weak, nonatomic) IBOutlet UILabel *title;
-(void)addpopview:(UIView*)view andtitle:(NSString*)title;
-(void)cancelpopview;

@end
