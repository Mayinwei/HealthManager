//
//  SunLogin.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunLogin.h"

@implementation SunLogin

-(instancetype)initWithDic:(NSDictionary *)dic
{
    if (self=[super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
+(instancetype)accessTokenWithDic:(NSDictionary *)dic
{
    return [[self alloc]initWithDic:dic];
}



#pragma mark --写入数据
-(void)encodeWithCoder:(NSCoder *)encode
{
   // [super encodeWithCoder:aCoder];
    [encode encodeObject:self.access_token forKey:@"access_token"];
    [encode encodeObject:self.usercode forKey:@"usercode"];
    [encode encodeObject:self.type forKey:@"type"];
}


//解析文件
-(id)initWithCoder:(NSCoder *)decoder
{
    if (self=[super init]) {
        self.access_token=[decoder decodeObjectForKey:@"access_token"];
        self.usercode=[decoder decodeObjectForKey:@"usercode"];
        self.type=[decoder decodeObjectForKey:@"type"];
    }
    return self;
}
@end
