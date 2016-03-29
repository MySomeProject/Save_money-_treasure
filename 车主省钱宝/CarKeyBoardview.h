//
//  CarKeyBoardview.h
//  车主省钱宝
//
//  Created by chenghao on 15/3/19.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CarKeyBoardviewdelegate <NSObject>

-(void)Menumehod:(NSString*)text;

@end
@interface CarKeyBoardview : UIView
@property (weak, nonatomic) IBOutlet UIView *downview;
@property(weak,nonatomic)id<CarKeyBoardviewdelegate> delegate;
-(void)addcarheard;
@end
