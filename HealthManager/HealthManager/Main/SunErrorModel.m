
//
//  SunErrorModel.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/26.
//  Copyright © 2016年 马银伟. All rights reserved.
//  错误模型

#import "SunErrorModel.h"
#import "MJExtension.h"
@implementation SunErrorModel

//判断是否有错误
+(instancetype)sunErroWithArray:(id)json
{
    SunErrorModel *errorModel=[SunErrorModel mj_objectWithKeyValues:json];
    return errorModel;
}
@end
