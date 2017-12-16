//
//  SunServerCategoryViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//  服务分类

#import "SunServerCategoryViewController.h"
#import "SunSearchServerViewController.h"

@interface SunServerCategoryViewController ()

@end

@implementation SunServerCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"服务分类";
    self.view.backgroundColor=MrColor(240, 240, 240);
    [self setMain];
}

-(void)setMain
{
    UITapGestureRecognizer *zhuanTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuanClick)];
    UIView *zhuanView=[self getViewWithImg:@"svr_01" title:@"专项" secondTitle:@"血压/血糖 专项管理专家"];
    [zhuanView addGestureRecognizer:zhuanTap];
    [self.view addSubview:zhuanView];
    UILabel *lb=zhuanView.subviews[1];
    lb.textColor=MrColor(159, 214, 253);
    [zhuanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(80);
    }];
    
    UITapGestureRecognizer *dingTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dingClick)];
    UIView *dingView=[self getViewWithImg:@"svr_02" title:@"定制" secondTitle:@"为您打造一对一专家VIP服务"];
    [dingView addGestureRecognizer:dingTap];
    [self.view addSubview:dingView];
    UILabel *zlb=dingView.subviews[1];
    zlb.textColor=MrColor(99, 203, 193);
    [dingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.top.equalTo(zhuanView.mas_bottom);
        make.height.equalTo(zhuanView);
    }];
}


-(UIView *)getViewWithImg:(NSString *)imgName title:(NSString *)title secondTitle:(NSString *)secondTitle
{
    UIView *totalView=[[UIView alloc]init];
    totalView.backgroundColor=[UIColor whiteColor];
    
    //图片
    CGFloat padding=13;
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imgName]];
    [totalView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(totalView).offset(padding);
        make.top.equalTo(totalView).offset(padding);
        make.bottom.equalTo(totalView).offset(-padding);
        make.width.equalTo(imgView.mas_height);
    }];
    
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=title;
    labTitle.font=[UIFont systemFontOfSize:22 weight:50];
    [totalView addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(padding);
        make.top.equalTo(imgView);
    }];
    
    UILabel *labSecond=[[UILabel alloc]init];
    labSecond.text=secondTitle;
    labSecond.font=kFont(15);
    labSecond.textColor=[UIColor lightGrayColor];
    [totalView addSubview:labSecond];
    [labSecond mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).offset(padding);
        make.bottom.equalTo(imgView);
    }];
    //分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(240, 240, 240);
    [totalView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(totalView).offset(padding);
        make.right.equalTo(totalView).offset(-padding);
        make.bottom.equalTo(totalView);
        make.height.mas_equalTo(1);
    }];
    
    //建构标志
    UIImageView *rigImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-right"]];
    [totalView addSubview:rigImgView];
    [rigImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(totalView);
        make.right.equalTo(totalView).offset(-padding);
        
    }];

    return totalView;
}

-(void)zhuanClick
{
    SunSearchServerViewController *se=[[SunSearchServerViewController alloc]init];
    se.title=@"专项查找";
    se.SearchType=@"专项";
    [self.navigationController pushViewController:se animated:YES];
}

-(void)dingClick
{
    SunSearchServerViewController *se=[[SunSearchServerViewController alloc]init];
    se.title=@"定制查找";
    se.SearchType=@"定制";
    [self.navigationController pushViewController:se animated:YES];
}
@end
