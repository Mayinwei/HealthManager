//
//  SunTool.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunTool.h"
#import "SunLogViewController.h"
#import "SunLogin.h"
#import "SunAccountTool.h"
#import "SunTabBarController.h"
#import "SunNewFeatureViewController.h"
#import "SunDocTabBarController.h"
@implementation SunTool


+(UIViewController *)ChooseViewController
{
    UIViewController *vc=[[UIViewController alloc]init];
    //获取版本号
    NSUserDefaults *userDefaule=[NSUserDefaults standardUserDefaults];
    NSString *lastVersion=[userDefaule objectForKey:@"lastVersion"];
    //当前版本号
    NSString *currentVersion=[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    if ([lastVersion isEqualToString:lastVersion]) {
        //判断是否登录
        SunLogin *login=[SunAccountTool getAccount];
        if (login==nil) {
            vc=[[SunLogViewController alloc]init];
        }else if([login.type isEqualToString:@"个人用户"]){
            vc=[[SunTabBarController alloc]init];
        }else if([login.type isEqualToString:@"机构用户"]){
            vc=[[SunDocTabBarController alloc]init];
        }
        
    }else{
        //跳转新特性
        //隐藏状态栏
        [UIApplication sharedApplication].statusBarHidden=YES;
        vc=[[SunNewFeatureViewController alloc]init];
        
        //设置版本号
        [userDefaule setObject:currentVersion forKey:@"lastVersion"];
        [userDefaule synchronize];       
    }
    return vc;
}
@end
