//
//  SunDocTabBarController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/23.
//  Copyright © 2017年 马银伟. All rights reserved.
//  医生tab

#import "SunDocTabBarController.h"
#import "SunDocNavigationController.h"
#import "SunDocHomeViewController.h"
#import "SunDocPatientViewController.h"
#import "SunMeViewController.h"
#import "SunChatViewController.h"
@interface SunDocTabBarController ()

@end

@implementation SunDocTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SunDocHomeViewController *home=[[SunDocHomeViewController alloc]init];
    SunDocPatientViewController *patient=[[SunDocPatientViewController alloc]init];
    SunMeViewController *my=[[SunMeViewController alloc]init];
    [self addChileWithImgName:@"Myhome" title:@"首页" vc:home];
    [self addChileWithImgName:@"Explore" title:@"患者" vc:patient];
    [self addChileWithImgName:@"User" title:@"我" vc:my];
    
    self.tabBar.tintColor=MrColor(33, 135, 244);
}


-(void)addChileWithImgName:(NSString *)name title:(NSString *)title vc:(UIViewController *)vc{
    vc.tabBarItem.title=title;
    vc.tabBarItem.image=[UIImage imageNamed:name];
    SunDocNavigationController *nav=[[SunDocNavigationController alloc]initWithRootViewController:vc];
    
    [self addChildViewController:nav];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"患者"]) {
        NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
        [userDefault setObject:@"" forKey:@"SearchType"];
    }
    
}


- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

//ios10点击消息跳转
- (void)didReceiveUserNotification:(UNNotification *)notification
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo)
    {
        NSArray *vcArray = self.childViewControllers;
        //判断是否是聊天
        BOOL isChatView=NO;
        
        for(UINavigationController *nav in vcArray)
        {
            //判断是否是聊天界面
            if([[[nav viewControllers] lastObject] isKindOfClass:[SunChatViewController class]])
            {
                isChatView=YES;
            }else{
                //退回到每个根控制器
                [nav popToRootViewControllerAnimated:NO];
            }
        }
        if (!isChatView) {
            [self setSelectedIndex:1];
        }
        
    }
}

//ios 10以下点击新消息跳转
- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo =  notification.userInfo;
    if (userInfo)
    {
        NSArray *vcArray = self.childViewControllers;
        //判断是否是聊天
        BOOL isChatView=NO;
        
        for(UINavigationController *nav in vcArray)
        {
            //判断是否是聊天界面
            if([[[nav viewControllers] lastObject] isKindOfClass:[SunChatViewController class]])
            {
                isChatView=YES;
            }else{
                //退回到每个根控制器
                [nav popToRootViewControllerAnimated:NO];
            }
        }
        if (!isChatView) {
            [self setSelectedIndex:1];
        }
        
    }
}



@end
