//
//  SunDocHomeViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/23.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunDocHomeViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJRefresh.h"




@interface SunDocHomeViewController ()
@property(nonatomic,weak)UIScrollView *contetnScrollView;
//总人数
@property(nonatomic,weak)UILabel *labAllPeo;
@property(nonatomic,weak)UILabel *labManPeo;
@property(nonatomic,weak)UILabel *labWomanPeo;

//告警人数
@property(nonatomic,weak)UILabel *labWaringRate;
@property(nonatomic,weak)UILabel *labWaringPeo;
@property(nonatomic,weak)UILabel *labZiPeo;
//统计
@property(nonatomic,weak)UIView *myNewView;
@property(nonatomic,weak)UILabel *labHeight;
@property(nonatomic,weak)UILabel *labMiddle;
@property(nonatomic,weak)UILabel *labLow;
@property(nonatomic,weak)UILabel *labNew;
@property(nonatomic,weak)MJRefreshNormalHeader *header;

//最后一个播放声音时间
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

//整体布局左右间距
#define Padding 8
@implementation SunDocHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.title=@"总览";
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIScrollView *contetnScrollView=[[UIScrollView alloc]init];
    self.contetnScrollView=contetnScrollView;
    //contetnScrollView.backgroundColor=[UIColor whiteColor];
    contetnScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:contetnScrollView];
    contetnScrollView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-49-64);
    //添加界面
    [self setUpTop];
    
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    self.contetnScrollView.mj_header=header;
    //加载数据
    [self loadData];
}





-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
}
-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetUserCount*%@",login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        self.labAllPeo.text=[json[@"AllCount"] copy];
        self.labManPeo.text=[json[@"ManCount"] copy];
        self.labWomanPeo.text=[json[@"WomanCount"] copy];
        self.labWaringRate.text=[json[@"WarnRate"] copy];
        self.labWaringPeo.text=[json[@"WarnCount"] copy];
        self.labZiPeo.text=[json[@"AdviceCount"] copy];
        //高中低
        self.labHeight.text=[json[@"HighRiskCount"] copy];
        self.labLow.text=[json[@"LowRiskCount"] copy];
        self.labMiddle.text=[json[@"MediumRiskCount"] copy];
        self.labNew.text=[json[@"AddCount"] copy];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];

}
//顶部布局
-(void)setUpTop
{
    CGFloat labTopFontSize=13;
    UILabel *lab1=[[UILabel alloc]init];
    lab1.textColor=[UIColor lightGrayColor];
    lab1.text=@"总人数:";
    lab1.font=kFont(labTopFontSize);
    [self.contetnScrollView addSubview:lab1];
    [lab1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contetnScrollView).offset(Padding);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
    }];
    UILabel *labZong=[[UILabel alloc]init];
    self.labAllPeo=labZong;
    labZong.textColor=[UIColor blackColor];
    labZong.text=@"";
    labZong.textColor=MrColor(106, 201, 246);
    labZong.font=kFont(labTopFontSize+3);
    [self.contetnScrollView addSubview:labZong];
    [labZong mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lab1);
        make.left.equalTo(lab1.mas_right).offset(2);
    }];
    //男
    UILabel *lab2=[[UILabel alloc]init];
    lab2.textColor=[UIColor lightGrayColor];
    lab2.text=@"其中 男:";
    lab2.font=kFont(labTopFontSize);
    [self.contetnScrollView addSubview:lab2];
    [lab2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contetnScrollView).offset(Padding);
        make.left.equalTo(labZong.mas_right).offset(20);
    }];
    UILabel *labNan=[[UILabel alloc]init];
    labNan.textColor=[UIColor blackColor];
    labNan.text=@"";
    self.labManPeo=labNan;
    labNan.textColor=labZong.textColor;
    labNan.font=kFont(labTopFontSize+3);
    [self.contetnScrollView addSubview:labNan];
    [labNan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lab2);
        make.left.equalTo(lab2.mas_right).offset(2);
    }];
    
    //女
    UILabel *lab3=[[UILabel alloc]init];
    lab3.textColor=[UIColor lightGrayColor];
    lab3.text=@"女:";
    lab3.font=kFont(labTopFontSize);
    [self.contetnScrollView addSubview:lab3];
    [lab3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contetnScrollView).offset(Padding);
        make.left.equalTo(labNan.mas_right).offset(10);
    }];
    UILabel *labNv=[[UILabel alloc]init];
    labNv.textColor=[UIColor blackColor];
    labNv.text=@"";
    self.labWomanPeo=labNv;
    labNv.textColor=labZong.textColor;
    labNv.font=kFont(labTopFontSize+3);
    [self.contetnScrollView addSubview:labNv];
    [labNv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(lab3);
        make.left.equalTo(lab3.mas_right).offset(2);
    }];
    
    //告警率
    UIImageView *warningImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chart_bg05"]];
    warningImgView.layer.cornerRadius=10;
    warningImgView.layer.masksToBounds=YES;
    warningImgView.userInteractionEnabled=YES;
    [self.contetnScrollView addSubview:warningImgView];
    [warningImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab1.mas_bottom).offset(10);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.equalTo(self.contetnScrollView).offset(-Padding*2);
        make.height.mas_equalTo(170);
    }];
    
    UILabel *labWTi=[[UILabel alloc]init];
    labWTi.textColor=[UIColor whiteColor];
    labWTi.text=@"告警率";
    labWTi.font=kFont(25);
    [warningImgView addSubview:labWTi];
    [labWTi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(warningImgView).offset(40);
        make.left.equalTo(warningImgView).offset(35);
    }];
    UILabel *labWarning=[[UILabel alloc]init];
    labWarning.textColor=[UIColor whiteColor];
    labWarning.text=@"";
    self.labWaringRate=labWarning;
    labWarning.font=kFont(50);
    [warningImgView addSubview:labWarning];
    [labWarning mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labWTi.mas_bottom).offset(10);
        make.centerX.equalTo(labWTi).offset(-8);
    }];
    
    UILabel *labWarningUnit=[[UILabel alloc]init];
    labWarningUnit.textColor=[UIColor whiteColor];
    labWarningUnit.text=@"%";
    labWarningUnit.font=kFont(20);
    [warningImgView addSubview:labWarningUnit];
    [labWarningUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labWarning.mas_right);
        make.bottom.equalTo(labWarning).offset(-8);
    }];
    
    //右侧模块
    CGFloat toPadding=10;
    UIView *viewPeo=[self getModelWithTitle:@"告警人数"];
    UIView *viewZi=[self getModelWithTitle:@"咨询人数"];
    [warningImgView addSubview:viewPeo];
    [warningImgView addSubview:viewZi];
    
    self.labWaringPeo=viewPeo.subviews[1];
    self.labZiPeo=viewZi.subviews[1];
    self.labWaringPeo.textColor=MrColor(106, 201, 246);
    self.labZiPeo.textColor=[UIColor lightGrayColor];
    self.labWaringPeo.userInteractionEnabled=YES;
    UITapGestureRecognizer *wTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(warningClick)];
    [self.labWaringPeo addGestureRecognizer:wTap];
    
    [@[viewPeo,viewZi] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:toPadding leadSpacing:toPadding tailSpacing:toPadding];
    
    
    [@[viewPeo,viewZi] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(160);
        make.right.equalTo(warningImgView).offset(-14);
    }];
    
    
    //风险等级
    UILabel *labMidTitle=[[UILabel alloc]init];
    labMidTitle.text=@"风险等级统计";
    labMidTitle.textColor=[UIColor lightGrayColor];
    labMidTitle.font=kFont(17);
    [self.contetnScrollView addSubview:labMidTitle];
    [labMidTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.top.equalTo(warningImgView.mas_bottom).offset(Padding*1.5);
    }];
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [self.contetnScrollView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labMidTitle.mas_bottom).offset(10);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(1);
    }];
    
    //高压
    UIView *heightView=[self getHeiWithImgName:@"height_icon" clickPrm:1];
    self.labHeight=heightView.subviews[1];
    self.labHeight.textColor=MrColor(243, 42, 27);
    [self.contetnScrollView addSubview:heightView];
    [heightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutView.mas_bottom).offset(5);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(35);
    }];
    //中压
    UIView *middleView=[self getHeiWithImgName:@"middle_icon"  clickPrm:2];
    self.labMiddle=middleView.subviews[1];
    self.labMiddle.textColor=MrColor(245, 168, 40);
    [self.contetnScrollView addSubview:middleView];
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(heightView.mas_bottom);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(35);
    }];
    //低压
    UIView *lowView=[self getHeiWithImgName:@"low_icon" clickPrm:3];
    self.labLow=lowView.subviews[1];
    self.labLow.textColor=MrColor(40, 245, 50);
    
    [self.contetnScrollView addSubview:lowView];
    [lowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(middleView.mas_bottom);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(35);
    }];
    
    
    //本月最新统计
    UILabel *labTong=[[UILabel alloc]init];
    labTong.text=@"本月新增统计";
    labTong.textColor=[UIColor lightGrayColor];
    labTong.font=labMidTitle.font;
    [self.contetnScrollView addSubview:labTong];
    [labTong mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.top.equalTo(lowView.mas_bottom).offset(Padding*1.5);
    }];
    UIView *cutTView=[[UIView alloc]init];
    cutTView.backgroundColor=MrColor(230, 230, 230);
    [self.contetnScrollView addSubview:cutTView];
    [cutTView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labTong.mas_bottom).offset(10);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(1);
    }];
    //
    UIView *newView=[self getHeiWithImgName:@"new_icon" clickPrm:4];
    self.myNewView=newView;
    self.labNew=newView.subviews[1];
    self.labNew.textColor=MrColor(19, 115, 243);
    [self.contetnScrollView addSubview:newView];
    [newView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutTView.mas_bottom).offset(5);
        make.left.equalTo(self.contetnScrollView).offset(Padding);
        make.width.mas_equalTo(SCREEN_WIDTH-Padding*2);
        make.height.mas_equalTo(35);
    }];
    [self.view layoutIfNeeded];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat y=CGRectGetMaxY(self.myNewView.frame);
    self.contetnScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, y);
}
//告警率模块
-(UIView *)getModelWithTitle:(NSString *)title
{
    UIView *allView=[[UIView alloc]init];
    allView.layer.cornerRadius=10;
    allView.backgroundColor=[UIColor whiteColor];
    allView.alpha=0.8;
    
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=title;
    labTitle.font=kFont(13);
    [allView addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(allView).offset(Padding);
        make.right.equalTo(allView).offset(-Padding);
    }];
    //数字
    UILabel *labNum=[[UILabel alloc]init];
    labNum.text=@"";
    labNum.font=kFont(38);
    [allView addSubview:labNum];
    [labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(allView);
        make.right.equalTo(labTitle.mas_left).offset(-6);
    }];
    
    
    return allView;
}

//高中低统计
-(UIView *)getHeiWithImgName:(NSString *)name clickPrm:(NSInteger)par
{
    UIView *contentView=[[UIView alloc]init];
    //图片
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:name]];
    [contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(5);
        make.bottom.equalTo(contentView).offset(-5);
        make.left.equalTo(contentView);
        make.width.equalTo(imgView.mas_height);
    }];
    //人数
    UILabel *labNum=[[UILabel alloc]init];
    labNum.text=@"";
    labNum.font=kFont(15);
    [contentView addSubview:labNum];
    [labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.centerX.equalTo(contentView).offset(-4);
    }];
    UILabel *labUnit=[[UILabel alloc]init];
    labUnit.text=@"人";
    labUnit.font=labNum.font;
    labUnit.textColor=[UIColor lightGrayColor];
    [contentView addSubview:labUnit];
    [labUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.left.equalTo(labNum.mas_right).offset(3);
    }];
    
    UIImageView *rigImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-right"]];
    [contentView addSubview:rigImgView];
    [rigImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(contentView);
        make.right.equalTo(contentView);
    }];
    
    //详情
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpTo:)];
    UILabel *labxiang=[[UILabel alloc]init];
    labxiang.tag=par;
    [labxiang addGestureRecognizer:tap];
    labxiang.userInteractionEnabled=YES;
    labxiang.text=@"详情";
    labxiang.font=labNum.font;
    labxiang.textColor=MrColor(22, 130, 251);
    [contentView addSubview:labxiang];
    [labxiang mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rigImgView.mas_left).offset(-5);
        make.centerY.equalTo(contentView);
    }];
    
    //分隔线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [contentView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView);
        make.width.equalTo(contentView);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
    }];
    
    return contentView;
}


-(void)jumpTo:(UITapGestureRecognizer *)tap
{
    NSString *val=@"";
    UILabel *lab=(UILabel *)tap.view;
    if (lab.tag==1) {
        val=@"HighRisk";
    }else if (lab.tag==2) {
        val=@"MediumRisk";
    }else if (lab.tag==3) {
        val=@"LowRisK";
    }else if (lab.tag==4) {
        val=@"Add";
    }
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:val forKey:@"SearchType"];
    self.tabBarController.selectedIndex=1;
}

-(void)warningClick
{
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    [userDefault setObject:@"Warn" forKey:@"SearchType"];
    self.tabBarController.selectedIndex=1;
}





@end
