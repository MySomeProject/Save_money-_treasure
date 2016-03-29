//
//  Orderinfo.h
//  车主省钱宝
//
//  Created by chenghao on 15/5/28.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Orderinfo : NSObject
@property(nonatomic,copy)NSString* ordernumber;
@property(nonatomic,copy)NSString* shangyexianbaodanhao;
@property(nonatomic,copy)NSString* orderstats;
@property(nonatomic,copy)NSString* orderbaoxiangongsiimage;
@property(nonatomic,copy)NSString* orderbaoxiangongsiname;
@property(nonatomic,copy)NSString* ordercarnumber;
@property(nonatomic,copy)NSString* orderpriace;
@property(nonatomic,copy)NSString* ordercarownname;
@property(nonatomic,copy)NSString* ordercarownid;
@property(nonatomic,copy)NSString* orderarea;
@property(nonatomic,copy)NSString* orderxiadanshijian;
@property(nonatomic,copy)NSString* ordertoubaoren;
@property(nonatomic,copy)NSString* orderbeitoubaoren;
@property(nonatomic,copy)NSString* ordershoujianren;
@property(nonatomic,copy)NSString* orderphone;
@property(nonatomic,copy)NSString* orderaddress;
@property(nonatomic,copy)NSString* orderbaoxianqixian;
@property(nonatomic,copy)NSString* useRedAmount;
@property(nonatomic,copy)NSString* useAmount;
@property(nonatomic,retain)NSMutableArray* xianzhonglogo;
@property(nonatomic,retain)NSMutableArray* xianzhongname;
@property(nonatomic,retain)NSMutableArray* xianzhongprice;
@end
