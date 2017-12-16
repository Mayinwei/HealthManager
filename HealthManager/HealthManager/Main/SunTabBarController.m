//
//  SunTabBarController.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunTabBarController.h"
#import "SunHomeViewController.h"
#import "SunAttentionViewController.h"
#import "SunDataViewController.h"
#import "SunMeViewController.h"
#import "SunNavigationController.h"

#import "SunChatViewController.h"
#import "SunMyServerTableViewController.h"
@interface SunTabBarController ()

@end

@implementation SunTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SunHomeViewController *home=[[SunHomeViewController alloc]init];
    SunDataViewController *data=[[SunDataViewController alloc] init];
    SunAttentionViewController *attention=[[SunAttentionViewController alloc]init];
    SunMeViewController *me=[[SunMeViewController alloc] init];
    
    
    [self setUpRootController:@"首页" image:@"Myhome" vc:home];
    [self setUpRootController:@"数据" image:@"File" vc:data];
    [self setUpRootController:@"关注" image:@"Explore" vc:attention];
    [self setUpRootController:@"我的" image:@"User" vc:me];
    
    //旧颜色
//    self.tabBar.tintColor=MrColor(0, 192, 248);
    self.tabBar.tintColor=MrColor(33, 135, 244);

}


-(void)setUpRootController:(NSString *)title image:(NSString *)imageName vc:(UIViewController *)vc
{
    vc.tabBarItem.image=[UIImage imageNamed:imageName];
    vc.tabBarItem.title=title;
    SunNavigationController *nav=[[SunNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];

}


//ios 10以下点击新消息跳转
- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        NSArray *vcArray = self.childViewControllers;
        //判断是否是聊天
        BOOL isChatView=NO;
        
        //需要跳转的控制器
        UINavigationController *firstNav=nil;
        for(UINavigationController *nav in vcArray)
        {
            
            for(UIViewController *vc in nav.viewControllers){
                if ([vc isKindOfClass:[SunHomeViewController class]]) {
                    firstNav=nav;
                }
            }
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
            [self setSelectedIndex:0];
            SunMyServerTableViewController *myServer=[[SunMyServerTableViewController alloc]init];
            [firstNav pushViewController:myServer animated:NO];
            SunChatViewController *chatViewController = nil;
            NSString *conversationChatter = userInfo[kConversationChatter];
            EMChatType messageType = [userInfo[kMessageType] intValue];
            
            
            chatViewController = [[SunChatViewController alloc] initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
            chatViewController.ChatCode=conversationChatter;
            [firstNav pushViewController:chatViewController animated:NO];
        }
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


- (void)didReceiveUserNotification:(UNNotification *)notification
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    if (userInfo)
    {
        NSArray *vcArray = self.childViewControllers;
        //判断是否是聊天
        BOOL isChatView=NO;
        
        //需要跳转的控制器
        UINavigationController *firstNav=nil;
        for(UINavigationController *nav in vcArray)
        {
            
            for(UIViewController *vc in nav.viewControllers){
                if ([vc isKindOfClass:[SunHomeViewController class]]) {
                    firstNav=nav;
                }
            }
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
            [self setSelectedIndex:0];
            SunMyServerTableViewController *myServer=[[SunMyServerTableViewController alloc]init];
            [firstNav pushViewController:myServer animated:NO];
            SunChatViewController *chatViewController = nil;
            NSString *conversationChatter = userInfo[kConversationChatter];
            EMChatType messageType = [userInfo[kMessageType] intValue];
            chatViewController = [[SunChatViewController alloc] initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
            chatViewController.ChatCode=conversationChatter;
            [firstNav pushViewController:chatViewController animated:NO];
        }
        
    }
}
@end
