//
//  SunLableItemModel.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunLableItemModel.h"

@implementation SunLableItemModel

+(instancetype)itemWithTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle
{
    SunLableItemModel *item=[[self alloc]init];
    item.title=leftTitle;
    item.rightTitle=rightTitle;
    return item;
}

+(instancetype)itemWithIcon:(NSString *)icon leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle
{
    SunLableItemModel *item=[self itemWithTitle:leftTitle rightTitle:rightTitle];
    item.icon=icon;    
    return item;
}
@end
