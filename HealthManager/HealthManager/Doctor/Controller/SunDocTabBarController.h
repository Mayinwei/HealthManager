//
//  SunDocTabBarController.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/23.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface SunDocTabBarController : UITabBarController

//接收本地通知
- (void)didReceiveLocalNotification:(UILocalNotification *)notification;
//ios10点击接收到的消息
- (void)didReceiveUserNotification:(UNNotification *)notification;
@end
