//
//  Utils.h
//  chebao
//
//  Created by chenghao on 14/11/6.
//  Copyright (c) 2014年 ebaochina. All rights reserved.
//

#ifndef chebao_Utils_h
#define chebao_Utils_h

#define Screen  [UIScreen mainScreen]
#define MessageItemsOffset [UIScreen mainScreen].bounds.size.width/6
#define Iphone5MessageItemsOffset [UIScreen mainScreen].bounds.size.width/4
#define NaviHight self.navigationController.navigationBar.frame.size.height
//#define BaseUrl @"http://yuxianbao.ebaochina.cn/yuxianbao/api/v2"
#define BaseUrl @"http://58.135.80.72:8080/yuxianbao/api/v2"
#define RequestHead  @{@"platform":@"ios",@"version":@"2.0",@"store":@"10000"}

#endif
