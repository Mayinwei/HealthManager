//
//  SunDocNavigationController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/23.
//  Copyright © 2017年 马银伟. All rights reserved.
//  医生导航控制器

#import "SunDocNavigationController.h"

@interface SunDocNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation SunDocNavigationController

//初始化导航控制器
+ (void)initialize
{
    UINavigationBar *navBar=[UINavigationBar appearance];
    [navBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    //设置导航栏的字体
    NSMutableDictionary *textAttr=[NSMutableDictionary dictionary];
    textAttr[UITextAttributeTextColor]=[UIColor whiteColor];
    //设置阴影为0
    textAttr[UITextAttributeTextShadowOffset]=[NSValue valueWithUIOffset:UIOffsetZero];
    textAttr[UITextAttributeFont]=[UIFont systemFontOfSize:19];
    [navBar setTitleTextAttributes:textAttr];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden=NO;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

//解决和tablecell滑动删除手势冲突
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (self.view && [[self.view gestureRecognizers] containsObject:gestureRecognizer]) {
            CGPoint tPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:gestureRecognizer.view];
            if (tPoint.x >= 0) {
                CGFloat y = fabs(tPoint.y);
                CGFloat x = fabs(tPoint.x);
                CGFloat af = 30.0f/180.0f * M_PI;
                
                CGFloat tf = tanf(af);
                if ((y/x) <= tf) {
                    return YES;
                }
                return NO;
            }else{
                return NO;
            }
        }
        
    }
    
    return YES;
}


//拦截跳转
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //隐藏底部工具条
    if (self.viewControllers.count>0) {
        viewController.hidesBottomBarWhenPushed=YES;
        //设置返回按钮
        UIButton *backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setBackgroundImage:[UIImage imageNamed:@"foward-left"] forState:UIControlStateNormal];
        backBtn.frame=(CGRect){CGPointZero,backBtn.currentBackgroundImage.size};
        viewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
        [backBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [super pushViewController:viewController animated:animated];
    
}
-(void)close
{
    [self popViewControllerAnimated:YES];
}

@end
