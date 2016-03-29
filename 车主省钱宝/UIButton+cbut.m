//
//  UIButton+cbut.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/12.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "UIButton+cbut.h"
#import <objc/runtime.h>
static const void *CaridKey = &CaridKey;
static const void *CarnumberKey = &CarnumberKey;
static const void *CarshouyiKey = &CarshouyiKey;
@implementation UIButton (cbut)
@dynamic carid;
@dynamic carnumber;

- (NSString *)carid {
    return objc_getAssociatedObject(self,CaridKey);
}
- (NSString *)carnumber {
    return objc_getAssociatedObject(self,CarnumberKey);
}
- (NSString *)carshouyi {
    return objc_getAssociatedObject(self,CarshouyiKey);
}
-(void)setCarid:(NSString *)carid{
       objc_setAssociatedObject(self,CaridKey, carid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setCarnumber:(NSString *)carnumber{
    objc_setAssociatedObject(self,CarnumberKey, carnumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)setCarshouyi:(NSString *)carshouyi{
    objc_setAssociatedObject(self,CarshouyiKey, carshouyi, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
