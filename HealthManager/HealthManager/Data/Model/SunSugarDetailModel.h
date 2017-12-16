//
//  SunSugarDetailModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/4.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunSugarDetailModel : NSObject
/**
 *  血糖值
 */
@property(nonatomic,strong)NSString *XTZ;
/**
 *  时间段
 */
@property(nonatomic,strong)NSString *XTLX;
/**
 *  时间
 */
@property(nonatomic,strong)NSString *CLSJ;
/**
 *  结果
 */
@property(nonatomic,strong)NSString *RESULT;
//行号
@property(nonatomic,strong)NSString *ROWNUMBER;
@end
