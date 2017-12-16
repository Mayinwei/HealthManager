//
//  SunLableItemModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  显示lable的

#import "SunBasicModel.h"

@interface SunLableItemModel : SunBasicModel

@property(nonatomic,strong)NSString *rightTitle;


+(instancetype)itemWithIcon:(NSString *)icon leftTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle;
+(instancetype)itemWithTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle;
@end
