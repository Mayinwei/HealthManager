//
//  SunPayResultModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/15.
//  Copyright © 2017年 马银伟. All rights reserved.
//  生成微信预支付订单

#import <Foundation/Foundation.h>

@interface SunPayResultModel : NSObject

@property(nonatomic,copy)NSString *Appid;
@property(nonatomic,copy)NSString *TotalSeconds;
@property(nonatomic,copy)NSString *NoncerStr;
@property(nonatomic,copy)NSString *Prepay_Id;
@property(nonatomic,copy)NSString *Order;
@end
