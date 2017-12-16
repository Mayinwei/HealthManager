//
//  SunArrowItemModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunBasicModel.h"

@interface SunArrowItemModel : SunBasicModel
/**
 *  需要跳转的控制器
 */
@property (nonatomic,assign) Class destVcClass;


+(instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title destVcClass:(Class)destVcClass;
+(instancetype)itemWithTitle:(NSString *)title destVcClass:(Class)destVcClass;
@end
