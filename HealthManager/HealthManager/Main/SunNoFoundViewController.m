//
//  SunNoFoundViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunNoFoundViewController.h"

@interface SunNoFoundViewController ()

@end

@implementation SunNoFoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    UILabel *lable=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    lable.numberOfLines=0;
    [self.view addSubview:lable];
    lable.text=self.result;
    
    
}

@end
