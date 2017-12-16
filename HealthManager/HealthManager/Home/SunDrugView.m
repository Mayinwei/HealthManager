//
//  SunDrugView.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/14.
//  Copyright © 2016年 马银伟. All rights reserved.
//  用药信息

#import "SunDrugView.h"



@implementation SunDrugView

//字体
#define FontSize 15
- (instancetype)init
{
    self = [super init];
    if (self) {
        //添加控件
        //背景图
        UIImageView *bagImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"drug_background"]];
        self.bagImgView=bagImgView;
        [self addSubview:bagImgView];
        //药名字
        UILabel *name=[[UILabel alloc]init];
        self.name=name;
        name.font=kFont(FontSize);
        [self addSubview:name];
        //计量
        UILabel *num=[[UILabel alloc]init];
        self.num=num;
        num.font=kFont(FontSize);
        [self addSubview:num];
        //方式
        UILabel *ways=[[UILabel alloc]init];
         ways.font=kFont(FontSize);
        self.ways=ways;
        [self addSubview:ways];
        //时间
        UILabel *timeName=[[UILabel alloc]init];
        timeName.font=kFont(FontSize);
        timeName.text=@"时间:";
        [self addSubview:timeName];
        self.timeName=timeName;
        UILabel *time=[[UILabel alloc]init];
        time.font=kFont(FontSize);
        self.time=time;
        [self addSubview:time];
        
        //按钮
        UIButton *fuBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        self.fuBtn=fuBtn;
        [fuBtn addTarget:self action:@selector(fuBtnClick) forControlEvents:UIControlEventTouchUpInside];
        fuBtn.titleLabel.font=kFont(FontSize);
        [fuBtn setBackgroundImage:[UIImage imageNamed:@"drug_btn_background"] forState:UIControlStateNormal];
        [fuBtn setTitle:@"已服" forState:UIControlStateNormal];
        [self addSubview:fuBtn];
        
        UIButton *againBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [againBtn setBackgroundImage:[UIImage imageNamed:@"drug_btn_background"] forState:UIControlStateNormal];
        self.againBtn=againBtn;
        [againBtn addTarget:self action:@selector(againBtnClick) forControlEvents:UIControlEventTouchUpInside];
        againBtn.titleLabel.font=kFont(FontSize);
        [againBtn setTitle:@"再提醒" forState:UIControlStateNormal];
        [self addSubview:againBtn];
        
        //遍历子元素，找出UILable更改字颜色
        for (UIView *obj in self.subviews) {
            if ([obj isKindOfClass:[UILabel class]]) {
                UILabel *lab=(UILabel *)obj;
                lab.textColor=[UIColor whiteColor];
            }
        }
        
    }
    return self;
}

-(void)againBtnClick
{
    if ([self.delegate respondsToSelector:@selector(sunDrugViewAgain:)]) {
        [self.delegate sunDrugViewAgain:self];
    }
}
-(void)fuBtnClick
{
    if ([self.delegate respondsToSelector:@selector(sunDrugViewFu:)]) {
        [self.delegate sunDrugViewFu:self];
    }
}


//设置位置
-(void)layoutSubviews
{
    if(SCREEN_WIDTH>320)
    {
        //i5+
        [self setUpSmailScr];
    }else
    {
        //i5
        [self setUpSmailScr];
    }
}


-(void)setUpBigScr
{
    CGFloat padding=10;
    //图片
    [self.bagImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.size.equalTo(self);
    }];
    //名称
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.left.equalTo(self).offset(padding);
    }];
    //    [self.name setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //    [self.name setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //计量
    [self.num mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.left.equalTo(self.name.mas_right).offset(padding*2);
        make.height.equalTo(self.name);
    }];
    //    [self.num setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //    [self.num setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //方式
    [self.ways mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.left.equalTo(self.num.mas_right).offset(padding*2);
        make.height.equalTo(self.name);
    }];
    [self.ways setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.ways setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //时间
    [self.timeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-padding);
        make.left.equalTo(self).offset(padding);
        make.height.equalTo(self.name);
    }];
    [self.timeName setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeName setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-padding);
        make.left.equalTo(self.timeName.mas_right).offset(3);
        make.height.equalTo(self.name);
    }];
    [self.time setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.time setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //按钮
    [self.fuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.bottom.equalTo(self.againBtn.mas_top).offset(-padding);
        make.width.mas_equalTo(60);
    }];
    
    [self.againBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fuBtn.mas_bottom).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.bottom.equalTo(self).offset(-padding);
        make.size.equalTo(self.fuBtn);
    }];

}

-(void)setUpSmailScr
{
    CGFloat padding=10;
    //图片
    [self.bagImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.size.equalTo(self);
    }];
    //名称
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.left.equalTo(self).offset(padding);
        make.right.equalTo(self.fuBtn.mas_left).offset(-padding);
    }];
    
    //计量
    [self.num mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.name);
        make.height.equalTo(self.name);
    }];
    
    
    //方式
    [self.ways mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.num);
        make.left.equalTo(self.num.mas_right).offset(padding*2);
        
    }];
    [self.ways setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.ways setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //时间
    [self.timeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(-padding);
        make.left.equalTo(self).offset(padding);
        make.height.equalTo(self.name);
    }];
    [self.timeName setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeName setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-padding);
        make.left.equalTo(self.timeName.mas_right).offset(3);
        make.height.equalTo(self.name);
    }];
    [self.time setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.time setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //按钮
    [self.fuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.bottom.equalTo(self.againBtn.mas_top).offset(-padding);
        make.width.mas_equalTo(60);
    }];
    
    [self.againBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fuBtn.mas_bottom).offset(padding);
        make.right.equalTo(self).offset(-padding);
        make.bottom.equalTo(self).offset(-padding);
        make.size.equalTo(self.fuBtn);
    }];
    
}


@end
