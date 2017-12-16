//
//  SunBloodDetailModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/3.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunBloodDetailModel : NSObject
/**
 *  高压
 */
@property(nonatomic,strong)NSString *SYSTOLIC;
/**
 *  低压
 */
@property(nonatomic,strong)NSString *DIASTOLIC;
/**
 *  心率
 */
@property(nonatomic,strong)NSString *HEARTRATE;
/**
 *  结果
 */
@property(nonatomic,strong)NSString *RESULT;
/**
 *  时间
 */
@property(nonatomic,strong)NSString *STARTTIME;
//行号
@property(nonatomic,strong)NSString *ROWNUMBER;
@end
