//
//  SunDataViewController.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  数据页

#import "SunDataViewController.h"
#import "MJRefresh.h"
#import "SunDataBloodView.h"
#import "SunDataSugarView.h"
#import "SunDataCategoryView.h"
#import "AFNetworking.h"
#import "SunWeatherModel.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunThirdData.h"
#import <CoreLocation/CoreLocation.h>
#import "SunSpeedVoice.h"
#import "SunBloodViewController.h"
#import "SunSugarViewController.h"

@interface SunDataViewController ()<CLLocationManagerDelegate,SunDataBloodViewDelegate,SunDataSugarViewDelegate,SunDataCategoryViewDelegate>
@property(nonatomic,strong)UIScrollView *contentScrollView;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
//顶部容器
@property(nonatomic,strong)UIView *topContentView;
//天气lable
@property(nonatomic,strong)UILabel *labWeather;
@property(nonatomic,strong)CLLocationManager *locationManager;
//最近三条总数据
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)UILabel *thirdLab;
@end

#define ViewTopPadding 5
#define ViewHeight 60
@implementation SunDataViewController
//懒加载
-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem.image=[UIImage imageNamed:@"File"];
    if(self.otherUserName==nil){
        self.navigationItem.title=@"数据";
    }else{
        self.navigationItem.title=[NSString stringWithFormat:@"%@的数据",self.otherUserName];
    }
    
    self.view.backgroundColor=[UIColor whiteColor];
    //添加控件
    [self setUpMain];
    
    //布局下面
    [self bottomView];
    
    //获取地理坐标
    [self setUpLocation];
    
    [self setUpThridData];
}

-(void)setUpMain
{
    UIScrollView *contentScrollView=[[UIScrollView alloc]init];
    self.contentScrollView=contentScrollView;
    //contentScrollView.backgroundColor=[UIColor redColor];
    [self.view addSubview:contentScrollView];
    contentScrollView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-105);
    contentScrollView.contentSize=CGSizeMake(SCREEN_WIDTH, 800);
    contentScrollView.showsHorizontalScrollIndicator=NO;
    //添加刷新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.header=header;
    contentScrollView.mj_header=header;
    
    //添加容器
    UIView *topContentView=[[UIView alloc]init];
    [contentScrollView addSubview:topContentView];
    self.topContentView=topContentView;
    //添加标题
    UILabel *thirdLab=[[UILabel alloc]init];
    self.thirdLab=thirdLab;
    thirdLab.text=@"最近三次测量结果";
    thirdLab.font=kFont(15);
    thirdLab.textColor=MrColor(105, 105, 105);
    [topContentView addSubview:thirdLab];
    [thirdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topContentView).offset(ViewTopPadding);
        make.left.equalTo(topContentView).offset(ViewTopPadding*2);
        make.width.equalTo(topContentView).multipliedBy(0.5);
        make.height.mas_equalTo(20);
    }];
    //添加数据
    //[self setUpThridData];
    
}
//加载数据
-(void)setUpThridData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    //查看是否有值
    NSString *userCode=login.usercode;
    if (self.otherUserCode!=nil) {
        userCode=self.otherUserCode;
    }
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetLatestRecord*%@",userCode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //获取最后一个试图
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //清空数组
        [self.arrayData removeAllObjects];
        //清楚页面元素
        for (UIView *view in self.topContentView.subviews) {
            if ([view isKindOfClass:[SunDataBloodView class]]) {
                [view removeFromSuperview];
            }else if([view isKindOfClass:[SunDataSugarView class]]) {
                [view removeFromSuperview];
            }
        }
        self.arrayData=[SunThirdData mj_objectArrayWithKeyValuesArray:json];
        int index=0;
        for(SunThirdData *data in self.arrayData)
        {
            UIView *subView=[self.topContentView.subviews lastObject];
            
            if ([data.TYPE isEqualToString:@"血压"]) {
                
                //分割字符串
                NSArray *shuArray = [data.VALUESNUM componentsSeparatedByString:@"/"];
                //添加数据
                SunDataBloodView *bloodView=[[SunDataBloodView alloc]init];
                NSString *strImgName=[NSString stringWithFormat:@"blood_pressure_%@",data.RESULT];
                //设置代理
                bloodView.delegate=self;
                bloodView.imgView.image=[UIImage imageNamed:strImgName];
                bloodView.higLab.text=[shuArray objectAtIndex:0];
                bloodView.lowLab.text=[shuArray objectAtIndex:1];
                bloodView.rateLab.text=[shuArray objectAtIndex:2];
                bloodView.timeLab.text=data.STARTTIME;
                bloodView.soundButton.tag=index;
                [self.topContentView addSubview:bloodView];
                [bloodView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(subView.mas_bottom).offset(ViewTopPadding);
                    make.width.equalTo(self.topContentView);
                    make.height.mas_equalTo(65);
                    make.left.equalTo(self.topContentView);
                }];
            }else{
                //血糖
                SunDataSugarView *sugarView=[[SunDataSugarView alloc]init];
                sugarView.delegate=self;
                CGFloat sugarNum=[data.VALUESNUM floatValue];
                sugarNum=sugarNum/18;
                sugarView.higLab.text=[NSString stringWithFormat:@"%.1f",sugarNum];
                sugarView.timeLab.text=[NSString stringWithFormat:@"%@",data.STARTTIME];;
                sugarView.sTimeLab.text=data.LX;
                sugarView.soundButton.tag=index;
                NSString *strImgName=[NSString stringWithFormat:@"xuetang_%@",data.RESULT];
                sugarView.imgView.image=[UIImage imageNamed:strImgName];
                [self.topContentView addSubview:sugarView];
                [sugarView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(subView.mas_bottom).offset(ViewTopPadding);
                    make.width.equalTo(self.topContentView);
                    make.height.mas_equalTo(65);
                    make.left.equalTo(self.topContentView);
                }];
            }
            index++;
        }//end for
        //获取最后一个试图
        UIView *subViewCount=[self.topContentView.subviews lastObject];
        //容器布局
        [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentScrollView);
            make.left.equalTo(self.contentScrollView);
            make.width.equalTo(self.contentScrollView);
            make.bottom.equalTo(subViewCount.mas_bottom).offset(ViewTopPadding);
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
-(void)bottomView
{
    UITapGestureRecognizer *bloodTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bloodTap)];
    SunDataCategoryView *view=[SunDataCategoryView viewFromNib];
    [view addGestureRecognizer:bloodTap];
    view.delegate=self;
    view.firstLab.text=@"血压管理";
    view.secondLab.text=@"开启科学管理方法";
    view.leftImgView.image=[UIImage imageNamed:@"blood"];
    [self.contentScrollView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContentView.mas_bottom).offset(ViewTopPadding);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.mas_equalTo(ViewHeight);
    }];
    
    UITapGestureRecognizer *sugarTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sugarTap)];
    SunDataCategoryView *sugarView=[SunDataCategoryView viewFromNib];
    [sugarView addGestureRecognizer:sugarTap];
    sugarView.delegate=self;
    sugarView.firstLab.text=@"血糖管理";
    sugarView.secondLab.text=@"开启科学管理方法";
    [self.contentScrollView addSubview:sugarView];
    [sugarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_bottom).offset(ViewTopPadding);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.mas_equalTo(ViewHeight);
    }];
    //天气应用
    UIView *weatherView=[[UIView alloc]init];
    //weatherView.backgroundColor=[UIColor redColor];
    [self.contentScrollView addSubview:weatherView];
    [weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sugarView.mas_bottom).offset(ViewTopPadding);
        make.left.equalTo(self.contentScrollView);
        make.width.equalTo(self.contentScrollView);
        make.height.mas_equalTo(ViewHeight);
    }];
    UIView *weatherCutView=[[UIView alloc]init];
    weatherCutView.backgroundColor=MrColor(194, 194, 194);
    [self.contentScrollView addSubview:weatherCutView];
    //获取上面试图分割线X值
    CGFloat x=sugarView.firstLab.frame.origin.x;
    [weatherCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weatherView.mas_bottom);
        make.left.equalTo(self.contentScrollView).offset(x);
        //make.left.equalTo(self.contentScrollView.mas_left).offset(-26);
        make.width.equalTo(self.contentScrollView).offset(-x);
        make.height.mas_equalTo(1);
    }];
    //天气
    UIImageView *weatherImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wheater-new"]];
    [weatherView addSubview:weatherImg];
    CGFloat wImg=sugarView.leftImgView.frame.size.width;
    CGFloat xImg=sugarView.leftImgView.frame.origin.x;
    [weatherImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(wImg);
        make.width.equalTo(weatherImg.mas_height);
        make.centerY.equalTo(weatherView);
        make.left.equalTo(weatherView).offset(xImg);
    }];
    
    
    UILabel *labName=[[UILabel alloc]init];
    labName.text=@"天气信息";
    labName.font=sugarView.firstLab.font;
    labName.textColor=sugarView.firstLab.textColor;
    [weatherView addSubview:labName];
    CGFloat xLab=sugarView.firstLab.frame.origin.x;
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weatherView);
        make.height.equalTo(weatherView).multipliedBy(0.5);
        make.left.equalTo(weatherView).offset(xLab);
        make.width.equalTo(weatherView);
    }];
    //天气展示
    UILabel *labWeather=[[UILabel alloc]init];
    labWeather.text=@"天气暂无";
    labWeather.font=kFont(sugarView.firstLab.font.pointSize-2);
    labWeather.textColor=sugarView.firstLab.textColor;
    [weatherView addSubview:labWeather];
    self.labWeather=labWeather;
    [labWeather mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labName.mas_bottom);
        make.height.equalTo(weatherView).multipliedBy(0.5);
        make.left.equalTo(labName);
        make.width.equalTo(weatherView);
    }];
}

-(void)bloodTap
{
        SunBloodViewController *blood=  [[SunBloodViewController alloc]init];
        blood.otherUserCode=self.otherUserCode;
        blood.otherUserName=self.otherUserName;
        [self.navigationController pushViewController:blood animated:YES];
    
}

-(void)sugarTap
{
    SunSugarViewController *sugar=[[SunSugarViewController alloc]init];
    sugar.otherUserCode=self.otherUserCode;
    sugar.otherUserName=self.otherUserName;
    [self.navigationController pushViewController:sugar animated:YES];
}
//获取地理坐标
-(void)setUpLocation
{
   CLLocationManager *locationManager=[[CLLocationManager alloc] init];
    locationManager.delegate=self;
    // 设置定位精度
    // kCLLocationAccuracyNearestTenMeters:精度10米
    // kCLLocationAccuracyHundredMeters:精度100 米
    // kCLLocationAccuracyKilometer:精度1000 米
    // kCLLocationAccuracyThreeKilometers:精度3000米
    // kCLLocationAccuracyBest:设备使用电池供电时候最高的精度
    // kCLLocationAccuracyBestForNavigation:导航情况下最高精度，一般要有外接电源时才能使用
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // distanceFilter是距离过滤器，为了减少对定位装置的轮询次数，位置的改变不会每次都去通知委托，而是在移动了足够的距离时才通知委托程序
    // 它的单位是米，这里设置为至少移动1000再通知委托处理更新;
    locationManager.distanceFilter = 1000.0f; // 如果设为kCLDistanceFilterNone，则每秒更新一次;
    self.locationManager=locationManager;
    if (iOSVersion>8.0) {
        //设置定位权限 仅ios8有意义
        [self.locationManager requestWhenInUseAuthorization];// 前台定位
        
        //  [locationManager requestAlwaysAuthorization];// 前后台同时定位
    }
    if ([CLLocationManager locationServicesEnabled]) {
        // 启动位置更新
        // 开启位置更新需要与服务器进行轮询所以会比较耗电，在不需要时用stopUpdatingLocation方法关闭;
        [self.locationManager startUpdatingLocation];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"请打开定位功能"];
    }
}
#pragma mark --刷新数据
-(void)loadData
{
    [self setUpThridData];
    [self.header endRefreshing];
}
#pragma mark --播放血压代理方法
-(void)bloodViewPlaySound:(SunDataBloodView *)blood
{
    //拼接朗读内容
    int index=(int)blood.soundButton.tag;
    SunThirdData *third=[self.arrayData objectAtIndex:index];
    NSString *str=[NSString stringWithFormat:@"您最新的检测结果为%@收缩压%@毫米汞柱 舒张压%@毫米汞柱心率%@次每分钟",third.RESULT,blood.higLab.text,blood.lowLab.text,blood.rateLab.text];
    [SunSpeedVoice speedVoice:str];
}
#pragma mark --播放血糖代理方法
-(void)sugarViewPlaySound:(SunDataSugarView *)sugar
{
    int index=(int)sugar.soundButton.tag;
    SunThirdData *third=[self.arrayData objectAtIndex:index];
    NSString *str=[NSString stringWithFormat:@"您最新的检测结果为%@%@ 血糖值%@毫摩尔每升",third.RESULT,sugar.sTimeLab.text,sugar.higLab.text];
     [SunSpeedVoice speedVoice:str];
}
#pragma mark --坐标改变时触发
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations{
    
     CLLocation *loc = [locations firstObject];
    AFHTTPSessionManager *afManager=[AFHTTPSessionManager manager];
    NSString *url=@"https://api.thinkpage.cn/v3/weather/now.json";
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"key"]=@"usvl3y6fgvxzz2wx";
    dic[@"location"]=[NSString stringWithFormat:@"%f:%f",loc.coordinate.latitude,loc.coordinate.longitude];
    dic[@"language"]=@"zh-Hans";
    dic[@"unit"]=@"c";
    [afManager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        NSData *data=[NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray *array=dic[@"results"];
        NSArray *array1=[SunWeatherModel mj_objectArrayWithKeyValuesArray:array];
        for (NSObject *obj in array1)
        {
            SunWeatherModel *model=(SunWeatherModel *)obj;
            self.labWeather.text=[NSString stringWithFormat:@"%@,  %@,  %@℃ (今日)",model.location[@"name"],model.now[@"text"],model.now[@"temperature"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [SVProgressHUD showErrorWithStatus:@"加载天气失败"];
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    }];
    // 停止位置更新
    [manager stopUpdatingLocation];
}
//定位失败时
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    [SVProgressHUD showErrorWithStatus:@"定位信息错误"];
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
}
#pragma mark --类型跳转
-(void)sunDataCategory:(SunDataCategoryView *)sun{
    //血压跳转
    if ([sun.firstLab.text isEqualToString:@"血压管理"]) {
        SunBloodViewController *blood=  [[SunBloodViewController alloc]init];
        blood.otherUserCode=self.otherUserCode;
        blood.otherUserName=self.otherUserName;
        [self.navigationController pushViewController:blood animated:YES];
    }else if([sun.firstLab.text isEqualToString:@"血糖管理"])
    {
        SunSugarViewController *sugar=[[SunSugarViewController alloc]init];
        sugar.otherUserCode=self.otherUserCode;
        sugar.otherUserName=self.otherUserName;
        [self.navigationController pushViewController:sugar animated:YES];
    }
}
@end
