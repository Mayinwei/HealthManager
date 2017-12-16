//
//  SunDocInfoViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 20 7年 马银伟. All rights reserved.
// 医生详细信息

#import "SunDocInfoViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunSearchDocModel.h"
#import "UIImageView+WebCache.h"
#import "SunMyServerModel.h"
#import "SunServerDetailViewController.h"

@interface SunDocInfoViewController ()
@property(nonatomic,strong)UIImageView *headImgView;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labShan;
@property(nonatomic,strong)UILabel *labzhi;
@property(nonatomic,strong)UILabel *labAd;
@property(nonatomic,strong)UIImageView *flagView;
@property(nonatomic,strong)UIScrollView *contentScrollView;
@property(nonatomic,strong)UIView *middleView;
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UILabel *labJian;

@property(nonatomic,strong)NSMutableArray *arrayData;
@end

@implementation SunDocInfoViewController
-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"医生详细信息";
    self.view.backgroundColor=MrColor(240, 240, 240);
    
    [self setUpMain];
    //医生服务
    [self setUpMiddle];
    //个人简介
    [self setUpBottom];

    //头像
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,self.searchDoc.HEADPIC]] ;
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
    [self.flagView setImage:[UIImage imageNamed:@"doc_flag"]];
    //姓名
    self.labName.text=self.searchDoc.USERNAME;
    self.labzhi.text=self.searchDoc.POST;
    if (![self.searchDoc.HOSNAME isEqualToString:@""]&&![self.searchDoc.DEPT isEqualToString:@""]) {
        self.labAd.text=[NSString stringWithFormat:@"%@/%@",self.searchDoc.HOSNAME,self.searchDoc.DEPT];
    }
    //简介
    self.labJian.text=self.searchDoc.PROFILE;
    
    //加载服务
    [self loadDocSer];
}

-(void)setUpMain
{
    //添加滚动框架
    UIScrollView *contentScrollView=[[UIScrollView alloc]init];
    contentScrollView.backgroundColor=MrColor(240, 240, 240);
    self.contentScrollView=contentScrollView;
    [self.view addSubview:contentScrollView];
    contentScrollView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    contentScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, 800);
    contentScrollView.pagingEnabled=NO;
    
    UIView *topView=[[UIView alloc]init];
    topView.backgroundColor=MrColor(40, 100, 132);
    [contentScrollView addSubview:topView];
    topView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 100);
    //头像
    CGFloat padding=12;
    UIImageView *imgView=[[UIImageView alloc]init];
    self.headImgView=imgView;
    [topView addSubview:imgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(padding);
        make.bottom.equalTo(topView).offset(-padding);
        make.left.equalTo(topView).offset(padding+5);
        make.width.equalTo(imgView.mas_height);
    }];
    
    //姓名
    UILabel *labName=[[UILabel alloc]init];
    labName.textColor=[UIColor whiteColor];
    self.labName=labName;
    [topView addSubview:labName];
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView);
        make.left.equalTo(imgView.mas_right).offset(padding);
    }];
    //医生标志
    UIImageView *flagView=[[UIImageView alloc]init];
    [topView addSubview:flagView];
    [flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName.mas_right).offset(3);
        make.top.equalTo(self.labName);
        make.bottom.equalTo(self.labName);
        make.width.mas_equalTo(37);
    }];
    
    //职务
    UILabel *labzhi=[[UILabel alloc]init];
    self.labzhi=labzhi;
    labzhi.font=kFont(14);
    labzhi.textColor=[UIColor lightGrayColor];
    [topView addSubview:labzhi];
    //职务
    [self.labzhi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(topView);
        make.left.equalTo(self.labName);
    }];
    //医院科室
    UILabel *labAd=[[UILabel alloc]init];
    labAd.font=kFont(14);
    labAd.textColor=[UIColor lightGrayColor];
    self.labAd=labAd;
    [topView addSubview:labAd];
    [self.labAd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImgView);
        make.left.equalTo(self.labName);
    }];
}

//医生服务
-(void)setUpMiddle{
    UIView *middleView=[[UIView alloc]init];
    self.middleView=middleView;
    middleView.backgroundColor=[UIColor whiteColor];
    [self.contentScrollView addSubview:middleView];
    middleView.frame=CGRectMake(0, 110, SCREEN_WIDTH, 60);
    
    //标题
    UILabel *midTitle=[[UILabel alloc]init];
    midTitle.text=@"健康管理服务";
    midTitle.textColor=MrColor(40, 100, 132);
    midTitle.font=kFont(15);
    [middleView addSubview:midTitle];
    [midTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(middleView).offset(12);
        make.top.equalTo(middleView).offset(12);
    }];
    //分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(220, 220, 220);
    [middleView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(midTitle);
        make.right.equalTo(midTitle);
        make.top.equalTo(midTitle.mas_bottom).offset(8);
        make.height.mas_equalTo(1);
    }];
}

//个人简介
-(void)setUpBottom
{
    UIView *bottomView=[[UIView alloc]init];
    self.bottomView=bottomView;
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.contentScrollView addSubview:bottomView];
    
    
    //标题
    UILabel *botTitle=[[UILabel alloc]init];
    botTitle.text=@"个人简介";
    botTitle.textColor=MrColor(40, 100, 132);
    botTitle.font=kFont(15);
    [bottomView addSubview:botTitle];
    [botTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(12);
        make.top.equalTo(bottomView).offset(12);
    }];
    //分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(220, 220, 220);
    [bottomView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(botTitle);
        make.right.equalTo(botTitle);
        make.top.equalTo(botTitle.mas_bottom).offset(8);
        make.height.mas_equalTo(1);
    }];
    //简介内容
    UILabel *labJian=[[UILabel alloc]init];
    self.labJian=labJian;
    labJian.font=kFont(15);
    labJian.numberOfLines=0;
    [bottomView addSubview:labJian];
    [labJian mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(12);
        make.right.equalTo(bottomView).offset(-12);
        make.top.equalTo(cutView.mas_bottom).offset(5);
    }];
    
    
}


//加载医生服务
-(void)loadDocSer
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetDocNoHave*%@*%@",self.searchDoc.DOCCODE,login.usercode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        self.arrayData=[SunMyServerModel mj_objectArrayWithKeyValuesArray:json];
        for (int i=0; i<self.arrayData.count; i++) {
            SunMyServerModel *ser=self.arrayData[i];
            UIView *serView=[self getViewWithName:[NSString stringWithFormat:@"%d. %@",i+1,ser.SVRNAME]];
            serView.subviews[1].tag=i;
            [self.middleView addSubview:serView];
            CGFloat my=36;
            CGFloat mh=38;
            serView.frame=CGRectMake(0, i*mh+my, SCREEN_WIDTH, mh);
        }
        
        //刷新界面
        [self.contentScrollView layoutIfNeeded];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //更新中间
    if(self.middleView.subviews.count>2){
    UIView *lastView=(UIView *)[self.middleView.subviews lastObject];
    CGFloat lastY=CGRectGetMaxY(lastView.frame);
    self.middleView.frame=CGRectMake(0, 110, SCREEN_WIDTH, lastY);
    }
    //更新底部
    CGFloat bottomY=CGRectGetMaxY(self.middleView.frame);
    CGFloat jianMaxY=CGRectGetMaxY(self.labJian.frame);
    self.bottomView.frame=CGRectMake(0, bottomY+10, SCREEN_WIDTH, jianMaxY);
    CGFloat botMaxY=CGRectGetMaxY(self.bottomView.frame);
    //更新滚动试图
    self.contentScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, botMaxY+10);
    
}

-(UIView *)getViewWithName:(NSString *)name
{
    UIView *serView=[[UIView alloc]init];
    
    UILabel *lab=[[UILabel alloc]init];
    lab.text=name;
    lab.font=kFont(15);
    [serView addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(serView);
        make.left.equalTo(serView).offset(12);
    }];
    
    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-right"]];
    [serView addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(serView);
        make.right.equalTo(serView).offset(-10);
    }];
    img.userInteractionEnabled=YES;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookSer:)];
    [img addGestureRecognizer:tap];
    return serView;
}

-(void)lookSer:(UITapGestureRecognizer *)tap
{
   int index=(int)tap.view.tag;
    SunMyServerModel *myServer=self.arrayData[index];
    SunServerDetailViewController *sd=[[SunServerDetailViewController alloc]init];
    sd.serModel=myServer;
    [self.navigationController pushViewController:sd animated:YES];
}


@end
