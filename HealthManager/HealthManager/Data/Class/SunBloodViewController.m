//
//  SunBloodViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/26.
//  Copyright © 2016年 马银伟. All rights reserved.
//  血压详细情况

#import "SunBloodViewController.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunCutImageView.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunBlood.h"
#import "SunErrorModel.h"
#import "SunBloodDetailViewController.h"
#import "SunInsertBloodDataViewController.h"
#import "SunDeviceBindiewController.h"
#import "UIImageView+WebCache.h"
#import "PNChart.h"
#import "Chameleon.h"

@interface SunBloodViewController ()<PNChartDelegate>
@property(nonatomic,weak)UIScrollView *contentScrollView;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@property(nonatomic,weak)UIView *topView;
@property(nonatomic,weak)UIView *bottomView;
@property(nonatomic,weak)UISegmentedControl *seg;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,weak)UILabel *labResult;
@property(nonatomic,weak)UILabel *labTime;
@property(nonatomic,weak)UILabel *labHigLow;
@property(nonatomic,weak)UILabel *labRate;
@property(nonatomic,weak)UILabel *labHigUnit;
@property(nonatomic,weak)UILabel *labRateUnit;
@property(nonatomic,assign)int flag;
@property(nonatomic,weak) UIImageView *imgHead;

@property(nonatomic,weak)NSMutableArray *arrayPoint;
@property(nonatomic,weak)UIImageView *bagImgView;

@property(nonatomic,weak)UILabel *labMe;
@end

@implementation SunBloodViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

-(NSMutableArray *)arrayPoint
{
    if (_arrayPoint==nil) {
        _arrayPoint=[NSMutableArray array];
    }
    return _arrayPoint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=MrColor(245, 245, 245);
    if(self.otherUserName==nil){
        self.navigationItem.title=@"血压详情";
    }else{
        self.navigationItem.title=[NSString stringWithFormat:@"%@的血压详情",self.otherUserName];
    }
    UIScrollView *contentScrollView=[[UIScrollView alloc]init];
    contentScrollView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    contentScrollView.contentSize=contentScrollView.frame.size;
    //contentScrollView.backgroundColor=[UIColor redColor];
    self.contentScrollView=contentScrollView;
    contentScrollView.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:contentScrollView];
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.header=header;
    self.contentScrollView.mj_header=header;
    //添加底部控件
    [self setUpTop];
    [self setUpBottom];
    [self getHeader];
}
-(void)loadData
{
    [self getHeader];
    [self.header endRefreshing];
}

//加载头像
-(void)getHeader
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    //判断是否是查看的自己账户
    NSString *tempCode=login.usercode;
    if(![login.usercode isEqualToString:self.otherUserCode]&&self.otherUserCode!=nil)
    {
        tempCode=self.otherUserCode;
        //更改名称
        self.labMe.text=self.otherUserName;
    }
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMePageInfo*%@",tempCode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSDictionary *dicResult=json;
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,[dicResult[@"HeadPic"] copy]]];
        [self.imgHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
        self.imgHead.layer.cornerRadius=30;
        self.imgHead.layer.masksToBounds=YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    

}
//添加上部试图内容
-(void)setUpTop
{
    
    UIView *topView=[[UIView alloc]init];
    self.topView=topView;
    [self.contentScrollView addSubview:topView];
    topView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT/2-64);
    UIImageView *bagImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chart_bg05"]];
    self.bagImgView=bagImgView;
    [topView addSubview:bagImgView];
    bagImgView.frame=topView.frame;
    
    //分割线
    CGFloat centerXRight=30;
    CGFloat labPadding=10;
    
    UIView *cutHView=[[UIView alloc]init];
    cutHView.backgroundColor=[UIColor whiteColor];
    [topView addSubview:cutHView];
    [cutHView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.centerX.equalTo(topView).offset(centerXRight);
        make.top.equalTo(topView).offset(20);
        make.height.equalTo(topView).multipliedBy(0.6);
    }];
    
    //时间
    UILabel *labTime=[[UILabel alloc]init];
    self.labTime=labTime;
    labTime.text=@"--";
    labTime.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labTime.font=kFont(13);
    [topView addSubview:labTime];
    [labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cutHView.mas_bottom);
        make.centerX.equalTo(topView).multipliedBy(0.5).offset(centerXRight/2);
    }];
    //单位
    UILabel *labHigUnit=[[UILabel alloc]init];
    labHigUnit.text=@"mmHg";
    self.labHigUnit=labHigUnit;
    labHigUnit.font=[UIFont fontWithName:@"Arial Rounded MT" size:22];
    labHigUnit.font=kFont(13);
    [topView addSubview:labHigUnit];
    [labHigUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labTime.mas_top).offset(-10);
        make.centerX.centerX.equalTo(topView.mas_centerX).multipliedBy(0.5).offset(-labPadding);
    }];
    //高压低压
    UILabel *labHigLow=[[UILabel alloc]init];
    self.labHigLow=labHigLow;
    labHigLow.text=@"-/-";
    labHigLow.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labHigLow.font=kFont(22);
    [topView addSubview:labHigLow];
    [labHigLow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labHigUnit.mas_top);
        make.centerX.equalTo(labHigUnit);
    }];
    //心率
    UILabel *labRate=[[UILabel alloc]init];
    self.labRate=labRate;
    labRate.text=@"-";
    labRate.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labRate.font=kFont(22);
    [topView addSubview:labRate];
    [labRate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(labHigLow);
        make.left.equalTo(labHigLow.mas_right).offset(labPadding);
    }];
    
    UILabel *labRateUnit=[[UILabel alloc]init];
    self.labRateUnit=labRateUnit;
    labRateUnit.text=@"bpm";
    labRateUnit.font=[UIFont fontWithName:@"Arial Rounded MT" size:22];
    labRateUnit.font=kFont(12);
    [topView addSubview:labRateUnit];
    [labRateUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(labHigUnit);
        make.centerX.equalTo(labRate);
    }];
    
    
    //结果
    UILabel *labResult=[[UILabel alloc]init];
    self.labResult=labResult;
    labResult.text=@"正常";
    labResult.adjustsFontSizeToFitWidth=YES;
    labResult.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:23];
    labResult.font=kFont(23);
    [topView addSubview:labResult];
    CGFloat padding=30;
    [labResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labHigLow.mas_top).offset(-padding+8);
        make.centerX.equalTo(topView.mas_centerX).multipliedBy(0.5).offset(centerXRight/2);
    }];
    //添加右半部分
    UILabel *labControl1=[[UILabel alloc]init];
    labControl1.text=@"舒张压60-90";
    labControl1.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labControl1.font=kFont(13);
    [topView addSubview:labControl1];
    [labControl1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cutHView);
        make.centerX.equalTo(topView).multipliedBy(1.5).offset(centerXRight/2);
    }];
    
    UILabel *labControl2=[[UILabel alloc]init];
    labControl2.text=@"收缩压90-140";
    labControl2.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labControl2.font=kFont(13);
    [topView addSubview:labControl2];
    [labControl2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labControl1.mas_top);
        make.centerX.equalTo(labControl1);
    }];
    
    
    UILabel *labControl3=[[UILabel alloc]init];
    labControl3.text=@"控压目标(mmHg)";
    labControl3.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labControl3.font=kFont(13);
    [topView addSubview:labControl3];
    [labControl3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labControl2.mas_top);
        make.centerX.equalTo(labControl2);
    }];
    
    
    UILabel *labMe=[[UILabel alloc]init];
    self.labMe=labMe;
    labMe.text=@"我";
    labMe.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labMe.font=kFont(13);
    [topView addSubview:labMe];
    [labMe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labControl3.mas_top).offset(-8);
        make.centerX.equalTo(labControl3);
    }];
    //头像
    UIImageView *headImgView=[[UIImageView alloc]init];
    self.imgHead=headImgView;
    [topView addSubview:headImgView];
    
    [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(labMe);
        make.bottom.equalTo(labMe.mas_top).offset(-3);
        make.width.mas_offset(60);
        make.height.equalTo(headImgView.mas_width);
    }];
    
    
    //动态添加宽度自适应约束
    for (NSObject *obj in topView.subviews) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *lable=(UILabel *)obj;
            [lable setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            
            //设置label1的content compression 为1000
            [lable setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
            //改变文字颜色
            lable.textColor=[UIColor whiteColor];
        }
    }
    if (self.otherUserCode==nil) {
        //添加按钮
        CGFloat btnPadding=26;
        UIButton *btnLeft=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnLeft setTitle:@"手动录入" forState:UIControlStateNormal];
        [btnLeft setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
        [btnLeft setBackgroundImage:[UIImage imageNamed:@"drug_btn_background"]  forState:UIControlStateNormal];
        btnLeft.titleLabel.font=kFont(13);
        [topView addSubview:btnLeft];
        [btnLeft addTarget:self action:@selector(insertData) forControlEvents:UIControlEventTouchUpInside];
        //绑定设备
        UIButton *btnRight=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnRight setTitle:@"绑定设备" forState:UIControlStateNormal];
        [btnRight setImage:[UIImage imageNamed:@"setting-white"] forState:UIControlStateNormal];
        [btnRight setBackgroundImage:[UIImage imageNamed:@"drug_btn_background"]  forState:UIControlStateNormal];
        [topView addSubview:btnRight];
        [btnRight addTarget:self action:@selector(bindDevice) forControlEvents:UIControlEventTouchUpInside];
        btnRight.titleLabel.font=btnLeft.titleLabel.font;
        
        //等间距排列
        [@[btnLeft,btnRight] mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:btnPadding leadSpacing:btnPadding tailSpacing:btnPadding];
        
        
        [@[btnLeft,btnRight] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(33);
            make.top.equalTo(labTime.mas_bottom).offset(14);
        }];
    }
    
    
    
    
}
-(void)setUpBottom
{
    UIView *bottomView=[[UIView alloc]init];
    bottomView.backgroundColor=[UIColor whiteColor];
    self.bottomView=bottomView;
    [self.contentScrollView addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(10);
        make.left.equalTo(self.contentScrollView);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.equalTo(self.topView).offset(49);
    }];
    //添加标题
    UILabel *title=[[UILabel alloc]init];
    title.text=@"血压趋势";
    title.textAlignment=NSTextAlignmentCenter;
    title.textColor=MrColor(33, 135, 244);
    title.font=kFont(14);
    [bottomView addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(bottomView);
        make.height.mas_equalTo(30);
        make.top.equalTo(bottomView);
    }];
    //添加箭头
    UIButton *jumpBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [jumpBtn setBackgroundImage:[UIImage imageNamed:@"nav-right"] forState:UIControlStateNormal];
    [bottomView addSubview:jumpBtn];
    [jumpBtn addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
    [jumpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomView).offset(3);
        make.right.equalTo(bottomView).offset(-10);
        make.height.equalTo(title).offset(-6);
        make.width.mas_equalTo(jumpBtn.mas_height);
    }];
    //添加分隔控件
    NSArray *array=[NSArray arrayWithObjects:@"日",@"周",@"月",@"年", nil];
    UISegmentedControl *seg=[[UISegmentedControl alloc]initWithItems:array];
    [bottomView addSubview:seg];
    seg.tintColor=MrColor(33, 135, 244);
    CGFloat segPadding=20;
    [seg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(4);
        make.left.equalTo(bottomView).offset(segPadding);
        make.right.equalTo(bottomView).offset(-segPadding);
        make.height.mas_equalTo(30);
    }];
    self.seg=seg;
    seg.selectedSegmentIndex=0;
    [self.view layoutIfNeeded];
    [seg addTarget:self action:@selector(select:) forControlEvents:UIControlEventValueChanged];
   
    //加载图表数据
    [self  loatData:0];
}
//添加图表控件
-(void)loatData:(int)index
{
    NSDate * date = [NSDate date];
    NSString *dateStr=@"";
    NSString *lastStr=@"";
    if ((int)index==0) {
        NSDate *lastDay=[NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if((int)index==1){
        NSDate *lastDay=[NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if((int)index==2){
        NSDate *lastDay=[NSDate dateWithTimeInterval:-30*24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if((int)index==3){
        NSDate *lastDay=[NSDate dateWithTimeInterval:-12*30*24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    SunLogin *login=[SunAccountTool getAccount];
    //查看是否有值,可以查看其它人员信息
    NSString *userCode=login.usercode;
    if (self.otherUserCode!=nil) {
        userCode=self.otherUserCode;
    }
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetBP*%@*%@,%@*1*10*1",userCode,lastStr,dateStr];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //清空数组
        [self.arrayData removeAllObjects];
        self.arrayData=[SunBlood mj_objectArrayWithKeyValuesArray:json];
        //默认选中第一个
        [self selectResult:0];
        [self setUpLineWidthIndex:index];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
 
    
}


//格式化日期
-(NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString * dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}
//加载折线
-(void)setUpLineWidthIndex:(int)index
{
    CGFloat h=self.bottomView.frame.size.height-CGRectGetMaxY(self.seg.frame);
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 80.0, SCREEN_WIDTH, h-40)];
    NSMutableArray * GArray = [NSMutableArray array];
    NSMutableArray * DArray =  [NSMutableArray array];
    NSMutableArray * RArray = [NSMutableArray array];
    //日期
     NSMutableArray * DataArray = [NSMutableArray array];
    NSMutableArray * newDataArray = [NSMutableArray array];
    // 高压
//    for (SunBlood *blood in self.arrayData) {
//        [GArray addObject:blood.SYSTOLIC];
//        [DArray addObject:blood.DIASTOLIC];
//        [RArray addObject:blood.HEARTRATE];
//        [DataArray addObject:blood.STARTTIME];
//    }
    //倒排序
    for (int i=(int)self.arrayData.count-1; i>=0; i--) {
        SunBlood *blood=self.arrayData[i];
        [GArray addObject:blood.SYSTOLIC];
        [DArray addObject:blood.DIASTOLIC];
        [RArray addObject:blood.HEARTRATE];
        [DataArray addObject:blood.STARTTIME];
    }
    
    
   [self.bottomView addSubview:lineChart];
    NSNumber *time=[[NSNumber alloc]initWithBool:0];
    NSDateFormatter*dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags= NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday|NSCalendarUnitHour;
    if ((int)index==0) {
        //  日
        for (int i=0; i<DataArray.count; i++) {
            NSDate *date=[dateFormatter dateFromString:DataArray[i]];
            comps = [calendar components:unitFlags fromDate:date];
            NSNumber *m= [NSNumber numberWithLong:[comps hour]];//获取月对应的长整形字符串
            //判断是否相等
            if(![time isEqualToNumber:m])
            {
                [newDataArray addObject:[NSString stringWithFormat:@"%@",m]];
            }else{
                [newDataArray addObject:@""];
            }
            time=m;
        }
    }else if((int)index==1){
        //周
        for (int i=0; i<DataArray.count; i++) {
            NSDate *date=[dateFormatter dateFromString:DataArray[i]];
            comps = [calendar components:unitFlags fromDate:date];
            NSNumber *m= [NSNumber numberWithLong:[comps weekday]];//获取月对应的长整形字符串
            //判断是否相等
            if(![time isEqualToNumber:m])
            {
                [newDataArray addObject:[NSString stringWithFormat:@"%@",m]];
            }else{
                [newDataArray addObject:@""];
            }
            time=m;
        }
    }else if((int)index==2){
        //月
        for (int i=0; i<DataArray.count; i++) {
            NSDate *date=[dateFormatter dateFromString:DataArray[i]];
            comps = [calendar components:unitFlags fromDate:date];
            NSNumber *m= [NSNumber numberWithLong:[comps day]];//获取月对应的长整形字符串
            //判断是否相等
            if(![time isEqualToNumber:m])
            {
                [newDataArray addObject:[NSString stringWithFormat:@"%@",m]];
            }else{
                [newDataArray addObject:@""];
            }
            time=m;
        }
    }else if((int)index==3){
        //年
        //重新计算月份
        for (int i=0; i<DataArray.count; i++) {
            NSDate *date=[dateFormatter dateFromString:DataArray[i]];
            comps = [calendar components:unitFlags fromDate:date];
            NSNumber *m= [NSNumber numberWithLong:[comps month]];//获取月对应的长整形字符串
            //判断是否相等
            if(![time isEqualToNumber:m])
            {
                [newDataArray addObject:[NSString stringWithFormat:@"%@",m]];
            }else{
                [newDataArray addObject:@""];
            }
            time=m;
        }
    }
    
    [lineChart setXLabels:newDataArray];
    lineChart.xLabelFont=kFont(20);
    lineChart.yUnit=@"时间";
    //高压
    NSArray * data01Array = GArray;
    PNLineChartData *data01 = [PNLineChartData new];
    data01.color = PNFreshGreen;
    data01.itemCount = lineChart.xLabels.count;
    data01.getData = ^(NSUInteger index) {
        CGFloat yValue = [data01Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    //低压
    NSArray * data02Array = DArray;
    PNLineChartData *data02 = [PNLineChartData new];
    data02.color = PNTwitterColor;
    data02.itemCount = lineChart.xLabels.count;
    data02.getData = ^(NSUInteger index) {
        CGFloat yValue = [data02Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    //心率
    NSArray * data03Array = RArray;
    PNLineChartData *data03 = [PNLineChartData new];
    data03.color = PNPinkGrey;
    data03.itemCount = lineChart.xLabels.count;
    data03.getData = ^(NSUInteger index) {
        CGFloat yValue = [data03Array[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    
    lineChart.chartData = @[data01, data02,data03];
    //折线平滑
    //lineChart.showSmoothLines = YES;
    lineChart.delegate = self;
    
    //开始绘画
    [lineChart strokeChart];
    lineChart.showYGridLines = YES;
    lineChart.yGridLinesColor = [UIColor grayColor];
    
    //图例
    data01.dataTitle = @"收缩压";
    data02.dataTitle = @"舒张压";
    data03.dataTitle = @"心率";
    lineChart.legendStyle = PNLegendItemStyleSerial;
    UIView *legend = [lineChart getLegendWithMaxWidth:290];
    
    //Move legend to the desired position and add to view
    [legend setFrame:CGRectMake((SCREEN_WIDTH-legend.frame.size.width), CGRectGetMaxY(lineChart.frame), legend.frame.size.width, legend.frame.size.height)];
    [self.bottomView addSubview:legend];
    
}

#pragma mark --跳转的方法
-(void)bindDevice
{
    [self.navigationController pushViewController:[[SunDeviceBindiewController alloc]init] animated:YES];
}
-(void)insertData
{
    [self.navigationController pushViewController:[[SunInsertBloodDataViewController alloc]init] animated:YES];
}

-(void)jump
{
    SunBloodDetailViewController *detail=  [[SunBloodDetailViewController alloc]init];
    detail.otherUserCode=self.otherUserCode;
    detail.otherUserName=self.otherUserName;
    [self.navigationController pushViewController:detail animated:YES];
}

//分段控件选择事件
-(void)select:(UISegmentedControl *)seg
{
    self.flag=1;
    [self  loatData:(int)seg.selectedSegmentIndex];
}
//选中显示值
-(void)selectResult:(int)index
{
    if (self.arrayData.count==0) {
        self.labResult.text=@"暂无";
        self.labHigLow.text=@"";
        self.labRate.text=@"";
        self.labTime.text=@"";
        self.labHigUnit.text=@"";
        self.labRateUnit.text=@"";
        
        return;
    }else
    {
        self.labHigUnit.text=@"mmHg";
        self.labRateUnit.text=@"bpm";
    }
    SunBlood *blood=[self.arrayData objectAtIndex:index];
    self.labResult.text=blood.RESULT;
    self.labHigLow.text=[NSString stringWithFormat:@"%@/%@",blood.SYSTOLIC,blood.DIASTOLIC];
    self.labRate.text=blood.HEARTRATE;
    self.labTime.text=blood.STARTTIME;
    //设置背景
    
    UIColor *bgColor=[UIColor flatBlueColor];
    if ([blood.RESULT isEqualToString:@"正常"]) {
        bgColor = [UIColor flatGreenColor];
    } else if ([blood.RESULT isEqualToString:@"最理想"]) {
        bgColor = [UIColor flatGreenColor];
    }
    else if ([blood.RESULT isEqualToString:@"轻度低血压"]) {
        bgColor = [UIColor flatGrayColor];
    }
    else if ([blood.RESULT isEqualToString:@"重度低血压"]) {
        bgColor = [UIColor flatGrayColorDark];
    }
    else if ([blood.RESULT isEqualToString:@"中度高血压"]) {
        bgColor = [UIColor flatOrangeColor];
    }
    else if ([blood.RESULT isEqualToString:@"轻度高血压"]) {
        bgColor = [UIColor flatYellowColor];
    } else if ([blood.RESULT isEqualToString:@"重度高血压"]) {
        bgColor = [UIColor flatRedColor];
    } else if ([blood.RESULT isEqualToString:@"正常偏高"]) {
        bgColor = [UIColor flatPinkColor];
    }
    self.bagImgView.image=[self createImageWithColor:bgColor];
}

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
#pragma mark --线段代理事件
-(void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex pointIndex:(NSInteger)pointIndex
{
    [self selectResult:(int)pointIndex];
}
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex
{

}
@end
