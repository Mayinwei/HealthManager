//
//  SunSettingTableViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSettingTableViewController.h"
#import "SunGroupModel.h"
#import "SunLableItemModel.h"
#import "SunArrowItemModel.h"
#import "SunLogViewController.h"
#import "SunFunctionViewController.h"
#import "SunSettingContactViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <Hyphenate/EMSDK.h>
#define CellHeightSetting 35
@interface SunSettingTableViewController ()

@end

@implementation SunSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    

    [self setUpGroup0];
    [self setUpGroup1];
    
    //添加底部按钮
    UIView *bottomView=[[UIView alloc]init];
    bottomView.frame=CGRectMake(0, 15, SCREEN_WIDTH, 60);
    self.tableView.tableFooterView=bottomView;
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font=kFont(15);
    [btn setTitle:@"切换账号" forState:UIControlStateNormal];
    [btn setBackgroundImage:[self createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:btn];
    btn.frame=CGRectMake(0, 20, SCREEN_WIDTH, 40);
    
}

-(void)completeClick
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    //文件名
    NSString *path=[doc stringByAppendingPathComponent:@"account.data"];
    [fileManager removeItemAtPath:path error:nil];
    
    if(iOSVersion>=10.0){
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }else{
        //清除本地通知
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    //登出环信
    [[EMClient sharedClient] logout:YES];
    self.view.window.rootViewController=[[SunLogViewController alloc] init];
}

//颜色转图片
-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)setUpGroup0
{
    SunGroupModel *group=[self addToArrayData];
    SunArrowItemModel *arrow1=[SunArrowItemModel itemWithTitle:@"功能介绍" destVcClass:[SunFunctionViewController class]];
    arrow1.cellHeight=CellHeightSetting;
    group.items=@[arrow1];
}

-(void)setUpGroup1
{
    SunGroupModel *group=[self addToArrayData];
    //SunArrowItemModel *arrow1=[SunArrowItemModel itemWithTitle:@"帮助" destVcClass:nil];
    //SunArrowItemModel *arrow2=[SunArrowItemModel itemWithTitle:@"关于" destVcClass:nil];
    //获取版本号
    NSString *currentVersion=[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    
    SunLableItemModel *arrow2=[SunLableItemModel itemWithTitle:@"版本" rightTitle:[NSString stringWithFormat:@"V %@",currentVersion]];
    SunArrowItemModel *arrow3=[SunArrowItemModel itemWithTitle:@"联系我们" destVcClass:[SunSettingContactViewController class]];
    //arrow1.cellHeight=CellHeightSetting;
    arrow2.cellHeight=CellHeightSetting;
    arrow3.cellHeight=CellHeightSetting;
    group.items=@[arrow2,arrow3];
}

@end
