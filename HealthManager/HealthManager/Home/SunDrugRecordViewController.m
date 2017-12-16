//
//  SunDrugRecordViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//  服药记录

#import "SunDrugRecordViewController.h"
#import "MJRefresh.h"
#import "Chameleon.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"
#import "MrDatePicker.h"
#import "UITableView+EmptyData.h"
#import "SunPlanRecordTableViewCell.h"
#import "SunRecordModel.h"
#import "SunAddPlanViewController.h"

@interface SunDrugRecordViewController ()<UITextFieldDelegate,MrDatePickerDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UIView *topView;
@property(nonatomic,strong)UITextField *textStart;
@property(nonatomic,strong)UITextField *textEnd;
@property(nonatomic,strong)UITextField *textField;
@property(nonatomic,strong)UITableView *tableView;

@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@property(nonatomic,strong)MJRefreshBackNormalFooter *footer;

//页码
@property(nonatomic,assign)int PageIndex;
@end

@implementation SunDrugRecordViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.PageIndex=1;
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"服药记录";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"添加记录" style: UIBarButtonItemStyleDone target:self action:@selector(addRecord)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //添加控件
    [self setUpTop];
    
    //添加底部控件
    [self setBottom];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadData];
}
//添加记录
-(void)addRecord
{
    SunAddPlanViewController *add=[[SunAddPlanViewController alloc]init];
    add.type=SunAddTypeRecord;
    [self.navigationController pushViewController:add animated:YES ];
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
    [btnSearch addTarget:self action:@selector(searClick) forControlEvents:UIControlEventTouchUpInside];
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
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [topView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.equalTo(topView);
        make.height.mas_equalTo(1);
    }];
}

-(void)setBottom
{
    //添加刷新标题
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    
    UITableView *tableView=[[UITableView alloc]init];
    tableView.mj_header=header;
    self.tableView=tableView;
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.top.equalTo(self.topView.mas_baseline);
        make.bottom.equalTo(self.view);
    }];
    //取消没有数据时的表格线
    tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
}
//加载数据
-(void)loadData
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedExec*%@**%@ 00:00:00.000*%@ 23:59:59.000*1*10*已服用",login.usercode,self.textStart.text,self.textEnd.text];
    [manager POST:MyURL parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        [SVProgressHUD show];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        [SVProgressHUD dismiss];
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self.arrayData removeAllObjects];
        self.arrayData=[SunRecordModel mj_objectArrayWithKeyValuesArray:json];
        if(self.arrayData.count>0)
        {
            [self setUpControl];
        }
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

//加载旧数据
-(void)loadOldData
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    self.PageIndex++;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedExec*%@**%@ 00:00:00.000*%@ 23:59:59.000*%d*10*已服用",login.usercode,self.textStart.text,self.textEnd.text,self.PageIndex];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:MyURL parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        [SVProgressHUD show];
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        [SVProgressHUD dismiss];
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        
        NSMutableArray *oldArray=[SunRecordModel mj_objectArrayWithKeyValuesArray:json];
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

-(void)refreshOldData
{
    //加载旧数据
    [self loadOldData];
    [self.footer endRefreshing];
}
//加载刷新控件
-(void)setUpControl
{
    //上拉加载
    MJRefreshBackNormalFooter *footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshOldData)];
    self.footer=footer;
    self.tableView.mj_footer=footer;
}

-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"还没有任何记录" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunRecordModel *record=self.arrayData[indexPath.row];
    SunPlanRecordTableViewCell *cell=[SunPlanRecordTableViewCell cellWithTabelView:tableView];
    cell.labName.text=record.MEDNAME;
    cell.labNum.text=[NSString stringWithFormat:@"%@%@",record.NUM,record.UNIT];
    cell.labWay.text=record.WAYS;
    cell.labTime.text=[record.EXECTIME componentsSeparatedByString:@" "][1];
    cell.labDate.text=[record.EXECTIME componentsSeparatedByString:@" "][0];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark --文本框协议
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

-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    self.textField.text=[[time componentsSeparatedByString:@" "] objectAtIndex:0];
}

//查询
-(void)searClick
{
    [self.header beginRefreshing];

}


@end
