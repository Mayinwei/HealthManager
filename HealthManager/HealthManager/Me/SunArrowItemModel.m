//
//  SunArrowItemModel.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  箭头类

#import "SunArrowItemModel.h"

@implementation SunArrowItemModel



+(instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass
{
    SunArrowItemModel *arrow=[self itemWithTitle:title destVcClass:destVcClass];
    arrow.icon=icon;
    return arrow;
}
+(instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass
{
    SunArrowItemModel *arrow=[[self alloc]init];
    arrow.title=title;
    arrow.destVcClass=destVcClass;
    return arrow;
}

@end
