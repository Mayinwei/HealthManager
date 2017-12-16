//
//  SunSettingContactViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/22.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSettingContactViewController.h"

@interface SunSettingContactViewController ()

@end

@implementation SunSettingContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    CGFloat leftPadding=8;
    
    UILabel *labName=[[UILabel alloc]init];
    labName.font=kFont(16);
    labName.text=@"天津善医科技";
    [self.view addSubview:labName];
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
    
    UILabel *labe=[[UILabel alloc]init];
    labe.font=kFont(14);
    labe.text=@"电话:022-83570200, 83570210, 83570300";
    [self.view addSubview:labe];
    [labe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labName.mas_bottom).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
    
    UILabel *labe2=[[UILabel alloc]init];
    labe2.font=kFont(14);
    labe2.text=@"邮箱:shanyi@sun-ee.com";
    [self.view addSubview:labe2];
    [labe2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labe.mas_bottom).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
    
    UILabel *laber=[[UILabel alloc]init];
    laber.font=kFont(14);
    laber.text=@"微信公众账号: shanyidajiankang";
    [self.view addSubview:laber];
    [laber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labe2.mas_bottom).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
    
    UILabel *laberweima=[[UILabel alloc]init];
    laberweima.font=kFont(14);
    laberweima.text=@"微信公众号二维码";
    [self.view addSubview:laberweima];
    [laberweima mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(laber.mas_bottom).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
    
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shanyi"]];
    [self.view addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding);
        make.top.equalTo(laberweima.mas_bottom).offset(leftPadding);
        make.height.mas_equalTo(150);
        make.width.mas_equalTo(150);
    }];
    
    
    UILabel *labAdress=[[UILabel alloc]init];
    labAdress.font=kFont(14);
    labAdress.text=@"地址: 天津市南开区罗平道6号雅安光电园1门401A";
    [self.view addSubview:labAdress];
    [labAdress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(leftPadding);
        make.left.equalTo(self.view).offset(leftPadding);
    }];
}


@end
