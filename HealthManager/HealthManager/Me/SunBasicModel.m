//
//  SunBasicModel.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunBasicModel.h"

@implementation SunBasicModel
//快速创建item
+(instancetype)item
{
    return [[self alloc]init];
}
+(instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title{
    SunBasicModel *item=[self item];
    item.icon=icon;
    item.title=title;
    return item;
}
+(instancetype)itemWithTitle:(NSString *)title
{
    SunBasicModel *item=[self item];
    item.title=title;
    return item;
}
@end
