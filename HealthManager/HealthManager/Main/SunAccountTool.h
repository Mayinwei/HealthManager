//
//  SunAccountTool.h
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SunLogin;
@interface SunAccountTool : NSObject

+(void)saveSunLogin:(SunLogin *)login;

//获取账户信息
+(SunLogin *)getAccount;
@end
