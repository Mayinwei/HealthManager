//
//  SunViewItemModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunBasicModel.h"

@interface SunViewItemModel : SunBasicModel

@property(nonatomic,strong)UIView *myView;

+(instancetype)itemWithTitle:(NSString *)title view:(UIView *)view;
@end
