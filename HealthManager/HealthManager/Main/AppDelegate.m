//
//  AppDelegate.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/6.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "SunTool.h"
#import "SunLogViewController.h"
#import "UIImageView+WebCache.h"
#import "WXApi.h"
#import <Hyphenate/EMSDK.h>

#import "SunAccountTool.h"
#import "SunLogin.h"
#import "DemoCallManager.h"

#import "AppDelegate+EaseMob.h"
#import "SunNewFeatureViewController.h"
#import "SunDocTabBarController.h"
#import "SunTabBarController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate,WXApiDelegate>

@end
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //注册微信支付
    [WXApi registerApp:@"wx1ff6993d14670f05"];
    
    
    
    
    
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor whiteColor];
    //设置根控制器   
    UIViewController *vc= (UIViewController *)[SunTool ChooseViewController];
    self.mainViewController=vc;
    //注册环信推送
    [self easemobApplication:application
didFinishLaunchingWithOptions:launchOptions
                      appkey:@"1136170213178188#healthmanager"
                apnsCertName:@"HealthManagerSenPush"
                 otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:NO]}];
    
    //判断自己登录系统和环信登录跳转页是否为一个
    if([vc isKindOfClass:[SunNewFeatureViewController class]])
    {
        //新特性
        self.window.rootViewController=vc;
    }else if([vc class]==[self.mainViewController class]){
        //主页
        self.window.rootViewController=self.mainViewController;
        [[DemoCallManager sharedManager] setMainController:self.mainViewController];
    }else if([self.mainViewController isKindOfClass:[SunLogViewController class]]||[vc isKindOfClass:[SunLogViewController class]]){
        //登录界面
        self.window.rootViewController=[[SunLogViewController alloc]init];
    }
    
    [self.window makeKeyAndVisible];

    
    if (iOSVersion> 8.0&&iOSVersion<10.0)
    {
        UIUserNotificationType type=UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge;//顶部弹窗模式
        
        UIUserNotificationSettings *settings=[UIUserNotificationSettings settingsForTypes:type categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else if(iOSVersion <=7.0)
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    else if (iOSVersion>=10.0)
    {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    
    return YES;
}

//APP进入后台
-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}
//APP从后台返回前台
-(void)applicationWillEnterForeground:(UIApplication *)application
{
    //清空badgeValue
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


#pragma mark --ios10消息推送协议
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    //NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    //功能：可设置是否在应用内弹出通知
    completionHandler(UNNotificationPresentationOptionAlert);
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    [self easemobApplication:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

//点击推送消息后回调
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    //如果是关注
    if([response.notification.request.content.body rangeOfString:@"关注"].location != NSNotFound){
        //发送通知跳转界面
        NSDictionary *dic=[NSDictionary dictionaryWithObject:@"SunAttentionRequestTableViewController"forKey:@"Info"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SunHomeViewController" object:self userInfo:dic];
    }
    
    if (_mainViewController) {
        if([_mainViewController isKindOfClass:[SunTabBarController class]]){
            SunTabBarController *tab=(SunTabBarController *)_mainViewController;
            [tab didReceiveUserNotification:response.notification];
        }else{
            //医生端接收到消息
            SunDocTabBarController *tab=(SunDocTabBarController *)_mainViewController;
            [tab didReceiveUserNotification:response.notification];
        }
    }
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:[self stringWithDeviceToken:deviceToken] forKey:@"deviceToken"];
    //同步
    [userDefault synchronize];
    //将用户设备token添加到环信
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

-(NSString *)stringWithDeviceToken:(NSData *)deviceToken
{
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++)
    {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

//接受本地推送通知
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if([[notification.userInfo objectForKey:@"id"] isEqualToString:@"sun.location"])
    {
        
        //判断设备状态
        if (application.applicationState==UIApplicationStateActive) {
            if (iOSVersion<10.0) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"用药提醒" message:[NSString stringWithFormat:@"请服用:%@",[notification.userInfo objectForKey:@"name"]] preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                            [alert addAction:cancelAction];
                            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            };
        }
    }
    
    if (_mainViewController) {
        if([_mainViewController isKindOfClass:[SunTabBarController class]]){
            SunTabBarController *tab=(SunTabBarController *)_mainViewController;
            [tab didReceiveLocalNotification:notification];
        }else{
            //医生端接收到消息
            SunDocTabBarController *tab=(SunDocTabBarController *)_mainViewController;
            [tab didReceiveLocalNotification:notification];
        }
        
    }
}

//接受远程推送消息，点击进来
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo
{
    if (application.applicationState==UIApplicationStateActive) {
        //如果是激活状态
        if(iOSVersion<10.0){
            NSDictionary *dicNot=userInfo[@"aps"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"关注提醒" message: dicNot[@"alert"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if([userInfo[@"alert"] rangeOfString:@"关注"].location != NSNotFound){
                    //发送通知跳转界面
                    NSDictionary *dic=[NSDictionary dictionaryWithObject:@"SunAttentionRequestTableViewController"forKey:@"Info"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SunHomeViewController" object:self userInfo:dic];
                }
                
            }];
            
            [alert addAction:cancelAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }else{
        if(iOSVersion<10.0){
            if([userInfo[@"alert"] rangeOfString:@"关注"].location != NSNotFound){
                //发送通知跳转界面
                NSDictionary *dic=[NSDictionary dictionaryWithObject:@"SunAttentionRequestTableViewController"forKey:@"Info"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SunHomeViewController" object:self userInfo:dic];
            }
        }
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //内存警告，清除缓存
    [[SDImageCache sharedImageCache] clearDisk];
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options{

    /*! @brief 处理微信通过URL启动App时传递的数据
     *
     * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
     * @param url 微信启动第三方应用时传递过来的URL
     * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
     * @return 成功返回YES，失败返回NO。
     */
    return [WXApi handleOpenURL:url delegate:self];
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp
{
    switch (resp.errCode) {
        case WXSuccess:
            //跳转到我的服务页面
            [self jumpMySer];
            break;
        default:
            [self showErrorPay:resp.errStr];
            break;
    }
}

-(void)jumpMySer
{
    //跳转到我的服务页面
    SunTabBarController *tab=(SunTabBarController *)self.window.rootViewController;
    UINavigationController *nav=tab.childViewControllers[0];
    [nav.topViewController.navigationController popToViewController:[nav.viewControllers objectAtIndex:1] animated:YES];
    //发出通知更改订单状态
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatePayStatus" object:self userInfo:nil];
}
//显示错误信息
-(void)showErrorPay:(NSString *)errStr
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"支付错误" message:[NSString stringWithFormat:@"支付失败:%@",errStr] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

}

//3D Touch快速启动
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    //判断用户类型
    SunLogin *login=[SunAccountTool getAccount];
    if(login==nil){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请先登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return
        ;
    }
    if ([login.type isEqualToString:@"机构用户"] ) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该功能只在个人端使用" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        return
        ;
    }
    
    NSDictionary *dic=[NSDictionary dictionaryWithObject:shortcutItem.localizedTitle forKey:@"type"];
    if([shortcutItem.localizedTitle isEqualToString:@"扫一扫"]){
        SunTabBarController *tab=(SunTabBarController *)self.mainViewController;
        tab.selectedIndex=0;
        UINavigationController  *nav=tab.childViewControllers[0];
        UIViewController *vc=[nav.viewControllers firstObject];
        
        //用于接收系统3D touch的点击
        [[NSNotificationCenter defaultCenter] addObserver:vc selector:@selector(showScan:) name:@"myHomeTouch" object:nil];
        //扫一扫
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myHomeTouch" object:self userInfo:dic];
    }else{
        SunTabBarController *tab=(SunTabBarController *)self.mainViewController;
        tab.selectedIndex=3;
        UINavigationController  *nav=tab.childViewControllers[3];
        UIViewController *vc=[nav.viewControllers firstObject];
        
        //用于接收系统3D touch的点击
        [[NSNotificationCenter defaultCenter] addObserver:vc selector:@selector(showScan:) name:@"myHomeTouch" object:nil];
        //我的二维码
        [[NSNotificationCenter defaultCenter] postNotificationName:@"myHomeTouch" object:self userInfo:dic];
    }
}


@end
