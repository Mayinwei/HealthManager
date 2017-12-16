//
//  SunAccountTool.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  账户工具类

#import "SunAccountTool.h"
#import "SunLogin.h"
@implementation SunAccountTool



//本地化账户信息
+(void)saveSunLogin:(SunLogin *)login
{
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *path=[doc stringByAppendingPathComponent:@"account.data"];
    //持久化
    [NSKeyedArchiver archiveRootObject:login toFile:path];
}


//获取账户信息
+(SunLogin *)getAccount
{
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path=[doc stringByAppendingPathComponent:@"account.data"];
    SunLogin *login= [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    return login;
}
@end
