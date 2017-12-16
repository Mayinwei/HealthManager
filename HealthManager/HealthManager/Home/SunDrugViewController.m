//
//  SunDrugViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/7.
//  Copyright © 2017年 马银伟. All rights reserved.
//  用药管理

#import "SunDrugViewController.h"
#import "Chameleon.h"
#import "SunDrugModel.h"
#import "SunDrugView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"
#import "MJRefresh.h"
#import "SunDrugPlanTableViewController.h"
#import "SunDrugRecordViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface SunDrugViewController ()<SunDrugViewDelegate>
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@property(nonatomic,strong)UIScrollView *scrllView;
@end

@implementation SunDrugViewController
-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"用药管理";
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    //设置顶部布局
    [self setUpTop];
    //今日用药
    [self SetUpDrugInfo];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //请求数据
    [self loadDrugInfo];
}

-(void)setUpTop
{
    //用药计划
    UIView *planView=[self getTopViewWithTitle:@"用药计划" imgName:@"notepad"];
    [self.view addSubview:planView];
    [planView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    //添加手势
    UITapGestureRecognizer *panPlan=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(planClick)];
    [planView addGestureRecognizer:panPlan];
    //分割线
    UIView *middleCutView=[[UIView alloc]init];
    [self.view addSubview:middleCutView];
    middleCutView.backgroundColor=MrColor(200, 200, 200);
    [middleCutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(1);
        make.height.equalTo(planView);
        make.top.equalTo(self.view);
    }];
    
    
    //用药记录
    UIView *recordView=[self getTopViewWithTitle:@"用药记录" imgName:@"notes"];
    [self.view addSubview:recordView];
    [recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view).multipliedBy(0.5);
        make.right.equalTo(self.view);
        make.height.equalTo(planView);
    }];
    //添加手势
    UITapGestureRecognizer *panRecord=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(recordClick)];
    [recordView addGestureRecognizer:panRecord];
}

//今日用药
-(void)SetUpDrugInfo
{
    UILabel *lab=[[UILabel alloc]init];
    lab.text=@"今天用药提醒";
    lab.font=kFont(15);
    lab.frame=CGRectMake(15, 100, SCREEN_WIDTH-15, 28);
    [self.view addSubview:lab];
    //添加刷新标题
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.header=header;
    UIScrollView *scrllView=[[UIScrollView alloc]init];
    scrllView.mj_header=header;
    self.scrllView=scrllView;
    scrllView.backgroundColor=[UIColor whiteColor];
    scrllView.frame=CGRectMake(0, 128, SCREEN_WIDTH, SCREEN_HEIGHT-128);
    [self.view addSubview:scrllView];
    
    
}
//请求数据
-(void)loadDrugInfo
{
    
    //清除所有本地通知
    if(iOSVersion>=10.0){
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }else{
        //清除本地通知
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    CGFloat leftPadding=10;
    CGFloat drugH=100;
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedRemind*%@",login.usercode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self.arrayData removeAllObjects];
        //清楚页面元素
        for (UIView *view in self.scrllView.subviews) {
            if ([view isKindOfClass:[SunDrugView class]]) {
                [view removeFromSuperview];
            }
        }
        self.arrayData=[SunDrugModel mj_objectArrayWithKeyValuesArray:json];
        int index=0;
        for(SunDrugModel *data in self.arrayData)
        {
            UIView *subView=[self.scrllView.subviews lastObject];
            SunDrugView *sunDrView=[[SunDrugView alloc]init];
            //设置随机颜色
            //sunDrView.bagColor=[UIColor randomFlatColor];
            sunDrView.delegate=self;
            sunDrView.name.text=data.MedName;
            sunDrView.num.text=[NSString stringWithFormat:@"%@/%@",data.Num,data.Unit];
            sunDrView.ways.text=data.Ways;
            sunDrView.time.text=data.PlanTime;
            sunDrView.timeName.text=@"时间:";
            sunDrView.fuBtn.tag=index;
            sunDrView.againBtn.tag=index;
            [self.scrllView addSubview:sunDrView];
            //设置本地推送
            [self addLocationInfoTime:data.PlanTime name:data.MedName index:index];
            [sunDrView mas_makeConstraints:^(MASConstraintMaker *make) {
                if([subView isKindOfClass:[SunDrugView class]])
                {
                    make.top.equalTo(subView.mas_bottom).offset(leftPadding);
                }else{
                    make.top.equalTo(self.scrllView).offset(leftPadding);
                }
                
                make.left.equalTo(self.scrllView).offset(leftPadding);
                make.width.equalTo(self.scrllView).offset(-leftPadding*2);
                make.height.mas_equalTo(drugH);
            }];
            index++;
        }
        //更新用药模块的高度
        int count=(int)[self.arrayData count];
        CGFloat contentHeight=count*(leftPadding+drugH+leftPadding);
        if (contentHeight<=self.scrllView.frame.size.height) {
            contentHeight=self.scrllView.frame.size.height;
        }
        self.scrllView.contentSize=CGSizeMake(SCREEN_WIDTH, contentHeight+leftPadding);
        
        if (self.arrayData.count==0) {
            //暂无用药提醒
            UILabel *labNoDrug=[[UILabel alloc]init];
            labNoDrug.textAlignment=NSTextAlignmentCenter;
            labNoDrug.font=kFont(15);
            labNoDrug.textColor=MrColor(153, 153, 153);
            labNoDrug.text=@"暂无用药";
            [self.scrllView addSubview:labNoDrug];
            labNoDrug.frame=CGRectMake(0, 10, SCREEN_WIDTH, 30);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
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

//添加本地推动用药提醒
-(void)addLocationInfoTime:(NSString *)time name:(NSString *)name index:(int)index
{
    //判断时间是否为空
    if ([time isEqualToString:@""]||time==nil) {
        return;
    }
//    NSDate *date=[[NSDate alloc]init];
//    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
//    dateFormatter.dateFormat=@"yyy-MM-dd";
//    NSDate *nowDate=[self getNowDateFromatAnDate:date];
//    NSString *shortDateStr=[dateFormatter stringFromDate:[NSDate date]];
//    dateFormatter.dateFormat=@"yyy-MM-dd HH-mm-ss";
//    //拼接时间
//    NSDate *activeDate=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",shortDateStr,time]];
//    NSDate *activeNorDate=[self getNowDateFromatAnDate:activeDate];
//    //秒为单位
//    NSTimeInterval timeInterval=[nowDate timeIntervalSinceDate:activeNorDate];
    
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
        //设置本地通知的触发时间（如果要立即触发，无需设置)特定时间
        location.fireDate=[calendar dateFromComponents:dateComponents];
        //循环通知的周期
        location.repeatInterval=kCFCalendarUnitWeekday;
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


#pragma mark --用药提醒协议
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
            [SVProgressHUD dismissWithDelay:2.0];
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
//用药计划
-(void)planClick
{
    [self.navigationController pushViewController:[[SunDrugPlanTableViewController alloc]init] animated:YES];
}
//用药记录
-(void)recordClick
{
    [self.navigationController pushViewController:[[SunDrugRecordViewController alloc]init] animated:YES];
}
//刷新数据
-(void)loadData
{
    [self loadDrugInfo];
    [self.header endRefreshing];
}
-(UIView *)getTopViewWithTitle:(NSString *)title imgName:(NSString *)imgName
{
    UIView *contView=[[UIView alloc]init];
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imgName]];
    [contView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contView).offset(14);
        make.centerX.equalTo(contView);
        make.width.mas_equalTo(40);
        make.height.equalTo(imgView.mas_width);
    }];
    //标题
    UILabel *lab=[[UILabel alloc]init];
    lab.font=kFont(15);    
    lab.text=title;
    lab.textAlignment=NSTextAlignmentCenter;
    [contView addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contView);
        make.top.equalTo(imgView.mas_bottom);
        make.bottom.equalTo(contView);
        make.left.equalTo(contView);
    }];
    //底部线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(200, 200, 200);
    [contView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contView);
        make.left.equalTo(contView);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(contView);
    }];
    return contView;
}
@end
