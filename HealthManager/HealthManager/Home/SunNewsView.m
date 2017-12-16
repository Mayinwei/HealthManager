//
//  SunNewsView.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/11.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunNewsView.h"

@implementation SunNewsView

+(instancetype)sunNewsWithImage:(NSString *)imgName firseTitle:(NSString *)firseTitle secondTitle:(NSString *)secondTitle
{
    UIView *view=[[UIView alloc] init];
    view.frame=CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 60);
    //添加图片
    UIImageView *leftImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
    [view addSubview:leftImage];
    CGFloat padding=10;
    [leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_centerY);
        make.left.equalTo(view).offset(padding);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    //添加文字
    UILabel *firseLab=[[UILabel alloc] init];
    firseLab.text=firseTitle;
    [view addSubview:firseLab];
    firseLab.textColor=MrColor(51, 51, 51);
    CGFloat windowW=[UIScreen mainScreen].bounds.size.width;
    CGFloat temp=windowW-padding*2;
    [firseLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftImage.mas_right).offset(padding+3);
        make.height.equalTo(view.mas_height).multipliedBy(0.5);
        make.width.equalTo(view).offset(temp);
        make.top.equalTo(view);
    }];
    //副标题
    UILabel *secondLab=[[UILabel alloc] init];
    secondLab.text=secondTitle;
    secondLab.font=[UIFont systemFontOfSize:14];
    secondLab.textColor=MrColor(153, 153, 153);
    [view addSubview:secondLab];
    [secondLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(firseLab.mas_centerX);
        make.width.equalTo(firseLab);
        make.height.equalTo(firseLab).offset(-1);
        make.top.equalTo(firseLab.mas_bottom);
    }];
    //添加右侧箭头
    UIImageView *rightImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-right"]];
    [view addSubview:rightImage];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_centerY);
        make.right.equalTo(view).offset(-padding*2);
        make.width.mas_equalTo(23);
        make.height.mas_equalTo(23);
    }];
    
    //添加一个分割线
    UIView *cutView=[[UIView alloc] init];
    cutView.backgroundColor=MrColor(225, 225, 225);
    [view addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(firseLab.mas_centerX);
        make.width.equalTo(secondLab.mas_width);
        make.height.mas_equalTo(1);
        make.top.equalTo(secondLab.mas_bottom);
    }];

return view;
    
}

@end
