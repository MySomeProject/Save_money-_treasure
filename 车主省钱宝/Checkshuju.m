//
//  Checkshuju.m
//  车主省钱宝
//
//  Created by chenghao on 15/5/20.
//  Copyright (c) 2015年 ebaochina. All rights reserved.
//

#import "Checkshuju.h"

@implementation Checkshuju
+(NSString*)checkshuju:(NSString*)str{
    NSArray* s = [[NSString stringWithFormat:@"%@",str] componentsSeparatedByString:@"."];
    if (s.count>1) {
        NSString* s1 = [s[1] substringToIndex:2];
        NSString* s2 = [NSString stringWithFormat:@"%@.%@",s[0],s1];
        return s2;
    }else{
        return [NSString stringWithFormat:@"%@.00",str];
    }


}
@end
