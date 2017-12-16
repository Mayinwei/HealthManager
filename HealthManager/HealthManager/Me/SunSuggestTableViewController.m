//
//  SunSuggestTableViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSuggestTableViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunSuggestModel.h"
#import "MJRefresh.h"
#import "UITableView+EmptyData.h"
#import "SunSuggestTableViewCell.h"

@interface SunSuggestTableViewController ()
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,assign)CGFloat CellHeightSuggest;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
//上拉刷新
@property(nonatomic,strong)MJRefreshBackNormalFooter *footer;
//页码
@property(nonatomic,assign)int PageIndex;
@end

@implementation SunSuggestTableViewController

-(NSMutableArray *)arrayData{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"专家建议";
    self.view.backgroundColor=MrColor(230, 230, 230);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    //加载数据
    [self loadData];
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    self.tableView.mj_header=header;
    //页码
    self.PageIndex=1;
    
    //这个系统方法·   自适应高度
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    //这个或者代理方法 estimatedHeightForRowAtIndexPath
//    self.tableView.estimatedRowHeight = 100;

}
-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
}
//加载旧数据
-(void)refreshOld
{
    [self loadOldData];
    [self.footer endRefreshing];
}
-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    
    dic[@"parma"]=[NSString stringWithFormat:@"GetPrescription*%@*1*10",login.usercode];
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
        self.arrayData=[SunSuggestModel mj_objectArrayWithKeyValuesArray:json];
        [self.tableView reloadData];
        if(self.arrayData.count>0)
        {
            [self setUpControl];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

//讲专家建议标记为已读
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self flagDate];
}

-(void)flagDate
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"SetPrescriptionRead*%@",login.usercode];
    
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
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

//上拉加载旧数据
-(void)loadOldData
{
    self.PageIndex++;
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    
    dic[@"parma"]=[NSString stringWithFormat:@"GetPrescription*%@*%d*10",login.usercode,self.PageIndex];
    
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
        NSMutableArray *oldArray=[SunSuggestModel mj_objectArrayWithKeyValuesArray:json];
        [self.arrayData addObjectsFromArray:oldArray];
        if(oldArray.count>0){
            [self.tableView reloadData];
        }else{
            self.tableView.mj_footer=NULL;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

//加载刷新控件
-(void)setUpControl
{
    //上拉加载
    MJRefreshBackNormalFooter *footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshOld)];
    self.footer=footer;
    self.tableView.mj_footer=footer;
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
    SunSuggestTableViewCell *cell=[SunSuggestTableViewCell cellWithTabelView:tableView];
    SunSuggestModel *sug=self.arrayData[indexPath.row];
    cell.suggest=sug;
    self.CellHeightSuggest=cell.getAutoCellHeight;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.CellHeightSuggest;
}
//取消选中
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
