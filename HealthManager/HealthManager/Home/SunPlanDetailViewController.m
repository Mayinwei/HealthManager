//
//  SunPlanDetailViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//  计划详情

#import "SunPlanDetailViewController.h"
#import "UITableView+EmptyData.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "Chameleon.h"
#import "SunPlanDetailTableViewCell.h"
#import "SunPlanDetailModel.h"
#import "SunAddPlanViewController.h"

@interface SunPlanDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)MJRefreshNormalHeader *header;

@end

@implementation SunPlanDetailViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"计划详情";
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"添加明细" style: UIBarButtonItemStyleDone target:self action:@selector(addPlanDetail)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UIView *topView=[[UIView alloc]init];
    [self.view addSubview:topView ];
    topView.backgroundColor=MrColor(230, 230, 230);
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    UILabel *labTitle=[[UILabel alloc]init];
    NSString *strTime=[self.StartTime componentsSeparatedByString:@" "][0];
    labTitle.text=[NSString stringWithFormat:@"执行时间:%@",strTime];
    labTitle.font=kFont(15);
    [topView addSubview:labTitle];
    labTitle.textColor=[UIColor lightGrayColor];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(topView);
        make.left.equalTo(topView).offset(17);
        make.right.equalTo(topView);
        make.top.equalTo(topView);
    }];
    
    UITableView *tableView=[[UITableView alloc]init];
    self.tableView=tableView;
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    //去掉多余分割线
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    tableView.mj_header=header;
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //加载数据
    [self loadData];

}
-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
}
-(void)addPlanDetail
{
   SunAddPlanViewController *addPlan= [[SunAddPlanViewController alloc]init];
    addPlan.MedDCode=self.MedDCode;
    addPlan.type=SunAddTypePlan;
    [self.navigationController pushViewController:addPlan animated:YES];
}



-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedPlanDet*%@",self.MedDCode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        
        self.arrayData=[SunPlanDetailModel mj_objectArrayWithKeyValuesArray:json];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SunPlanDetailModel *planDetail=self.arrayData[indexPath.row];
    SunPlanDetailTableViewCell *cell=[SunPlanDetailTableViewCell cellWithTableView:tableView];
    cell.labName.text=[NSString stringWithFormat:@"名称:%@",planDetail.MEDNAME];
    cell.labNum.text=[NSString stringWithFormat:@"剂量:%@%@",planDetail.NUM,planDetail.UNIT];
    cell.labWay.text=[NSString stringWithFormat:@"方法:%@",planDetail.WAYS];
    cell.labTime.text=[NSString stringWithFormat:@"时间:%@",planDetail.PLANTIME];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        SunPlanDetailModel *plan=self.arrayData[indexPath.row];
        
        [self deletePlanDetailWidthCode:plan.MEDDCODE];
        //删除数组中的对应数据
        [self.arrayData removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//删除计划详情
-(void)deletePlanDetailWidthCode:(NSString *)code
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GelMedPlanDet*%@",code];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"删除失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

@end
