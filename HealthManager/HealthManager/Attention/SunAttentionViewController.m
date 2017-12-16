//
//  SunAttentionViewController.m
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  关注界面

#import "SunAttentionViewController.h"
#import "UITableView+EmptyData.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "Chameleon.h"
#import "SunAttentionModel.h"
#import "SunAttentionTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SunAddAttentionViewController.h"
#import "SunDataViewController.h"
@interface SunAttentionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableview;
@property(nonatomic,strong)MJRefreshNormalHeader *header;
@property(nonatomic,strong)MJRefreshBackNormalFooter *footer;
@property(nonatomic,strong)NSMutableArray *arrayData;
//页码
@property(nonatomic,assign)int PageIndex;
@end

@implementation SunAttentionViewController
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
    self.navigationItem.title=@"关注";
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"添加人员" style: UIBarButtonItemStyleDone target:self action:@selector(addPeo)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    //页码
    self.PageIndex=1;
    //加载数据
    [self loadDate];
    //添加控件
    [self setUpCon];
}
//加载数据
-(void)loadDate
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetAttentionUser*%@*1*10",login.usercode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [self.arrayData removeAllObjects];
        self.arrayData=[SunAttentionModel mj_objectArrayWithKeyValuesArray:json];
        if(self.arrayData.count>0)
        {
            [self setUpControl];
        }
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];


}
//加载旧数据
-(void)loadOldData
{
    self.PageIndex++;
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetAttentionUser*%@*2*10",login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        
        
        NSMutableArray *oldArray=[SunAttentionModel mj_objectArrayWithKeyValuesArray:json];
        [self.arrayData addObjectsFromArray:oldArray];
        if(oldArray.count>0){
            [self.tableview reloadData];
        }else{
            self.tableview.mj_footer=NULL;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

-(void)refreshData
{
    [self loadDate];
    [self.header endRefreshing];
}
-(void)bottomLoadData
{
    //加载旧数据
    [self loadOldData];
    [self.footer endRefreshing];
}
//加载刷新控件
-(void)setUpControl
{
    [self.tableview reloadData];
    //上拉加载
    MJRefreshBackNormalFooter *footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(bottomLoadData)];
    self.footer=footer;
    self.tableview.mj_footer=footer;
}
-(void)setUpCon
{
    //刷新
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    UITableView *tableview=[[UITableView alloc]init];
    self.tableview=tableview;
    self.tableview.mj_header=header;
    tableview.delegate=self;
    tableview.dataSource=self;
    [self.view addSubview:tableview];
    tableview.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    

}

//添加关注人员
-(void)addPeo
{
    [self.navigationController pushViewController:[[SunAddAttentionViewController alloc]init] animated:YES];
}
#pragma mark --tableview代理协议

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [tableView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunAttentionTableViewCell *cell=[SunAttentionTableViewCell cellWithTableView:tableView];
    SunAttentionModel *attModel=self.arrayData[indexPath.row];
    cell.attModel=attModel;
    
    return cell;
}
//选择协议
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SunAttentionModel *attention=self.arrayData[indexPath.row];
    SunDataViewController *dataView=[[SunDataViewController alloc]init];
    dataView.otherUserCode=attention.ATTENTEDUSER;
    dataView.otherUserName=attention.USERNAME;
    [self.navigationController pushViewController:dataView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
//解绑设备
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        SunAttentionModel *attention=self.arrayData[indexPath.row];
        
        [self deletePeoWidthCode:attention.ATTENTEDUSER];
        //删除数组中的对应数据
        [self.arrayData removeObjectAtIndex:indexPath.row];
        
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"解除";
}

//解除绑定
-(void)deletePeoWidthCode:(NSString*)code
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"DeleteAttention*%@*%@",login.usercode,code];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"解除成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        //删除本行
        [self.tableview reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"解除失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    }];
}
@end
