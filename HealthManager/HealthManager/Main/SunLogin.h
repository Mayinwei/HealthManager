//
//  SunLogin.h
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunLogin : NSObject<NSCoding>
@property(nonatomic,copy)NSString *access_token;
@property(nonatomic,copy)NSString *usercode;
//用户类型 个人用户/机构用户
@property(nonatomic,copy)NSString *type;

+(instancetype)accessTokenWithDic:(NSDictionary *)idc;
-(instancetype)initWithDic:(NSDictionary *)dic;
@end
