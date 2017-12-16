//
//  SunThirdData.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/23.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunThirdData : NSObject
/**
 *  类型
 */
@property(nonatomic,strong)NSString *TYPE;
/**
 *  值
 */
@property(nonatomic,strong)NSString *VALUESNUM;
/**
 *  高血糖服用时间
 */
@property(nonatomic,strong)NSString *LX;
/**
 *  结果
 */
@property(nonatomic,strong)NSString *RESULT;
/**
 *  时间
 */
@property(nonatomic,strong)NSString *STARTTIME;
@end
