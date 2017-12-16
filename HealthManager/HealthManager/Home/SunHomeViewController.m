//
//  SunHomeViewController.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  首页答复

#import "SunHomeViewController.h"
#import "SunNewsViewController.h"
#import "SunNavigationController.h"
#import "SunAttentionView.h"
#import "SunDrugView.h"
#import "HealthKitManage.h"
#import "MJRefresh.h"
#import "SunDrugModel.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "Chameleon.h"
#import "SXScrPageView.h"
#import "SunWarningModel.h"
#import "SunDrugViewController.h"
#import "SunDeviceTableViewController.h"
#import "SunQRViewController.h"
#import "SunDeviceBindiewController.h"
#import "SunSuggestTableViewController.h"
#import "CCWebViewController.h"
#import "SunNoFoundViewController.h"
#import "SunAddAttentionViewController.h"
#import "SunAttentionRequestTableViewController.h"
#import "SunMyServerTableViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "WZLBadgeImport.h"
//模块之间的间距
#define ModelTopPadding 5
#define CutViewHeight 1
@interface SunHomeViewController ()<UIScrollViewDelegate,SunDrugViewDelegate>
@property(nonatomic,weak)UIView *bgView;
@property(nonatomic,weak)UIScrollView *contentScrollView;
//健康View
@property(nonatomic,weak)UIView *healthView;
//关注
@property(nonatomic,weak)UIView *attentoinView;
//模块
@property(nonatomic,weak)UIView *modelView;
//用药
@property(nonatomic,weak)UIView *drugView;
//步数
@property(nonatomic,weak)UILabel *shoesLab;
//卡路里
@property(nonatomic,weak)UILabel *kaLab;
//下拉刷新控件
@property(nonatomic,weak)MJRefreshNormalHeader *header;
@property(nonatomic,strong)NSArray *arrayData;
//顶部轮播
@property(nonatomic,weak)UIView *dataView;

@property(nonatomic,strong)UIView *bloodView;
@property(nonatomic,strong)UIView *sugarView;
@property(nonatomic,weak)UIButton *btnRight;
@property(nonatomic,weak)UILabel *labNoDrug;
//网络连接
@property(nonatomic,strong)AFHTTPSessionManager *manager;
@end

@implementation SunHomeViewController
//懒加载
-(NSArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSArray array];
    }
    return _arrayData;
}

-(AFHTTPSessionManager *)manager
{
    if (_manager==nil) {
        _manager=[AFHTTPSessionManager manager];
    }
    return _manager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    //主框架内容
    [self setUpMain];
    
    //填充内容
    [self setUpContain];
    
    //添加模块布局
    [self addModel];
    //用药布局
    [self setUpDrug];
    
    //注册通知用于接收扫码传递
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanFun:) name:@"SunHomeViewController" object:nil];
    //用于接收系统3D touch的点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScan:) name:@"myHomeTouch" object:nil];
}

-(void)showScan:(NSNotification *)not
{
    NSString *touchType= not.userInfo[@"type"];
    
     if([touchType isEqualToString:@"扫一扫"]){
         [self sao];
     }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //设置导航栏下面黑线隐藏
    UIImageView *navBarHairlineImageView= [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden=YES;
    
    //添加一个带有颜色的view
    if(self.bgView!=nil)
    {
        [self.bgView removeFromSuperview];
    }
    UIView *bgView=[[UIView alloc]init];
    
    bgView.alpha=0;
    //旧颜色
    //bgView.backgroundColor=MrColor(0, 228, 248);
    bgView.backgroundColor=MrColor(33, 135, 244);
    bgView.frame=CGRectMake(0,-20,SCREEN_WIDTH, self.navigationController.navigationBar.frame.size.height+20);
    [self.navigationController.navigationBar insertSubview:bgView atIndex:0];
    bgView.userInteractionEnabled=NO;
    self.bgView=bgView;
    
    
    
    //获取聊天记录未读数
    NSInteger unRead=[self setupUnreadMessageCount];
    if(unRead>0){
        self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%ld",(long)unRead];
    }else{
        self.tabBarItem.badgeValue=nil;
        
    }
    [self setUpLun];
    
    
    
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat maxDrugViewY=CGRectGetMaxY(self.drugView.frame);
    self.contentScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, maxDrugViewY+10);
}

//通知事件
-(void)scanFun:(NSNotification *)not
{
    if([not.userInfo[@"Info"] isEqualToString:@"SunSuggestTableViewController"])
    {        
        SunSuggestTableViewController *bind=[[SunSuggestTableViewController alloc]init];
        [self.navigationController pushViewController:bind animated:YES];
    }else if([not.userInfo[@"Info"] isEqualToString:@"SunAttentionRequestTableViewController"])
    {
        [self.navigationController pushViewController:[[SunAttentionRequestTableViewController alloc]init] animated:YES];
        
    }else if([not.userInfo[@"Info"] rangeOfString:@"SunUrl"].location !=NSNotFound)
    {
        NSString *url=[not.userInfo[@"Info"] componentsSeparatedByString:@"*"][1];
        //扫描的是网址
        [CCWebViewController showWithContro:self withUrlStr:url withTitle:@""];
    
    }else if([not.userInfo[@"Info"] rangeOfString:@"NoFound"].location !=NSNotFound)
    {
        //可能是血糖仪
//        NSString *str=[not.userInfo[@"Info"] componentsSeparatedByString:@"*"][1];
//        SunNoFoundViewController *not=[[SunNoFoundViewController alloc]init];
//        not.result=str;
//        [self.navigationController pushViewController:not animated:YES];
        NSString *SugarDev=[not.userInfo[@"Info"] componentsSeparatedByString:@"*"][1];
        SunDeviceBindiewController *bind=[[SunDeviceBindiewController alloc]init];
        bind.EquCode=SugarDev;
        [self.navigationController pushViewController:bind animated:YES];
    }else if([not.userInfo[@"Info"] rangeOfString:@"SunAttention"].location !=NSNotFound)
    {
        //扫描关注
        NSString *str=[not.userInfo[@"Info"] componentsSeparatedByString:@"*"][1];
        //扫描的是网址
        SunAddAttentionViewController *att=[[SunAddAttentionViewController alloc]init];
        att.text=str;
        [self.navigationController pushViewController:att animated:YES];
        
    }else{
        SunDeviceBindiewController *bind=[[SunDeviceBindiewController alloc]init];
        bind.EquCode=not.userInfo[@"Info"];
        [self.navigationController pushViewController:bind animated:YES];
    }
    
}



-(void)setUpMain
{
    //self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //添加一个可以滚动的scrollView
    UIScrollView *contentScrollView=[[UIScrollView alloc] init];
    contentScrollView.backgroundColor=[UIColor whiteColor];
    CGFloat scrollW=[UIScreen mainScreen].bounds.size.width;
    [self.view addSubview:contentScrollView];
    contentScrollView.frame=CGRectMake(0, -64,ScreenWidth , ScreenHeight+15);
    
    contentScrollView.contentSize=CGSizeMake(scrollW, 130);
    contentScrollView.delegate=self;
   // contentScrollView.bounces=NO;
    //设置偏移量
    contentScrollView.contentOffset=CGPointMake(0, -128);
    contentScrollView.showsVerticalScrollIndicator=NO;
    self.contentScrollView=contentScrollView;
    
    
    //添加左右标志
    UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setBackgroundImage:[UIImage imageNamed:@"ic_scan"] forState:UIControlStateNormal];
    
    btnLeft.frame=(CGRect){CGPointZero,btnLeft.currentBackgroundImage.size};
    [btnLeft addTarget:self action:@selector(sao) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnLeft] ;
    
    UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRight=btnRight;
    [btnRight setBackgroundImage:[UIImage imageNamed:@"mes_ic"] forState:UIControlStateNormal];
    
    btnRight.frame=(CGRect){CGPointZero,btnRight.currentBackgroundImage.size};
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btnRight] ;
    [btnRight addTarget:self action:@selector(news) forControlEvents:UIControlEventTouchUpInside];
    
    //添加刷新控件
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.contentScrollView.mj_header=header;
    //[header beginRefreshing];
    self.header=header;
}

//下拉刷新数据
-(void)loadData
{
    [self setUpLun];
    [self.header endRefreshing];
    
    
}

//查看是否有无消息
-(void)getNews
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetHaveNews*%@",login.usercode];
    [self.manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //解析
        NSDictionary *dicResult=json;
        NSString *str=[dicResult[@"Result"] copy];
        if ([str isEqualToString: @"yes"]) {
            //判断之前是否添加过
            if (self.btnRight.subviews.count==1) {
                //添加未读标记
                UIView *redView=[[UIView alloc]init];
                redView.backgroundColor=[UIColor redColor];
                redView.layer.cornerRadius=2.5;
                redView.layer.masksToBounds=YES;
                [self.btnRight addSubview:redView];
                [redView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self.btnRight).offset(3);
                    make.centerY.equalTo(self.btnRight).offset(4);
                    make.width.mas_equalTo(5);
                    make.height.mas_equalTo(5);
                }];
            }
        }else{
            //没有
            if (self.btnRight.subviews.count>1) {
                [[self.btnRight.subviews lastObject] removeFromSuperview];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"查询消息失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//健康
-(void)setUpContain
{
    
    //数据轮播页
    UIView *dataView=[[UIView alloc] init];
    self.dataView=dataView;
    [self.contentScrollView addSubview:dataView];
    dataView.frame=CGRectMake(0, 0, self.contentScrollView.frame.size.width, 220);
    
    
    //健康步数
    UIView *healthView=[[UIView alloc]init];
    self.healthView=healthView;
    [self.contentScrollView addSubview:healthView];
    CGFloat healthH=60;
    [healthView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dataView.mas_bottom).offset(ModelTopPadding);
        make.width.equalTo(dataView.mas_width);
        make.height.mas_equalTo(healthH);
    }];
    //鞋子和火苗图片
    CGFloat healthPadding=10;
    UIImageView *shoesImgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shoes-blue"]];
    [healthView addSubview:shoesImgView];
    [shoesImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthView).offset(healthPadding);
        make.height.equalTo(healthView.mas_height).offset(-healthPadding*2);
        make.width.equalTo(shoesImgView.mas_height);
        make.left.mas_equalTo(5*healthPadding);
    }];
    //文字
    UILabel *shoesLab=[self lableWithName:@"" isFirst:YES];
    self.shoesLab=shoesLab;
    [healthView addSubview:shoesLab];
    [shoesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthView.mas_top);
        make.left.equalTo(shoesImgView.mas_right).offset(healthPadding);
        make.height.equalTo(healthView);
        //make.width.mas_equalTo(100);
    }];
    //设置宽度，根据内容决定
    /*
     Content Compression Resistance = 不许挤我！
     
     对，这个属性说白了就是“不许挤我”=。=
     这个属性的优先级（Priority）越高，越不“容易”被压缩。也就是说，当整体的空间装不小所有的View的时候，Content Compression Resistance优先级越高的，现实的内容越完整。
     
     Content Hugging = 抱紧！
     
     这个属性的优先级越高，整个View就要越“抱紧”View里面的内容。也就是View的大小不会随着父级View的扩大而扩大。
     
     分析
     
     根据要求，可以将约束分为两个部分：
     
     整体空间足够时，两个label的宽度由内容决定，也就是说，label的“Content Hugging”优先级很高，而且没有固定的Width属性。
     整体空间不够时，左边的label更不容易被压缩，也就是“Content Compression Resistance”优先级更高。
     */
    [shoesLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //设置label1的content compression 为1000
    [shoesLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    //单位
    UILabel *shoesD=[self lableWithName:@"步" isFirst:NO];
    [healthView addSubview:shoesD];
    [shoesD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthView.mas_top);
        make.left.equalTo(shoesLab.mas_right).offset(5);
        make.height.equalTo(healthView);
        //make.width.mas_equalTo(100);
    }];
    
    [shoesD setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //设置label1的content compression 为1000
    [shoesD setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //卡路里
    //鞋子和火苗图片
    
    //单位
    //获取鞋子图标x值
    //CGFloat shoesX=shoesImgView.frame.origin.x;
    //NSLog(@"%f",shoesX);
    UILabel *kaD=[self lableWithName:@"千卡" isFirst:NO];
    [healthView addSubview:kaD];
    [kaD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthView.mas_top);
        make.right.equalTo(healthView).offset(-5*healthPadding);
        make.height.equalTo(shoesD);
        //make.width.mas_equalTo(100);
    }];
    
    [kaD setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //设置label1的content compression 为1000
    [kaD setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //文字
    UILabel *kaLab=[self lableWithName:@"74" isFirst:YES];
    self.kaLab=kaLab;
    [healthView addSubview:kaLab];
    [kaLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(healthView.mas_top);
        make.right.equalTo(kaD.mas_left).offset(-5);
        make.height.equalTo(healthView);
        //make.width.mas_equalTo(100);
    }];
    
    [kaLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //设置label1的content compression 为1000
    [kaLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    
    UIImageView *kaImgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redfire"]];
    [healthView addSubview:kaImgView];
    [kaImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(kaLab.mas_left).offset(-healthPadding);
        make.height.equalTo(shoesImgView);
        make.width.equalTo(shoesImgView).offset(-8);
        make.centerY.equalTo(shoesImgView.mas_centerY);
    }];
    
    
    
    //添加底部分割线
    UIView *cutView=[[UIView alloc] init];
    cutView .backgroundColor=MrColor(225, 225, 225);
    [healthView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(healthView);
        make.height.mas_equalTo(CutViewHeight);
        make.bottom.equalTo(healthView);
        
    }];
    //读取数据
    [self getStepNum];
}

//轮播图
-(void)setUpLun
{
    NSMutableArray *arrayLun=[NSMutableArray array];
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetAlarm*%@",login.usercode];
    //AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [self.manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSMutableArray *arrayLunData=[SunWarningModel mj_objectArrayWithKeyValuesArray:json];
        if (arrayLunData.count>0) {
            for (int i=0; i<arrayLunData.count; i++) {
                SunWarningModel *waring=arrayLunData[i];
                if ([waring.WARNTYPE isEqualToString:@"高血压"]) {
                    NSArray *bloodArray=[waring.CHECKVALUE componentsSeparatedByString:@"/"];
                    self.bloodView= [self imageBloodCarouselWith:bloodArray[0] di:bloodArray[1] rate:bloodArray[2] time:waring.CHECKTIME  result:waring.WARNLEVEL];
                    [arrayLun addObject:self.bloodView];
                }else{
                    CGFloat temp=[waring.CHECKVALUE floatValue];
                    temp=temp/18;
                    self.sugarView= [self imageSugarCarouselWith:[NSString stringWithFormat:@"%.1f",temp] time:waring.CHECKTIME result:waring.WARNLEVEL];
                    [arrayLun addObject:self.sugarView];
                }
            }
            
            
        }
        
        if(arrayLun.count==2){
            //轮播图
            SXScrPageView * sxView =[SXScrPageView direcWithtFrame:CGRectMake(0, 0,self.dataView.frame.size.width, self.dataView.frame.size.height) ImageArr:arrayLun AndImageClickBlock:nil];
            [self.dataView addSubview:sxView];
        }else if(arrayLun.count==1)
        {
            //只有一个
            UIView *view= [arrayLun objectAtIndex:0];
            view.frame=self.dataView.bounds;
            [self.dataView addSubview:view];
        }else if(arrayLun.count==0)
        {
            //一个没有是话显示暂无
            UIView *noView=[self getNoHaveWarning];
            noView.frame=self.dataView.bounds;
            [self.dataView addSubview:noView];
        }
        
        //加载用药提醒
        [self loadDrugInfo];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载告警数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    

}

#pragma mark --轮播图标方法
/**
 *  血压轮播图
 *
 *  @param gao    高压
 *  @param di     低压
 *  @param rate   心率
 *  @param time   时间
 *  @param result 结果
 *
 *  @return 图片视图
 */
-(UIView *)imageBloodCarouselWith:(NSString *)gao di:(NSString *)di rate:(NSString *)rate time:(NSString *)time result:(NSString *)result
{
    //透明度
    CGFloat alphaView=0.7;
    UIColor *bgColor=[UIColor flatBlueColor];
    UIView *imgView=[[UIView alloc]init];
    if ([result isEqualToString:@"正常"]) {
        bgColor = [UIColor flatGreenColor];
    } else if ([result isEqualToString:@"最理想"]) {
        bgColor = [UIColor flatGreenColor];
    }
    else if ([result isEqualToString:@"轻度低血压"]) {
        bgColor = [UIColor flatGrayColor];
    }
    else if ([result isEqualToString:@"重度低血压"]) {
        bgColor = [UIColor flatGrayColorDark];
    }
    else if ([result isEqualToString:@"中度高血压"]) {
        bgColor = [UIColor flatOrangeColor];
    }
    else if ([result isEqualToString:@"轻度高血压"]) {
        bgColor = [UIColor flatYellowColor];
    } else if ([result isEqualToString:@"重度高血压"]) {
        bgColor = [UIColor flatRedColor];
    } else if ([result isEqualToString:@"正常偏高"]) {
        bgColor = [UIColor flatPinkColor];
    }
    imgView.backgroundColor=bgColor;
    imgView.frame=(CGRect){CGPointZero,self.dataView.frame.size};
    CGFloat padding=50;
    //中间内容视图
    UIView *contView=[[UIView alloc]init];
    contView.alpha=alphaView;
    contView.backgroundColor=[UIColor flatWhiteColor];
    [imgView addSubview:contView];
    CGFloat contW=imgView.frame.size.width-padding*2;
    CGFloat contH=imgView.frame.size.height-64-25;
    contView.frame=CGRectMake(padding, 64, contW, contH);

    //结果
    UILabel *labResult=[[UILabel alloc]init];
    labResult.text=result;
    labResult.textAlignment=NSTextAlignmentCenter;
    labResult.backgroundColor=[UIColor flatGrayColor];
    labResult.textColor=bgColor;
    labResult.font=kFont(20);
    labResult.alpha=alphaView;
    [contView addSubview:labResult];
    labResult.frame=CGRectMake(0, 0, contView.frame.size.width, contView.frame.size.height*0.27);

    
    //高压
    CGFloat fontPadding=18;
    UILabel *labHig=[[UILabel alloc]init];
    labHig.text=gao;
    labHig.textColor=[UIColor flatBlueColor];
    labHig.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
    labHig.font=kFont(30);
    [contView addSubview:labHig];
    CGRect gaoRect=[gao boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labHig.font} context:nil];
    
    CGFloat gaoY=labResult.frame.size.height+5;
    labHig.frame=CGRectMake(fontPadding, gaoY, gaoRect.size.width, gaoRect.size.height);

    UILabel *labCut=[[UILabel alloc]init];
    labCut.text=@"/";
    labCut.textColor=[UIColor flatPlumColor];
    labCut.font=labHig.font;
    [contView addSubview:labCut];
    CGFloat labCutX=fontPadding+gaoRect.size.width+2;
    CGRect labCutRect=[labCut.text boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labHig.font} context:nil];
    labCut.frame=CGRectMake(labCutX, gaoY, labCutRect.size.width, labCutRect.size.height);

    UILabel *labLow=[[UILabel alloc]init];
    labLow.text=di;
    labLow.textColor=[UIColor flatPurpleColor];
    labLow.font=labHig.font;
    [contView addSubview:labLow];
    CGRect labLowRect=[labLow.text boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labHig.font} context:nil];
    labLow.frame=CGRectMake(labCutX+2+labCutRect.size.width, gaoY, labLowRect.size.width, labLowRect.size.height);

    
    //心率
    UILabel *labRate=[[UILabel alloc]init];
    labRate.text=rate;
    labRate.textColor=[UIColor flatGrayColor];
    labRate.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
    labRate.font=kFont(25);
    [contView addSubview:labRate];
    CGRect labRateRect=[labRate.text boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labRate.font} context:nil];
    CGFloat labRateX=contView.frame.size.width-fontPadding-labRateRect.size.width;
    CGFloat labRateY=(labLowRect.size.height-labRateRect.size.height)+gaoY;
    labRate.frame=CGRectMake(labRateX, labRateY, labRateRect.size.width, labRateRect.size.height);

    //单位
    UILabel *labUnitLeft=[[UILabel alloc]init];
    labUnitLeft.text=@"mmHg";
    labUnitLeft.textColor=[UIColor flatGrayColor];
    labUnitLeft.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
    labUnitLeft.font=kFont(15);
    [contView addSubview:labUnitLeft];
    CGRect labUnitLeftRect=[labUnitLeft.text boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labUnitLeft.font} context:nil];
    
    CGFloat labUnitLeftX=CGRectGetMaxX(labLow.frame)-labUnitLeftRect.size.width;
    CGFloat labUnitLeftY=CGRectGetMaxY(labLow.frame);
    labUnitLeft.frame=CGRectMake(labUnitLeftX, labUnitLeftY, labUnitLeftRect.size.width, labUnitLeftRect.size.height);

    //单位
    UILabel *labUnitRight=[[UILabel alloc]init];
    labUnitRight.text=@"bpm";
    labUnitRight.textColor=[UIColor flatGrayColor];
    labUnitRight.font=labUnitLeft.font;
    [contView addSubview:labUnitRight];
    CGRect labUnitRightRect=[labUnitRight.text boundingRectWithSize:CGSizeMake(120,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labUnitRight.font} context:nil];
    CGFloat labUnitRightX=CGRectGetMaxX(labRate.frame)-labUnitRightRect.size.width;
    CGFloat labUnitRightY=CGRectGetMaxY(labRate.frame);
    labUnitRight.frame=CGRectMake(labUnitRightX, labUnitRightY, labUnitRightRect.size.width, labUnitRightRect.size.height);

    //时间
    UILabel *labTime=[[UILabel alloc]init];
    labTime.text=time;
    labTime.textColor=[UIColor flatGrayColor];
    labTime.font=labUnitLeft.font;
    [contView addSubview:labTime];
    CGRect labTimeRect=[labTime.text boundingRectWithSize:CGSizeMake(300,60) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labTime.font} context:nil];
    CGFloat labTimeY=contView.frame.size.height-5-labTimeRect.size.height;
    labTime.frame=CGRectMake(fontPadding, labTimeY, labTimeRect.size.width, labTimeRect.size.height);
    return imgView;
}
//血糖轮播
-(UIView *)imageSugarCarouselWith:(NSString *)value time:(NSString *)time result:(NSString *)result
{
    //透明度
    CGFloat alphaView=0.7;
    UIColor *bgColor=[UIColor flatRedColor];
    UIView *imgView=[[UIView alloc]init];
    if ([result isEqualToString:@"正常"]) {
        bgColor = [UIColor flatGreenColor];
    } else if ([result isEqualToString:@"高血糖"]) {
        bgColor = [UIColor flatRedColor];
    }
    else if ([result isEqualToString:@"低血糖"]) {
        bgColor = [UIColor flatGrayColor];
    }
    imgView.backgroundColor=bgColor;
    imgView.frame=(CGRect){CGPointZero,self.dataView.frame.size};
    CGFloat padding=50;
    UIView *contView=[[UIView alloc]init];
    contView.alpha=alphaView;
    contView.backgroundColor=[UIColor flatWhiteColor];
    [imgView addSubview:contView];
    CGFloat contW=imgView.frame.size.width-padding*2;
    CGFloat contH=imgView.frame.size.height-64-25;
    contView.frame=CGRectMake(padding, 64, contW, contH);

    UILabel *labResult=[[UILabel alloc]init];
    labResult.text=result;
    labResult.textAlignment=NSTextAlignmentCenter;
    labResult.backgroundColor=[UIColor flatGrayColor];
    [labResult setTextColor:[UIColor whiteColor]];
    labResult.font=kFont(20);
    labResult.alpha=alphaView;
    [contView addSubview:labResult];
    labResult.frame=CGRectMake(0, 0, contView.frame.size.width, contView.frame.size.height*0.27);
    //血糖值
    UILabel *labVal=[[UILabel alloc]init];
    labVal.text=value;
    labVal.textColor=MrColor(33, 135, 244);
    labVal.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
    labVal.font=kFont(30);
    [contView addSubview:labVal];
    CGRect valRect=[value boundingRectWithSize:CGSizeMake(200, 50) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labVal.font} context:0];
    CGFloat valX=(contView.frame.size.width-valRect.size.width)/2;
    labVal.frame=CGRectMake(valX, CGRectGetMaxY(labResult.frame)+5, valRect.size.width, valRect.size.height);
    
    
    //单位
    UILabel *labUnitLeft=[[UILabel alloc]init];
    labUnitLeft.text=@"mmol/L";
    labUnitLeft.textColor=[UIColor flatGrayColor];
    labUnitLeft.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:10];
    labUnitLeft.font=kFont(15);
    [contView addSubview:labUnitLeft];
    CGRect unitRect=[labUnitLeft.text boundingRectWithSize:CGSizeMake(100, 50) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labUnitLeft.font} context:0];
    
    CGFloat unitX=(contView.frame.size.width-unitRect.size.width)/2;
    labUnitLeft.frame=CGRectMake(unitX, CGRectGetMaxY(labVal.frame), unitRect.size.width, unitRect.size.height);
 
    
    //时间
    UILabel *labTime=[[UILabel alloc]init];
    labTime.text=time;
    labTime.textColor=[UIColor flatGrayColor];
    labTime.font=labUnitLeft.font;
    [contView addSubview:labTime];
    CGRect timeRect=[time boundingRectWithSize:CGSizeMake(200, 50) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : labTime.font} context:0];
    CGFloat timeX=(contView.frame.size.width-timeRect.size.width)/2;
    labTime.frame=CGRectMake(timeX, contView.frame.size.height-timeRect.size.height-3, timeRect.size.width, timeRect.size.height);
    return imgView;
}
//暂无告警
-(UIView *)getNoHaveWarning
{
    //透明度
    CGFloat alphaView=0.7;
    UIColor *bgColor=[UIColor flatBlueColor];
    UIView *imgView=[[UIView alloc]init];
    
    imgView.backgroundColor=bgColor;
    imgView.frame=(CGRect){CGPointZero,self.dataView.frame.size};
    CGFloat padding=50;
    UIView *contView=[[UIView alloc]init];
    contView.alpha=alphaView;
    contView.backgroundColor=[UIColor flatWhiteColor];
    [imgView addSubview:contView];
    [contView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView).offset(padding);
        make.right.equalTo(imgView).offset(-padding);
        make.top.equalTo(imgView).offset(64);
        make.bottom.equalTo(imgView).offset(-25);
    }];
    
    UILabel *labResult=[[UILabel alloc]init];
    labResult.text=@"暂无报警";
    labResult.textAlignment=NSTextAlignmentCenter;
    labResult.backgroundColor=[UIColor flatGrayColor];
    labResult.textColor=[UIColor whiteColor];
    labResult.font=kFont(20);
    labResult.alpha=alphaView;
    [contView addSubview:labResult];
    [labResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contView);
        make.top.equalTo(contView);
        make.left.equalTo(contView);
        make.height.equalTo(contView).multipliedBy(0.27);
    }];
    
    //笑脸标志
    UIImageView *smilImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"smiley"]];
    [contView addSubview:smilImgView];
    [smilImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labResult.mas_bottom).offset(10);
        make.centerX.equalTo(contView);
        make.width.equalTo(smilImgView.mas_height);
        make.bottom.equalTo(contView).offset(-10);
    }];
    return imgView;
}


/**
 *  根据颜色生成图片
 *
 *  @param color 颜色
 *
 *  @return 图片
 */
- (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);  //图片尺寸
    UIGraphicsBeginImageContext(rect.size); //填充画笔
    CGContextRef context = UIGraphicsGetCurrentContext(); //根据所传颜色绘制
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect); //联系显示区域
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext(); // 得到图片信息
    UIGraphicsEndImageContext(); //消除画笔
    return image;
}
//添加关注布局
-(void)addAttention
{
    UIView *attentoinView=[[UIView alloc] init];
    self.attentoinView=attentoinView;
    [self.contentScrollView addSubview:attentoinView];
    [attentoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.healthView.mas_bottom).offset(ModelTopPadding);
        make.width.equalTo(self.contentScrollView);
        make.height.mas_equalTo(80);
    }];
    CGFloat padding=10;
    SunAttentionView *attView=[[SunAttentionView alloc]init];
    attView.imgView.image=[UIImage imageNamed:@"man"];
    attView.lable.text=@"我";
    attView.isAdd=NO;
    [attentoinView addSubview:attView];
    [attView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(attentoinView).multipliedBy(0.15);
        make.top.equalTo(attentoinView);
        make.height.equalTo(attentoinView);
        make.left.equalTo(attentoinView).offset(6*padding);
    }];
    
    SunAttentionView *addView=[[SunAttentionView alloc]init];
    addView.imgView.image=[UIImage imageNamed:@"Add"];
    addView.isAdd=YES;
    [attentoinView addSubview:addView];
    [addView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(attView);
        make.right.equalTo(attentoinView).offset(-6*padding);
        make.top.equalTo(attentoinView);
    }];
    
    
    
    //添加整体底部分割线
    UIView *allCutView=[[UIView alloc] init];
    allCutView.backgroundColor=MrColor(225, 225, 225);
    [attentoinView addSubview:allCutView];
    [allCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(attentoinView);
        make.height.mas_equalTo(CutViewHeight);
        make.centerX.equalTo(attentoinView);
        make.bottom.equalTo(attentoinView);
    }];
    
}

//添加模块布局
-(void)addModel
{
    UIView *modelView=[[UIView alloc]init];
    self.modelView=modelView;
    [self.contentScrollView addSubview:modelView];
    [modelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.healthView.mas_bottom).offset(ModelTopPadding);
        make.width.equalTo(self.contentScrollView);
        make.height.mas_equalTo(150);
        make.left.equalTo(self.contentScrollView);
    }];
    //添加四个模块
    UIView *wen=[self viewWithImageName:@"voicemail" firstTitle:@"问问专家" secondTitle:@"问专家，更放心"];
    //添加手势
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wenClick)];
    [wen addGestureRecognizer:tap];
    [modelView addSubview:wen];
    UIImageView *imgWen=wen.subviews[0];
    self.imgWen=imgWen;
    [wen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(modelView);
        make.height.equalTo(modelView).multipliedBy(0.5);
        make.width.equalTo(modelView).multipliedBy(0.5);
        make.top.equalTo(modelView);
    }];
    
    UIView *xue=[self viewWithImageName:@"book" firstTitle:@"学学知识" secondTitle:@"把握健康资讯"];
    [modelView addSubview:xue];
    UITapGestureRecognizer *tapXue=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xueClick)];
    [xue addGestureRecognizer:tapXue];
    [xue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(modelView);
        make.size.equalTo(wen);
        make.top.equalTo(modelView);
    }];
    
    UIView *she=[self viewWithImageName:@"tv" firstTitle:@"设备管理" secondTitle:@"掌握设备的使用"];
    [modelView addSubview:she];
    UITapGestureRecognizer *tapShe=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sheClick)];
    [she addGestureRecognizer:tapShe];
    [she mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(modelView);
        make.size.equalTo(wen);
        make.top.equalTo(wen.mas_bottom);
    }];
    
    UIView *yong=[self viewWithImageName:@"stats" firstTitle:@"用药信息" secondTitle:@"吃对药，才重要"];
    [modelView addSubview:yong];
    UITapGestureRecognizer *tapYong=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yongClick)];
    [yong addGestureRecognizer:tapYong];
    [yong mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(modelView);
        make.size.equalTo(she);
        make.top.equalTo(wen.mas_bottom);
    }];
    //添加两个水平垂直分割线
    UIView *hView=[[UIView alloc] init];
    hView .backgroundColor=MrColor(225, 225, 225);
    [modelView addSubview:hView];
    [hView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(modelView).offset(-40);
        make.height.mas_equalTo(1);
        make.center.equalTo(modelView);
        
    }];
    
    UIView *vView=[[UIView alloc] init];
    vView .backgroundColor=MrColor(225, 225, 225);
    [modelView addSubview:vView];
    [vView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.equalTo(modelView).offset(-30);
        make.center.equalTo(modelView);
        
    }];
    
    //添加底部分割线
    UIView *cutView=[[UIView alloc] init];
    cutView .backgroundColor=MrColor(225, 225, 225);
    [modelView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(modelView);
        make.height.mas_equalTo(CutViewHeight);
        make.bottom.equalTo(modelView);
        
    }];
}


// 统计未读消息数
-(NSInteger)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    return unreadCount;
}



#pragma mark --手势识别
-(void)wenClick
{
    [self.navigationController pushViewController:[[SunMyServerTableViewController alloc]init] animated:YES];
}
-(void)xueClick
{
    [CCWebViewController showWithContro:self withUrlStr:@"http://182.92.73.203/page/Specal2.html" withTitle:@"学一学"];
}
-(void)sheClick
{
    [self.navigationController pushViewController:[[SunDeviceTableViewController alloc]init] animated:YES];
}
-(void)yongClick
{
    [self.navigationController pushViewController:[[SunDrugViewController alloc]init] animated:YES];
}
//今日用药
-(void)setUpDrug
{
    UIView *drugView=[[UIView alloc]init];
    //drugView.backgroundColor=[UIColor orangeColor];
    [self.contentScrollView addSubview:drugView];
    self.drugView=drugView;
    [drugView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.modelView.mas_bottom);
        make.width.equalTo(self.contentScrollView);
        make.left.equalTo(self.contentScrollView);
        make.bottom.equalTo(self.contentScrollView);
    }];
    
    //添加顶部标题和按钮
    UILabel *titleLable=[[UILabel alloc]init];
    titleLable.text=@"今日用药";
    titleLable.font=kFont(14);
    [drugView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(drugView);
        make.width.equalTo(drugView).multipliedBy(0.5);
        make.left.equalTo(drugView).offset(20);
        make.height.mas_equalTo(30);
    }];
    //顶部分割线
    UIView *topCutView=[[UIView alloc]init];
    topCutView.backgroundColor=MrColor(225, 225, 225);
    [drugView addSubview:topCutView];
    [topCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLable.mas_bottom);
        make.width.equalTo(drugView);
        make.height.mas_equalTo(CutViewHeight);
        make.left.equalTo(drugView);
    }];
    
    
    
    
    
    
}
//加载用药提醒
-(void)loadDrugInfo
{
    CGFloat padding=10;
   // AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedRemind*%@",login.usercode];
    [self.manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //清除所有本地通知
        if(iOSVersion>=10.0){
            UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeAllPendingNotificationRequests];
        }else{
            //清除本地通知
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        //清楚页面元素
        for (UIView *view in self.drugView.subviews) {
            if ([view isKindOfClass:[SunDrugView class]]) {
                [view removeFromSuperview];
            }
        }
        self.arrayData=[SunDrugModel mj_objectArrayWithKeyValuesArray:json];
        if (self.arrayData.count==0) {
            //暂无用药提醒
            UILabel *labNoDrug=[[UILabel alloc]init];
            self.labNoDrug=labNoDrug;
            labNoDrug.textAlignment=NSTextAlignmentCenter;
            labNoDrug.font=kFont(15);
            labNoDrug.textColor=MrColor(153, 153, 153);
            labNoDrug.text=@"暂无用药";
            [self.drugView addSubview:labNoDrug];
            labNoDrug.frame=CGRectMake(0, 30, SCREEN_WIDTH, 30);
            return;
        }else{
            [self.labNoDrug removeFromSuperview];
        }
        int index=0;
        for(SunDrugModel *data in self.arrayData)
        {
            UIView *subView=[self.drugView.subviews lastObject];
            SunDrugView *sunDrView=[[SunDrugView alloc]init];
            sunDrView.delegate=self;
            sunDrView.name.text=data.MedName;
            sunDrView.num.text=[NSString stringWithFormat:@"%@/%@",data.Num,data.Unit];
            sunDrView.ways.text=data.Ways;
            sunDrView.time.text=data.PlanTime;
            sunDrView.timeName.text=@"时间:";
            sunDrView.fuBtn.tag=index;
            sunDrView.againBtn.tag=index;
            [self.drugView addSubview:sunDrView];
            //设置本地推送
            [self addLocationInfoTime:data.PlanTime name:data.MedName index:index];
            
            [sunDrView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(subView.mas_bottom).offset(padding);
                make.left.equalTo(self.drugView).offset(padding);
                make.right.equalTo(self.drugView).offset(-padding);
                make.height.mas_equalTo(100);
            }];
            index++;
        }
        
        //更新用药模块的高度
        UIView *subAllView=[self.drugView.subviews lastObject];
        [self.drugView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(subAllView).offset(10);
        }];
        [self.view layoutIfNeeded];
        
        //查询未读消息
        [self getNews];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}


#pragma mark --用药信息按钮代理
//设置已付用
-(void)sunDrugViewFu:(SunDrugView *)drugView
{
    //获取计划明细编码
    int index=(int)drugView.fuBtn.tag;
    SunDrugModel *drugMode=self.arrayData[index];
    //已付
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"SetMedStatus*%@",drugMode.MedDCode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self loadDrugInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
-(void)sunDrugViewAgain:(SunDrugView *)drugView
{
    //在提醒
    //获取计划明细编码
    int index=(int)drugView.fuBtn.tag;
    SunDrugModel *drugMode=self.arrayData[index];
    //已付
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"SetTimeAddTenMinutes*%@*%@",drugMode.MedDCode,drugMode.NextTime];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"在提醒成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        [self loadDrugInfo];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//添加本地推动用药提醒
-(void)addLocationInfoTime:(NSString *)time name:(NSString *)name index:(int)index
{
    //判断时间是否为空
    if ([time isEqualToString:@""]||time==nil) {
        return;
    }
    NSInteger h=[[time componentsSeparatedByString:@":"][0] intValue];
    NSInteger m=[[time componentsSeparatedByString:@":"][1] intValue];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    dateComponents.hour =h;
    dateComponents.minute = m;
    if(iOSVersion>=10.0){
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
        
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"用药提醒!" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"服用药物:%@ 时间:%@",name,time]
                                                             arguments:nil];
        
        content.sound = [UNNotificationSound defaultSound];
        content.userInfo=[NSDictionary dictionaryWithObjectsAndKeys:@"sun.location",@"id",[NSNumber numberWithInteger:index],@"index",time,@"time",nil];
        
        // 在 alertTime 后推送本地推送
//        UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
//                                                      triggerWithTimeInterval:timeInterval repeats:NO];
        
        //特定时间提醒
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger  triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:name
                                                                        content:content trigger:trigger];
       
        //添加推送成功后的处理！
        [center addNotificationRequest:request withCompletionHandler:nil];
        
        
    }else if(iOSVersion>9.0 && iOSVersion<10.0){
        
        
        
        //实例化本地通知
        UILocalNotification *location=[[UILocalNotification alloc]init];
        //设置本地通知的触发时间（如果要立即触发，无需设置
        location.fireDate=[calendar dateFromComponents:dateComponents];
        //设置本地时区
        location.timeZone=[NSTimeZone defaultTimeZone];
        //设置通知的内容
        location.alertBody=[NSString stringWithFormat:@"服用药物:%@",name];
        //设置通知动作按钮的标题
        location.alertAction=@"查看";
        //设置提醒的声音，可以自己添加声音文件，这里设置为默认提示声
        location.soundName=UILocalNotificationDefaultSoundName;
        //location.alertTitle=@"用药提醒";
        //设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息//设置通知的相关信息，这个很重要，可以添加一些标记性内容，方便以后区分和获取通知的信息
        //值和键
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:@"sun.location",@"id",[NSNumber numberWithInteger:index],@"index",time,@"time",name,@"name",nil];
        location.userInfo = infoDic;
        //在规定的日期触发通知
        [[UIApplication sharedApplication] scheduleLocalNotification:location];
     
    }
    
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

//返回模块信息
-(UIView *)viewWithImageName:(NSString *)name firstTitle:(NSString *)firstTitle secondTitle:(NSString *)secondTitle
{
    UIView *conView=[[UIView alloc] init];
    UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:name]];
    [conView addSubview:img];
    CGFloat padding=10;
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(conView).offset(-padding*4);
        make.top.equalTo(conView).offset(padding);
        make.right.equalTo(conView).offset(-padding*1.3);
        make.width.equalTo(img.mas_height);
    }];
    
    UILabel *firstLab=[[UILabel alloc]init];
    [conView addSubview:firstLab];
    firstLab.font=kFont(15);
    firstLab.text=firstTitle;
    [firstLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(conView).offset(10);
        make.left.equalTo(conView).offset(padding*2);
        make.height.equalTo(conView).multipliedBy(0.5).offset(-10);
        make.right.equalTo(img.mas_left).offset(-padding);
        //make.width.mas_equalTo(100);
    }];
    
    
    UILabel *secondLab=[[UILabel alloc]init];
    [conView addSubview:secondLab];
    secondLab.text=secondTitle;
    [secondLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstLab.mas_bottom);
        make.width.equalTo(firstLab);
        make.height.equalTo(firstLab).offset(-10);
        make.centerX.equalTo(firstLab);
    }];
    secondLab.font=kFont(11);
    secondLab.textColor=MrColor(153, 153, 153);
    
    
    return conView;
}

-(UILabel *)lableWithName:(NSString *)name isFirst:(BOOL)isFirst
{
    UILabel *lable=[[UILabel alloc]init];
    lable.text=name;
    if (isFirst) {
        lable.font=[UIFont systemFontOfSize:18];
        lable.textColor=MrColor(51, 51, 51);
    
    }else
    {
        lable.font=[UIFont systemFontOfSize:14];
        lable.textColor=MrColor(153, 153, 153);
    }
    
    return lable;

}




//找到导航栏下面的黑线，
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}
//扫一扫
-(void)sao
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"SunHomeViewController" forKey:@"NotificationName"];
    //设置同步
    [defaults synchronize];
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"QRCodeViewController" bundle:nil];
    //初始化
    SunQRViewController *vc=[sb instantiateViewControllerWithIdentifier:@"vc"];
    [self.navigationController presentViewController:vc animated:YES completion:nil ];
    
    
}

//打开消息
-(void)news
{
    SunNavigationController *nav=[[SunNavigationController alloc] initWithRootViewController:[[SunNewsViewController alloc]init]] ;
    [self presentViewController:nav animated:YES completion:nil];
    
}
#pragma mark --scrollView协议
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //计算上下的偏移量
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY >=  0) {
        CGFloat alpha = MIN(1, (offsetY-20)/64);
        self.bgView.alpha =alpha;
    } else {
        self.bgView.alpha=0;
    }
}

#pragma mark --读取健康步数
-(void)getStepNum
{
    HealthKitManage *manage = [HealthKitManage shareInstance];
    [manage authorizeHealthKit:^(BOOL success, NSError *error) {
        
        if (success) {
            [manage getStepCount:^(double value, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.shoesLab.text = [NSString stringWithFormat:@"%.0f", value];
                    self.kaLab.text= [NSString stringWithFormat:@"%.0f", value*60*(value/1000)*1.036/1000];
                });
                
            }];
        }
        else {
            [SVProgressHUD showErrorWithStatus:@"获取健康数据失败"];
        }
    }];
    
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
