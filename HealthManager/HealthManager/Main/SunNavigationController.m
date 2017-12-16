//
//  SunNavigationController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  导航栏

#import "SunNavigationController.h"

@interface SunNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation SunNavigationController
/**
 *  这个只调用一次，当有子类时，子类没有这个方法他会在调用一次
 */
+(void)initialize
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
-(void)viewDidLoad{
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [UIApplication sharedApplication].statusBarHidden=NO;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    // 设置代理
    //id target = self.interactivePopGestureRecognizer.delegate;
    // 创建手势
   // UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    // 设置pan手势的代理
   // pan.delegate = self;
    // 添加手势
   // [self.view addGestureRecognizer:pan];
    // 将系统自带的手势覆盖掉
    self.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark --手势代理
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.childViewControllers.count>1;
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
        [backBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
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
