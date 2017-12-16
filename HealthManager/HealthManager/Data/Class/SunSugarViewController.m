//
//  SunSugarViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/4.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSugarViewController.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunCutImageView.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunSugarDetailModel.h"
#import "SunErrorModel.h"
#import "SunSugarDetailViewController.h"
#import "SunInsertSugarDataViewController.h"
#import "SunDeviceBindiewController.h"
#import "UIImageView+WebCache.h"
#import "PNChart.h"
#import "Chameleon.h"

@interface SunSugarViewController ()<PNChartDelegate>
@property(nonatomic,weak)UIScrollView *contentScrollView;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@property(nonatomic,weak)UIView *topView;
@property(nonatomic,weak)UILabel *labTime;
@property(nonatomic,weak)UILabel *labNum;
@property(nonatomic,weak)UILabel *labResult;
@property(nonatomic,weak)UILabel *labTimeD;
@property(nonatomic,weak)UILabel *labHigUnit;
@property(nonatomic,weak)UIView *bottomView;
@property(nonatomic,weak)UIImageView *imgHead;
@property(nonatomic,weak)UIImageView *bagImgView;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,weak)UILabel *bottomTitle;
@property(nonatomic,weak)UILabel *labMe;
@end

@implementation SunSugarViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=MrColor(245, 245, 245);
    
    if(self.otherUserName==nil){
        self.navigationItem.title=@"血糖详情";
    }else{
        self.navigationItem.title=[NSString stringWithFormat:@"%@的血糖详情",self.otherUserName];
    }
    
    UIScrollView *contentScrollView=[[UIScrollView alloc]init];
    contentScrollView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    contentScrollView.contentSize=contentScrollView.frame.size;
    self.contentScrollView=contentScrollView;
    contentScrollView.showsHorizontalScrollIndicator=NO;
    [self.view addSubview:contentScrollView];
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.header=header;
    self.contentScrollView.mj_header=header;
    
    //添加顶部布局
    [self setUpTop];
    [self setUpBottom];
    [self getHeader];
    
    //加载数据
    [self getDate];
}

//刷新数据
-(void)loadData
{
    [self getHeader];
    [self.header endRefreshing];
}

//格式化日期
-(NSString *)getDateString:(NSDate *)date
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    NSString * dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

-(void)getDate
{
    int index=3;
    NSDate * date = [NSDate date];
    NSString *dateStr=@"";
    NSString *lastStr=@"";
    if (index==0) {
        NSDate *lastDay=[NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if(index==1){
        NSDate *lastDay=[NSDate dateWithTimeInterval:-7*24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if(index==2){
        NSDate *lastDay=[NSDate dateWithTimeInterval:-30*24*60*60 sinceDate:date];
        dateStr= [self getDateString:date];
        lastStr= [self getDateString:lastDay];
    }else if(index==3){
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
    dic[@"parma"]=[NSString stringWithFormat:@"GetXT*%@*%@,%@*1*10*1",userCode,lastStr,dateStr];
    
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
        self.arrayData=[SunSugarDetailModel mj_objectArrayWithKeyValuesArray:json];
        [self selectResult:0];
        [self setUpLineWidthIndex:3];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//选中显示值
-(void)selectResult:(int)index
{
    if (self.arrayData.count==0) {
        self.labResult.text=@"暂无";
        self.labNum.text=@"";
        self.labTime.text=@"";
        self.labTimeD.text=@"";
        self.labHigUnit.text=@"";
        return;
    }
    self.labHigUnit.text=@"mmol/L";
    SunSugarDetailModel *sugar=[self.arrayData objectAtIndex:index];
    self.labResult.text=sugar.RESULT;
    self.labNum.text=sugar.XTZ;
    self.labTime.text=sugar.CLSJ;
    self.labTimeD.text=sugar.XTLX;
    //设置背景    
    UIColor *bgColor=[UIColor flatBlueColor];
    if ([sugar.RESULT isEqualToString:@"正常"]) {
        bgColor = [UIColor flatGreenColor];
    } else if ([sugar.RESULT isEqualToString:@"高血糖"]) {
        bgColor = [UIColor flatRedColor];
    }
    else if ([sugar.RESULT isEqualToString:@"低血糖"]) {
        bgColor = [UIColor flatGrayColor];
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
    CGFloat paddingHo=10;
    UILabel *labTime=[[UILabel alloc]init];
    self.labTime=labTime;
    labTime.text=@"2015-12-12 12:12:000";
    labTime.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labTime.font=kFont(13);
    [topView addSubview:labTime];
    [labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(cutHView.mas_bottom).offset(-10);
        make.centerX.equalTo(topView).multipliedBy(0.5).offset(centerXRight/2-20);
    }];
    //时间段
    UILabel *labTimeD=[[UILabel alloc]init];
    self.labTimeD=labTimeD;
    labTimeD.text=@"早餐前";
    labTimeD.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labTimeD.font=kFont(13);
    [topView addSubview:labTimeD];
    [labTimeD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labTime.mas_right).offset(5);
        make.centerY.equalTo(labTime);
    }];
    
    //血糖值
    UILabel *labNum=[[UILabel alloc]init];
    self.labNum=labNum;
    labNum.text=@"";
    labNum.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labNum.font=kFont(35);
    [topView addSubview:labNum];
    [labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labTime.mas_top).offset(-paddingHo);
        make.centerX.equalTo(topView).multipliedBy(0.5).offset(centerXRight/2);
    }];
    //单位
    UILabel *labHigUnit=[[UILabel alloc]init];
    self.labHigUnit=labHigUnit;
    labHigUnit.text=@"mmol/L";
    labHigUnit.font=[UIFont fontWithName:@"Arial Rounded MT" size:22];
    labHigUnit.font=kFont(13);
    [topView addSubview:labHigUnit];
    [labHigUnit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labNum.mas_right).offset(5);
        make.bottom.equalTo(labNum);
    }];
    
    
    
    //结果
    UILabel *labResult=[[UILabel alloc]init];
    self.labResult=labResult;
    labResult.text=@"正常";
    labResult.adjustsFontSizeToFitWidth=YES;
    labResult.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:23];
    labResult.font=kFont(32);
    [topView addSubview:labResult];
    [labResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(labNum.mas_top).offset(-paddingHo+8);
        make.centerX.equalTo(labNum);
    }];
    //添加右半部分
    
    //头像
    UIImageView *headImgView=[[UIImageView alloc]init];
    self.imgHead=headImgView;
    [topView addSubview:headImgView];
    
    [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topView).multipliedBy(1.5).offset(centerXRight/2);
        make.top.equalTo(cutHView).offset(30);
        make.width.mas_offset(60);
        make.height.equalTo(headImgView.mas_width);
    }];
    
    UILabel *labMe=[[UILabel alloc]init];
    self.labMe=labMe;
    labMe.text=@"我";
    labMe.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:22];
    labMe.font=kFont(13);
    [topView addSubview:labMe];
    [labMe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headImgView.mas_bottom).offset(8);
        make.centerX.equalTo(headImgView);
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
    if(self.otherUserCode==nil)
    {
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
            make.top.equalTo(cutHView.mas_bottom).offset(14);
        }];
    }
    
    
    
    
}


//加载头像
-(void)getHeader
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //manager.responseSerializer = [AFHTTPResponseSerializer serializer];// 响应
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
    self.bottomTitle=title;
    title.text=@"血糖趋势";
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
    
}

-(void)insertData
{
    [self.navigationController pushViewController:[[SunInsertSugarDataViewController alloc]init] animated:YES];
}
-(void)bindDevice
{
    [self.navigationController pushViewController:[[SunDeviceBindiewController alloc]init] animated:YES];
}
-(void)jump
{
    SunSugarDetailViewController *detaile= [[SunSugarDetailViewController alloc]init];
    detaile.otherUserCode=self.otherUserCode;
    detaile.otherUserName=self.otherUserName;
    [self.navigationController pushViewController:detaile animated:YES];
}



//加载折线
-(void)setUpLineWidthIndex:(int)index
{
    CGFloat h=self.bottomView.frame.size.height-CGRectGetMaxY(self.bottomTitle.frame);
    PNLineChart * lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, h-40)];
    NSMutableArray * GArray = [NSMutableArray array];
    //日期
    NSMutableArray * DataArray = [NSMutableArray array];
    NSMutableArray * newDataArray = [NSMutableArray array];

    //倒排序
    for (int i=(int)self.arrayData.count-1; i>=0; i--) {
        SunSugarDetailModel *sugar=self.arrayData[i];
        [GArray addObject:sugar.XTZ];
        [DataArray addObject:sugar.CLSJ];
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
    
    lineChart.chartData = @[data01];
    //折线平滑
    lineChart.delegate = self;
    
    //开始绘画
    [lineChart strokeChart];
    lineChart.showYGridLines = YES;
    lineChart.yGridLinesColor = [UIColor grayColor];
    
    //图例
    data01.dataTitle = @"血糖值";
    lineChart.legendStyle = PNLegendItemStyleSerial;
    UIView *legend = [lineChart getLegendWithMaxWidth:290];
    
    //Move legend to the desired position and add to view
    [legend setFrame:CGRectMake((SCREEN_WIDTH-legend.frame.size.width), CGRectGetMaxY(lineChart.frame), legend.frame.size.width, legend.frame.size.height)];
    [self.bottomView addSubview:legend];
    
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
