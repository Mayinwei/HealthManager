//
//  SunAttentionRequestTableViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunAttentionRequestTableViewController.h"
#import "UITableView+EmptyData.h"
#import "SunGuanInfoModel.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunGuanTableViewCell.h"
#import "SunGuanInfoModel.h"
@interface SunAttentionRequestTableViewController ()<SunGuanTableViewCellDelegate>
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)MJRefreshBackNormalFooter *footer;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@end

@implementation SunAttentionRequestTableViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"关注信息";
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];

    //刷新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.header=header;
    self.tableView.mj_header=header;
    //加载数据
    [self loadData];
    
    self.tableView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
}

-(void)refreshHead
{
    [self loadData];
    [self.header endRefreshing];
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetGuanInfoByMe*%@*1*10",login.usercode];
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
        self.arrayData=[SunGuanInfoModel mj_objectArrayWithKeyValuesArray:json];
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

//加载刷新控件
-(void)setUpControl
{
    //上拉加载
    MJRefreshBackNormalFooter *footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomLoadData)];
    self.footer=footer;
    self.tableView.mj_footer=footer;
}


-(void)bottomLoadData
{
    [self.footer endRefreshing];
}

#pragma mark --celldialing协议
-(void)guanCell:(SunGuanTableViewCell *)cell
{
    SunGuanInfoModel *info=self.arrayData[cell.tag];
    NSString*ID=info.ID;
    NSString *type=info.type;
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];

    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"UpdateAttentionInfo*%@*%@*1",ID,type];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self loadData];
        [SVProgressHUD showSuccessWithStatus:@"操作成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"暂无关注数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunGuanTableViewCell *cell=[SunGuanTableViewCell cellWithTableView:tableView];
    cell.delegate=self;
    cell.tag=indexPath.row;
    SunGuanInfoModel *info=self.arrayData[indexPath.row];
    cell.guanModel=info;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self deleteDeviceWidthCode:(int)indexPath.row];
        //删除数组中的对应数据
        [self.arrayData removeObjectAtIndex:indexPath.row];
        //删除本行
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView reloadData];
    }
}

//设置tableview是否可编辑
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunGuanInfoModel *info=self.arrayData[indexPath.row];
    if ([info.type isEqualToString:@"1"]&&[info.STATUS isEqualToString:@"0"]) {
        return UITableViewCellEditingStyleDelete;
    }
    //判断是否显示删除操作
    return UITableViewCellEditingStyleNone;
    
}

-(void)deleteDeviceWidthCode:(int)index
{
    SunGuanInfoModel *info=self.arrayData[index];
    NSString*ID=info.ID;
    NSString *type=info.type;
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"UpdateAttentionInfo*%@*%@*2",ID,type];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self loadData];
        [SVProgressHUD showSuccessWithStatus:@"操作成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"不同意";
}
@end
