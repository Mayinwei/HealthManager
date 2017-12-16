//
//  SunViewItemModel.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  视图类型

#import "SunViewItemModel.h"

@implementation SunViewItemModel


+(instancetype)itemWithTitle:(NSString *)title view:(UIView *)view
{
    SunViewItemModel *viewItem=[[self alloc]init];
    viewItem.myView=view;
    viewItem.title=title;
    return viewItem;
}
@end
