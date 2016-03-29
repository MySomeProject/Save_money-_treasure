//
//  RedPoint.h
//  车主省钱宝
//
//  Created by 魏强 on 15/6/8.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedPoint : NSObject

+(RedPoint *)shareRedPoint;
@property(nonatomic,retain)NSMutableArray *AccountArray;
@property(nonatomic,retain)NSMutableArray *SystemArray;
-(void)addAccountArray:(NSMutableArray *)arr;
-(void)addSystemArray:(NSMutableArray *)arr;
@end
