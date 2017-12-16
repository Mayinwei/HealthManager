//
//  SunDataSugarView.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/20.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunDataSugarView.h"
#define FontSize 22
#define FontSmallSize 14
@interface SunDataSugarView()
@property(nonatomic,strong)UIView *topCutView;
@property(nonatomic,strong)UIView *bottomCutView;
@end

@implementation SunDataSugarView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //顶部分割线
        UIView *topCutView=[[UIView alloc]init];
        topCutView.backgroundColor=MrColor(224, 224, 224);
        self.topCutView=topCutView;
        [self addSubview:topCutView];
        //底部分割线
        UIView *bottomCutView=[[UIView alloc]init];
        bottomCutView.backgroundColor=MrColor(224, 224, 224);
        self.bottomCutView=bottomCutView;
        [self addSubview:bottomCutView];
        //标题
        UILabel *labTitle=[[UILabel alloc]init];
        self.labTitle=labTitle;
        [self addSubview:labTitle];
        labTitle.font=kFont(15);
        labTitle.text=@"血糖";
        //图片
        UIImageView *imgView=[[UIImageView alloc]init];
        self.imgView=imgView;
        [self addSubview:self.imgView];
        //血糖值
        UILabel *higLab=[[UILabel alloc]init];
        self.higLab=higLab;
        higLab.font=kFont(FontSize);
        higLab.textColor=MrColor(33, 125, 244);
        [self addSubview:higLab];
        
        //单位
        UILabel *higUnit=[[UILabel alloc]init];
        self.higUnit=higUnit;
        higUnit.font=kFont(FontSmallSize);
        higUnit.textColor=MrColor(164, 164, 164);
        higUnit.text=@"mmol/L";
        [self addSubview:higUnit];
        //时间段
        UILabel *sTimeLab=[[UILabel alloc]init];
        sTimeLab.font=kFont(20);
        sTimeLab.textColor=MrColor(164, 164, 164);
        self.sTimeLab=sTimeLab;
        [self addSubview:sTimeLab];
        //时间
        UILabel *timeLab=[[UILabel alloc]init];
        timeLab.font=kFont(FontSmallSize);
        timeLab.textColor=MrColor(164, 164, 164);
        self.timeLab=timeLab;
        [self addSubview:timeLab];
        //声音
       UIButton *soundButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.soundButton=soundButton;
        [soundButton addTarget:self action:@selector(paySound) forControlEvents:UIControlEventTouchUpInside];
        [soundButton setBackgroundImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
        [soundButton setBackgroundImage:[UIImage imageNamed:@"speaker-hightlight"] forState:UIControlStateHighlighted];
        [self addSubview:soundButton];
    }
    return self;
}
-(void)paySound
{
    if ([self.delegate respondsToSelector:@selector(sugarViewPlaySound:)]) {
        [self.delegate sugarViewPlaySound:self];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //动态添加宽度自适应约束
    for (NSObject *obj in self.subviews) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *lable=(UILabel *)obj;
            [lable setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            
            //设置label1的content compression 为1000
            [lable setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            
        }
    }
    CGFloat padding=0;
    if(SCREEN_WIDTH==320)
    {
        padding=3;
    }else
    {
        padding=10;
    }
    
    [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(padding);
        make.height.equalTo(self.mas_height);
    }];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labTitle.mas_right).offset(padding);
        make.top.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-5);
        make.width.equalTo(self.imgView.mas_height);
    }];
    //血糖值
    [self.higLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.5);
        make.left.equalTo(self.imgView.mas_right).offset(padding);
    }];
    //时间
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.higLab.mas_bottom);
        make.height.equalTo(self).multipliedBy(0.5);
        make.left.equalTo(self.higLab);
    }];
    //单位
    [self.higUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self.timeLab);
        make.height.equalTo(self.higLab);
    }];
    
    //时间段
    [self.sTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.higUnit.mas_right).offset(padding);
        make.height.equalTo(self);
        make.top.equalTo(self);
    }];
    //声音
    [self.soundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(25);
        make.centerY.equalTo(self);
        make.width.equalTo(self.soundButton.mas_height);
        make.right.equalTo(self).offset(-padding-5);
    }];
    //添加分割线
    [self.topCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.height.mas_equalTo(1);
        make.width.equalTo(self);
    }];
    
    
    [self.bottomCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.height.equalTo(self.topCutView);
        make.width.equalTo(self);
    }];
}


@end
