//
//  SunBloodDetailViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/3.
//  Copyright © 2017年 马银伟. All rights reserved.
//  血压详细数据

#import "SunBloodDetailViewController.h"
#import "Chameleon.h"
#import<QuartzCore/QuartzCore.h>
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"
#import "SunBloodDetailModel.h"
#import "SunBloodTableViewCell.h"
#import "SunDataBloodView.h"
#import "SunSpeedVoice.h"
#import "MrDatePicker.h"

@interface SunBloodDetailViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,SunDataBloodViewDelegate,MrDatePickerDelegate>
@property(nonatomic,strong)UIView *topView;
//下拉刷新
@property(nonatomic,strong)MJRefreshNormalHeader  *header;
//上拉刷新
@property(nonatomic,strong)MJRefreshBackNormalFooter *footer;
@property(nonatomic,strong) UITableView *tableView;
//数据集合
@property(nonatomic,strong)NSMutableArray  *arrayData;
@property(nonatomic,strong)UIDatePicker *datePicker;
//保存触发的文本框
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UITextField *textStart;
@property(nonatomic,strong)UITextField *textEnd;
//页码
@property(nonatomic,assign)int PageIndex;
@end

@implementation SunBloodDetailViewController

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
    self.view.backgroundColor=MrColor(242, 242, 242);
    if(self.otherUserName==nil){
        self.navigationItem.title=@"血压详情";
    }else{
        self.navigationItem.title=[NSString stringWithFormat:@"%@的血压详情",self.otherUserName];
    }
    //页码
    self.PageIndex=1;
    //添加顶部试图
    [self setUpTop];
    //添加table
    [self setUpBottom];
    //请求数据
    [self loadData];
    
}
//添加顶部试图
-(void)setUpTop
{
    UIView *topView=[[UIView alloc]init];
    topView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topView];
    self.topView=topView;
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    // 实例化NSDateFormatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    NSDate *oldtDate = [NSDate dateWithTimeIntervalSinceNow:-7*24*60*60];
    NSString *currentDateString = [formatter stringFromDate:currentDate];
    NSString *oldDateString = [formatter stringFromDate:oldtDate];
    
    
    UITextField *textStart=[[UITextField alloc]init];
    self.textStart=textStart;
    textStart.text=oldDateString;
    textStart.delegate=self;
    textStart.font=kFont(12);
    textStart.backgroundColor=MrColor(240, 240, 240);
    textStart.textColor=[UIColor flatBlueColor];
    textStart.textAlignment=NSTextAlignmentCenter;
    textStart.layer.cornerRadius=0.5;
    textStart.borderStyle=UITextBorderStyleRoundedRect;
    [topView addSubview:textStart];
    [textStart mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView);
        make.height.mas_equalTo(30);
    }];
    
    UITextField *textEnd=[[UITextField alloc]init];
    self.textEnd=textEnd;
    textEnd.text=currentDateString;
    textEnd.delegate=self;
    textEnd.font=textStart.font;
    textEnd.backgroundColor=textStart.backgroundColor;
    textEnd.textColor=textStart.textColor;
    textEnd.textAlignment=NSTextAlignmentCenter;
    textEnd.layer.cornerRadius=0.5;
    textEnd.borderStyle=UITextBorderStyleRoundedRect;
    [topView addSubview:textEnd];
    [textEnd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(textStart);
        make.size.equalTo(textStart);
    }];
    
    //查询按钮
    UIButton *btnSearch=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"common_btn-hightlight"] forState:UIControlStateHighlighted];
    [btnSearch setTitle:@"查询" forState:UIControlStateNormal];
    btnSearch.titleLabel.textColor=[UIColor flatWhiteColor];
    btnSearch.titleLabel.font=kFont(14);
    [btnSearch addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btnSearch];
    [btnSearch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(textEnd);
        make.height.equalTo(textEnd);
    }];
    CGFloat padd=SCREEN_WIDTH*0.06;
    [@[textStart,textEnd,btnSearch] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:padd tailSpacing:padd];
    
    
    //分短线
    UILabel *labCut=[[UILabel alloc]init];
    labCut.text=@"-";
    labCut.textColor=[UIColor flatGrayColor];
    labCut.textAlignment=NSTextAlignmentCenter;
    [topView addSubview:labCut];
    [labCut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textStart.mas_right);
        make.height.equalTo(topView);
        make.top.equalTo(topView);
        make.width.mas_equalTo(15);
    }];
}


//添加table
-(void)setUpBottom
{
    //下拉刷新
    MJRefreshNormalHeader  *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(topLoadData)];
    self.header=header;
    
    UITableView *tableView=[[UITableView alloc]init];
    self.tableView=tableView;
    self.tableView.mj_header=header;
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.backgroundColor=MrColor(240, 240, 240);
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(3);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
}


//请求数据
-(void)loadData
{
    NSString *oldDate=self.textStart.text;
    NSString *currentDate=self.textEnd.text;
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    
    SunLogin *login=[SunAccountTool getAccount];
    //查看是否有值
    NSString *userCode=login.usercode;
    if (self.otherUserCode!=nil) {
        userCode=self.otherUserCode;
    }
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetBP*%@*%@ 00:00:00.000,%@ 23:59:59.000*1*10*0",userCode,oldDate,currentDate];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self.arrayData removeAllObjects];
        self.arrayData=[SunBloodDetailModel mj_objectArrayWithKeyValuesArray:json];
        if(self.arrayData.count>0)
        {
            [self setUpControl];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"查询失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];

}
//上拉加载旧数据
-(void)loadOldData
{
    NSString *oldDate=self.textStart.text;
    NSString *currentDate=self.textEnd.text;
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    //查看是否有值
    NSString *userCode=login.usercode;
    if (self.otherUserCode!=nil) {
        userCode=self.otherUserCode;
    }
    dic[@"access_token"]=login.access_token;
    self.PageIndex++;
    dic[@"parma"]=[NSString stringWithFormat:@"GetBP*%@*%@ 00:00:00.000,%@ 23:59:59.000*%d*10*0",userCode,oldDate,currentDate,self.PageIndex];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        
        NSMutableArray *oldArray=[SunBloodDetailModel mj_objectArrayWithKeyValuesArray:json];
        [self.arrayData addObjectsFromArray:oldArray];
        if(oldArray.count>0){
            [self.tableView reloadData];
        }else{
            self.tableView.mj_footer=NULL;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"查询失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];

}


//加载刷新控件
-(void)setUpControl
{
    [self.tableView reloadData];
    //上拉加载
    MJRefreshBackNormalFooter *footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomLoadData)];
    self.footer=footer;
     self.tableView.mj_footer=footer;
}
//下拉刷新
-(void)topLoadData
{
    [self loadData];
    [self.header endRefreshing];
}
//上拉加载
-(void)bottomLoadData
{
    //加载旧数据
    [self loadOldData];
    [self.footer endRefreshing];
}
//查询
-(void)searchClick
{
    [self loadData];
}

//触发时间控件
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    datePicker.delegate=self;
    [self.view addSubview:datePicker];
    self.textField=textField;
    return NO;
}
#pragma mark --播放声音代理方法
-(void)bloodViewPlaySound:(SunDataBloodView *)blood
{
    //拼接朗读内容
    int index=(int)blood.soundButton.tag;
    SunBloodDetailModel *third=[self.arrayData objectAtIndex:index];
    NSString *str=[NSString stringWithFormat:@"您最新的检测结果为%@收缩压%@毫米汞柱 舒张压%@毫米汞柱心率%@次每分钟",third.RESULT,blood.higLab.text,blood.lowLab.text,blood.rateLab.text];
    [SunSpeedVoice speedVoice:str];
}

#pragma mark --时间选择空间协议
-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    self.textField.text=[[time componentsSeparatedByString:@" "] objectAtIndex:0];
}

#pragma make --tableView协议方法


//有多少组，默认是1组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//每组有多少行
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayData.count;
}

//  每行显示的数据
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunBloodTableViewCell *cell=[SunBloodTableViewCell cellWithTableView:tableView];
    SunDataBloodView *bloodView=(SunDataBloodView *)cell.blood;
    bloodView.delegate=self;
    bloodView.soundButton.tag=indexPath.row;
    cell.bloodDetail=self.arrayData[indexPath.row];
    return cell;
}
//设置行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  65;
}
@end
