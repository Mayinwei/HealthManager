//
//  SunDeviceTableViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//  设备管理

#import "SunDeviceTableViewController.h"
#import "UITableView+EmptyData.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunDeviceModel.h"
#import "SunDeviceTableViewCell.h"
#import "SunDevicePlanViewController.h"
#import "SunDeviceBindiewController.h"


@interface SunDeviceTableViewController ()
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@end

@implementation SunDeviceTableViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"设备管理";
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"绑定设备" style: UIBarButtonItemStyleDone target:self action:@selector(addDevice)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    
    //去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    self.tableView.mj_header=header;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //加载数据
    [self loadData];
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetUserDevice*%@",login.usercode];
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
        self.arrayData=[SunDeviceModel mj_objectArrayWithKeyValuesArray:json];
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
}

-(void)addDevice
{
    [self.navigationController pushViewController:[[SunDeviceBindiewController alloc]init] animated:YES];
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
    SunDeviceTableViewCell *cell=[SunDeviceTableViewCell cellWithTabelView:tableView];
    cell.deviceModel=self.arrayData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"解绑";
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunDeviceModel *device=self.arrayData[indexPath.row];
    if ([device.EQUSUBTYPE isEqualToString:@"动态血压计"]) {
        SunDevicePlanViewController *dePlan=[[SunDevicePlanViewController alloc]init];
        dePlan.EquCode=device.EQUCODE;
        [self.navigationController pushViewController:dePlan animated:YES];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//解绑设备
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        SunDeviceModel *device=self.arrayData[indexPath.row];
        
        [self deleteDeviceWidthCode:device.EQUCODE];
        //删除数组中的对应数据
        [self.arrayData removeObjectAtIndex:indexPath.row];
        //删除本行
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView reloadData];
    }
}

-(void)deleteDeviceWidthCode:(NSString *)code
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"DelDevice*%@*%@",login.usercode,code];
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
