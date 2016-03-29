//
//  NullView.h
//  车主省钱宝
//
//  Created by chenghao on 15/4/15.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NullViewdelegate <NSObject>

-(void)NullViewMenumehod;

@end
@interface NullView : UIView
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UIButton *but;
@property(weak,nonatomic)id<NullViewdelegate> delegate;
-(void)addpopview:(UIView*)view andtitle:(NSString*)title andbutitle:(NSString*)buttile;

@end
