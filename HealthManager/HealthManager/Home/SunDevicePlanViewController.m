
//
//  SunDevicePlanViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunDevicePlanViewController.h"
#import "PKYStepper.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MrDatePicker.h"
#import "SunDeviceDetailModel.h"
#import "SunDevicePlanModel.h"

@interface SunDevicePlanViewController ()<MrDatePickerDelegate>
@property(nonatomic,strong)PKYStepper *setpper;
@property(nonatomic,strong)UIView *nameView;
@property(nonatomic,strong)UILabel *labXu;
@property(nonatomic,strong)UILabel *labChang;
@property(nonatomic,strong)UILabel *labZiType;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labStartTime;
@property(nonatomic,strong)UILabel *labEndTime;
//开关
@property(nonatomic,strong)UISwitch *switchPlan;
@property(nonatomic,strong)NSMutableArray *arrayData;
//
@property(nonatomic,strong)UIView *bottomView;
@property(nonatomic,strong)UILabel *timeLable;
@end

//行高
#define HeightView 40
@implementation SunDevicePlanViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"设备计划";
    self.view.backgroundColor=MrColor(240, 240, 240);
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"保存" style: UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //添加顶部
    [self setUpTop];
    
    //添加底部
    [self setUpBottom];
    
    //加载数据
    [self loadData];
}

-(void)setUpTop
{
    //序列号
    UIView *xuView=[self getTypeWitLeft:@"设备序列号" right:@""];
    [self.view addSubview:xuView];
    self.labXu=xuView.subviews[1];
    [xuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(self.view);
    }];
    //厂家
    UIView *changView=[self getTypeWitLeft:@"设备设备厂家" right:@""];
    self.labChang=changView.subviews[1];
    [self.view addSubview:changView];
    [changView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(xuView.mas_height);
        make.top.equalTo(xuView.mas_bottom);
    }];
    //设备子类别
    UIView *ziView=[self getTypeWitLeft:@"设备子类别" right:@""];
    self.labZiType=ziView.subviews[1];
    [self.view addSubview:ziView];
    [ziView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(xuView.mas_height);
        make.top.equalTo(changView.mas_bottom);
    }];
    //设备名称
    UIView *nameView=[self getTypeWitLeft:@"设备名称" right:@""];
    self.labName=nameView.subviews[1];
    self.nameView=nameView;
    [self.view addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(ziView.mas_height);
        make.top.equalTo(ziView.mas_bottom);
    }];

}

-(void)setUpBottom
{
    UIView *switchView=[self getControlTypeWitLeft:@"检测计划" isSwitch:YES];
    [self.view addSubview:switchView];
    [switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(self.nameView.mas_bottom).offset(30);
    }];
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(180, 180, 180);
    [self.view addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(switchView.mas_bottom);
        make.height.mas_equalTo(1);
        
    }];
    
    UIView *bottomView=[[UIView alloc]init];
    self.bottomView=bottomView;
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    //获取时间
    //时间
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dataString=[dateFormatter stringFromDate:[NSDate date]];
    NSString *time=[dataString componentsSeparatedByString:@" "][1];
    //计划开始
    UIView *startView=[self getTypeWitLeft:@"计划开始时间" right:time];
    self.labStartTime=startView.subviews[1];
    UITapGestureRecognizer *tapStart=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startClick)];
    self.labStartTime.userInteractionEnabled=YES;
    [self.labStartTime addGestureRecognizer:tapStart];
    
    [bottomView addSubview:startView];
    [startView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView);
        make.right.equalTo(bottomView);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(bottomView);
    }];
    //计划结束时间
    UIView *endView=[self getTypeWitLeft:@"计划结束时间" right:time];
    self.labEndTime=endView.subviews[1];
    UITapGestureRecognizer *tapEnd=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endClick)];
    self.labEndTime.userInteractionEnabled=YES;
    [self.labEndTime addGestureRecognizer:tapEnd];
    [bottomView addSubview:endView];
    [endView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView);
        make.right.equalTo(bottomView);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(startView.mas_bottom);
    }];
    //计划执行频率
    UIView *repeatView=[self getControlTypeWitLeft:@"计划执行频率" isSwitch:NO];
    [bottomView addSubview:repeatView];
    [repeatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomView);
        make.left.equalTo(bottomView);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(endView.mas_bottom);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(switchView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(repeatView);
    }];

}
-(void)endClick
{
    self.timeLable=self.labEndTime;
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.pickerModel=@"UIDatePickerModeTime";
    datePicker.delegate=self;
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-66);
    [self.view addSubview:datePicker];
}
-(void)startClick
{
    self.timeLable=self.labStartTime;
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.pickerModel=@"UIDatePickerModeTime";
    datePicker.delegate=self;
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-66);
    [self.view addSubview:datePicker];
}

#pragma makr --时间选择控件
-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    //时间
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *data=[dateFormatter dateFromString:time];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dataString=[dateFormatter stringFromDate:data];
    self.timeLable.text=[dataString componentsSeparatedByString:@" "][1];
}

-(UIView *)getTypeWitLeft:(NSString *)left right:(NSString *)right
{
    //添加内容
    UIView *contentView=[[UIView alloc]init];
    contentView.backgroundColor=[UIColor whiteColor];
    //左右间距
    CGFloat leftPadding=16;
    UILabel *titleLab=[[UILabel alloc]init];
    titleLab.text=left;
    titleLab.font=kFont(15);
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.top.equalTo(contentView);
        make.centerY.equalTo(contentView);
    }];
    
    
    UILabel *rightLab=[[UILabel alloc]init];
    [contentView addSubview:rightLab];
    rightLab.font=titleLab.font;
    rightLab.text=right;
    [rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
    }];
    
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [contentView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.right.equalTo(contentView).offset(-leftPadding);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
        
    }];
    
    
    return contentView;
}

//获取控件类型
-(UIView *)getControlTypeWitLeft:(NSString *)left isSwitch:(BOOL)isSwitch
{
    //添加内容
    UIView *contentView=[[UIView alloc]init];
    contentView.backgroundColor=[UIColor whiteColor];
    //左右间距
    CGFloat leftPadding=16;
    UILabel *titleLab=[[UILabel alloc]init];
    titleLab.text=left;
    titleLab.font=kFont(15);
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.top.equalTo(contentView);
        make.centerY.equalTo(contentView);
    }];
    
    
    if (isSwitch) {
        //开关
        UISwitch *sw=[[UISwitch alloc]init];
        self.switchPlan=sw;
        [sw addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:sw];
        [sw mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(contentView).offset(-leftPadding);
            make.centerY.equalTo(contentView);
        }];
    }else{
        UILabel *lab=[[UILabel alloc]init];
        lab.text=@"分钟";
        [contentView addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(contentView).offset(-leftPadding);
            make.centerY.equalTo(contentView);
        }];
        
        //记不起
        PKYStepper *setpper=[[PKYStepper alloc]init];
        self.setpper=setpper;
        setpper.value=10;
        setpper.minimum=1;
        setpper.buttonWidth=30;
       // UIColor *color=MrColor(39, 228, 246);
        setpper.valueChangedCallback=^(PKYStepper *stepper, float count) {
            stepper.countLabel.text = [NSString stringWithFormat:@"%@", @(count)];
        };
//        [setpper setLabelTextColor:color];
//        [setpper setButtonTextColor:color forState:UIControlStateNormal];
//        [setpper setBorderColor:color];
        [setpper setup];
        [contentView addSubview:setpper];
        [setpper mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lab.mas_left).offset(-8);
            make.top.equalTo(contentView).offset(5);
            make.bottom.equalTo(contentView).offset(-5);
            make.width.mas_equalTo(110);
        }];
    }
    
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [contentView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.right.equalTo(contentView).offset(-leftPadding);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
        
    }];
    
    
    return contentView;
}

//开关
-(void)switchClick:(UISwitch *)switchC
{
    self.bottomView.hidden=!switchC.on;
}

//保存检测计划
-(void)save
{
    if (self.switchPlan.on) {
        [self update];
    }else{
        [self delete];
    }
}

//更新计划
-(void)update
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"InsertDeviceMonitoring*%@*%@*%@*%@*%@*有",self.EquCode,self.labEndTime.text,self.labStartTime.text,self.setpper.countLabel.text,login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//删除计划
-(void)delete
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"DelDeviceMonitoring*%@*%@",self.EquCode,login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//加载数据
-(void)loadData
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetDeviceInfo*%@",self.EquCode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        SunDeviceDetailModel *detail=[SunDeviceDetailModel mj_objectWithKeyValues:json];
        self.labName.text=detail.EQUNAME;
        self.labXu.text=detail.EQUCODE;
        self.labZiType.text=detail.EQUSUBTYPE;
        self.labChang.text=detail.COMPANYNO;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    //查询是否有无检测计划
    
    NSMutableDictionary *dicPlan=[NSMutableDictionary dictionary];
    dicPlan[@"access_token"]=login.access_token;
    dicPlan[@"parma"]=[NSString stringWithFormat:@"GetDeviceMonitoring*%@",self.EquCode];
    [manager POST:MyURL parameters:dicPlan progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        SunDevicePlanModel *plan=[SunDevicePlanModel mj_objectWithKeyValues:json];
        if (plan!=nil) {
            if ([plan.HASPLAN isEqualToString:@"有"]) {
                self.labStartTime.text=plan.PLANSTARTTIME;
                self.labEndTime.text=plan.PLANENDTIME;
                self.labZiType.text=plan.PLANENDTIME;
                self.setpper.countLabel.text=plan.PLANFREQUENCE;
                self.switchPlan.on=YES;
                self.bottomView.hidden=NO;
            }else{
                self.switchPlan.on=NO;
                self.bottomView.hidden=YES;
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    
}
@end
