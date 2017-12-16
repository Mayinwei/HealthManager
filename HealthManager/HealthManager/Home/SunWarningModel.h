//
//  SunWarningModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/5.
//  Copyright © 2017年 马银伟. All rights reserved.
//  告警模板

#import <Foundation/Foundation.h>

@interface SunWarningModel : NSObject

@property(nonatomic,strong)NSString *WARNLEVEL;
@property(nonatomic,strong)NSString *CHECKVALUE;
@property(nonatomic,strong)NSString *CHECKTIME;
@property(nonatomic,strong)NSString *WARNTYPE;
@end
