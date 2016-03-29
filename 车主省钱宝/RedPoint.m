//
//  RedPoint.m
//  车主省钱宝
//
//  Created by 魏强 on 15/6/8.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "RedPoint.h"

@implementation RedPoint

+(RedPoint *)shareRedPoint{
    
    static RedPoint *share = nil;
    if (share == nil) {
        share = [[RedPoint alloc] init];
    }
    
    return share;
}
-(void)addAccountArray:(NSMutableArray *)arr{
    
   // [self.AccountArray addObject:arr];
    for (NSString *str  in arr) {
        
        [self.AccountArray addObject:str];
    }
    
}
-(void)addSystemArray:(NSMutableArray *)arr{
    for (NSString *str in arr) {
        [self.SystemArray addObject:str];
    }
   // [self.SystemArray addObject:arr];
}
@end
