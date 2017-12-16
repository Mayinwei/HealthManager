//
//  SunInsertSugarDataViewController.m
//  Demo
//
//  Created by 李金星 on 2017/1/5.
//  Copyright © 2017年 天津市善医科技发展有限公司. All rights reserved.
//

#import "SunInsertSugarDataViewController.h"
#import "Chameleon.h"
#import "LXMRulerView.h"
#import "DLRadioButton.h"
#import "MrDatePicker.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"

@interface SunInsertSugarDataViewController ()<MrDatePickerDelegate>

@property(nonatomic,strong)UIView *topView;
//时间
@property(nonatomic,strong)UILabel *timeLab;
//日期
@property(nonatomic,strong)UILabel *dateLab;
//尺子选择数值
@property(nonatomic,strong)UILabel *labNum;
//保存触发的文本框
@property(nonatomic,assign)int flagLab;
//点选按钮
@property(nonatomic,strong)DLRadioButton *zaocanqian;
@end

#define fontSize 13
#define LefPadding 17
@implementation SunInsertSugarDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"血糖录入";
    self.view.backgroundColor=MrColor(230, 230, 230);
    
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:(UIBarButtonItemStylePlain) target:self action:@selector(saveClick)];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    rightitem.width=5;
    [rightitem setTitleTextAttributes:dic forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightitem;
    
    //添加顶部
    [self setUpTop];
    //添加底部
    [self setUpBottom];
}

//添加顶部
-(void)setUpTop
{
    UIView *topView=[[UIView alloc]init];
    self.topView=topView;
    topView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(170);
    }];
    
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=@"血糖值";
    labTitle.font=[UIFont systemFontOfSize:13];
    [topView addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(LefPadding);
        make.right.equalTo(topView);
        make.top.equalTo(topView).offset(10);
        make.height.mas_equalTo(fontSize+2);
    }];
    
    //添加尺子
    UILabel *labNum = [[UILabel alloc] init];
    self.labNum=labNum;
    labNum.textAlignment = NSTextAlignmentCenter;
    labNum.font=[UIFont systemFontOfSize:30];
    [topView addSubview:labNum];
    
    
    
    LXMRulerView *oneRulerView = [[LXMRulerView alloc] init];
    oneRulerView.markViewColor=MrColor(33, 135, 244);
    oneRulerView.minValue=0;
    oneRulerView.maxValue=33.3;
    [oneRulerView setValueChangeCallback:^(CGFloat currentValue) {
        labNum.text = [NSString stringWithFormat:@"%.01f", currentValue];
    }];
    oneRulerView.accuracy = 0.1;
    [oneRulerView reloadData];
    [topView addSubview:oneRulerView];
    [oneRulerView updateCurrentValue:30];
    
    [oneRulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView).offset(20);
        make.left.equalTo(topView);
        make.right.equalTo(topView);
        make.height.mas_equalTo(70);
    }];
    
    [labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(oneRulerView.mas_top).offset(-8);
        make.centerX.equalTo(topView);
        make.height.mas_equalTo(30);
        make.width.equalTo(topView);
    }];
    
    
}

//底部控件
-(void)setUpBottom
{
    UIView *bottomView=[[UIView alloc]init];
    bottomView.backgroundColor=[UIColor whiteColor ];
    [self.view addSubview:bottomView];
    
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=@"测量时段";
    labTitle.font=kFont(13);
    [bottomView addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(LefPadding);
        make.right.equalTo(bottomView);
        make.top.equalTo(bottomView).offset(10);
        make.height.mas_equalTo(fontSize+2);
    }];
    
    
    DLRadioButton *zaocanqian = [[DLRadioButton alloc] init];
    self.zaocanqian=zaocanqian;
    [zaocanqian setTitle:@"空腹" forState:UIControlStateNormal];
    [zaocanqian setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    zaocanqian.indicatorColor =MrColor(33, 135, 244);
    zaocanqian.titleLabel.font=kFont(15);
    zaocanqian.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    zaocanqian.selected=YES;
    
    
    NSMutableArray *array=[NSMutableArray array];
    DLRadioButton *zaocanhou=[self createRadioButtom:@"早餐后"];
    DLRadioButton *wucanqian=[self createRadioButtom:@"午餐前"];
    DLRadioButton *wucanhou=[self createRadioButtom:@"午餐前"];
    DLRadioButton *wancanqian=[self createRadioButtom:@"晚餐前"];
    DLRadioButton *wancanhou=[self createRadioButtom:@"晚餐后"];
    DLRadioButton *shuiqian=[self createRadioButtom:@"睡前"];
    DLRadioButton *lingcheng=[self createRadioButtom:@"凌晨"];
    [array addObject:zaocanhou];
    [array addObject:wucanqian];
    [array addObject:wucanhou];
    [array addObject:wancanqian];
    [array addObject:wancanhou];
    [array addObject:shuiqian];
    [array addObject:lingcheng];
    zaocanqian.otherButtons=array;
    //添加到视图中
    [bottomView addSubview:zaocanqian];
    [bottomView addSubview:zaocanhou];
    [bottomView addSubview:wucanqian];
    [bottomView addSubview:wucanhou];
    [bottomView addSubview:wancanqian];
    [bottomView addSubview:wancanhou];
    [bottomView addSubview:shuiqian];
    [bottomView addSubview:lingcheng];
    //布局
    /**
     *  axisType         轴线方向
     *  fixedSpacing     间隔大小
     *  fixedItemLength  每个控件的固定长度/宽度
     *  leadSpacing      头部间隔
     *  tailSpacing      尾部间隔
     *
     */
    
    CGFloat Height=20;
    CGFloat radioTop=8;
    CGFloat FixedItemLength=90;
    //第一排
    [@[zaocanqian,zaocanhou,wucanqian] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:FixedItemLength leadSpacing:18 tailSpacing:0];
    [@[zaocanqian,zaocanhou,wucanqian] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(Height);
        make.top.equalTo(labTitle.mas_bottom).offset(15);
    }];
    //第二排
    [@[wucanhou,wancanqian,wancanhou] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:FixedItemLength leadSpacing:18 tailSpacing:0];
    [@[wucanhou,wancanqian,wancanhou] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(Height);
        make.top.equalTo(zaocanqian.mas_bottom).offset(radioTop);
    }];
    //最后一排
    [shuiqian mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(zaocanqian);
        make.size.equalTo(zaocanqian);
        make.top.equalTo(wucanhou.mas_bottom).offset(radioTop);
    }];
    [lingcheng mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(zaocanhou);
        make.size.equalTo(zaocanqian);
        make.centerY.equalTo(shuiqian);
    }];
    
    //分割线
    UIView *cutView1=[[UIView alloc]init];
    cutView1.backgroundColor=MrColor(230, 230, 230);
    [bottomView addSubview:cutView1];
    [cutView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shuiqian.mas_bottom).offset(20);
        make.left.equalTo(bottomView).offset(LefPadding);
        make.right.equalTo(bottomView).offset(-LefPadding);
        make.height.mas_equalTo(1);
    }];
    
    //时间格式化
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *date=[dateFormatter stringFromDate:[NSDate date]];
    
    CGFloat topPadding=15;
    //日期标题
    UILabel *dateTitleLab=[[UILabel alloc]init];
    dateTitleLab.text=@"测量日期";
    dateTitleLab.font=labTitle.font;
    [bottomView addSubview:dateTitleLab];
    [dateTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutView1.mas_bottom).offset(topPadding);
        make.left.equalTo(cutView1);
    }];
    
    UILabel *dateLab=[[UILabel alloc]init];
    self.dateLab=dateLab;
    dateLab.textColor=MrColor(180, 180, 180);
    dateLab.text=[date componentsSeparatedByString:@" "][0];
    dateLab.font=labTitle.font;
    //添加手势
    dateLab.userInteractionEnabled=YES;
    UITapGestureRecognizer *dateTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dateClick)];
    [dateLab addGestureRecognizer:dateTap];
    [bottomView addSubview:dateLab];
    
    [dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(dateTitleLab);
        make.left.equalTo(dateTitleLab.mas_right).offset(40);
    }];
    
    UIView *cutView2=[[UIView alloc]init];
    cutView2.backgroundColor=MrColor(230, 230, 230);
    [bottomView addSubview:cutView2];
    [cutView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dateTitleLab.mas_bottom).offset(topPadding);
        make.centerX.equalTo(cutView1);
        make.size.equalTo(cutView1);
    }];
    
    //时间标题
    UILabel *timeTitleLab=[[UILabel alloc]init];
    timeTitleLab.text=@"测量时间";
    timeTitleLab.font=labTitle.font;
    [bottomView addSubview:timeTitleLab];
    [timeTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutView2.mas_bottom).offset(topPadding);
        make.left.equalTo(cutView1);
    }];
    
    UILabel *timeLab=[[UILabel alloc]init];
    self.timeLab=timeLab;
    timeLab.textColor=dateLab.textColor;
    timeLab.text=[date componentsSeparatedByString:@" "][1];
    timeLab.font=labTitle.font;
    [bottomView addSubview:timeLab];
    //添加手势
    timeLab.userInteractionEnabled=YES;
    UITapGestureRecognizer *timeTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(timeClick)];
    [timeLab addGestureRecognizer:timeTap];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(timeTitleLab);
        make.left.equalTo(dateLab);
    }];
    
    //整体约束
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom).offset(8);
        make.bottom.equalTo(timeLab.mas_bottom).offset(topPadding);
    }];
}

//日期选择
-(void)dateClick
{
    self.flagLab=1;
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.delegate=self;
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-66);
    [self.view addSubview:datePicker];
}
//时间选择
-(void)timeClick
{
    self.flagLab=0;
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.pickerModel=@"UIDatePickerModeTime";
    datePicker.delegate=self;
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-66);
    [self.view addSubview:datePicker];
}

#pragma  mark --日期选择空间协议
-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    if(self.flagLab==1)
    {
        self.dateLab.text=[time componentsSeparatedByString:@" "][0];
    }else if(self.flagLab==0){
        //时间
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *data=[dateFormatter dateFromString:time];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dataString=[dateFormatter stringFromDate:data];
        self.timeLab.text=[dataString componentsSeparatedByString:@" "][1];
    }
}
//创建单选按钮
-(DLRadioButton *)createRadioButtom:(NSString *)title
{
    // customize this button
    DLRadioButton *radioButton = [[DLRadioButton alloc] init];
    radioButton.titleLabel.font=kFont(15);
    [radioButton setTitle:title forState:UIControlStateNormal];
    [radioButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    radioButton.indicatorColor = MrColor(33, 135, 244);
    //radioButton.iconSize=10;
    radioButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    return radioButton;
}

-(void)saveClick
{
    DLRadioButton *btn=self.zaocanqian.selectedButton;
    NSString *time=[NSString stringWithFormat:@"%@ %@:00.000",self.dateLab.text,self.timeLab.text];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"insertXT*%@*%@*%@*%@",login.usercode,self.labNum.text,btn.titleLabel.text,time];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
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
        [SVProgressHUD showErrorWithStatus:@"录入数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}


@end
