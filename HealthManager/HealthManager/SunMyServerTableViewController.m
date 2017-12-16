//
//  SunMyServerTableViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//  我的服务

#import "SunMyServerTableViewController.h"
#import "SunMyServerModel.h"
#import "UITableView+EmptyData.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunMyServiceTableViewCell.h"
#import "SunServerDetailViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "SunBuyViewController.h"
#import "SunPayResultModel.h"
#import "SunServerCategoryViewController.h"
#import <Hyphenate/Hyphenate.h>
#import "SunChatTypeInfoModel.h"
#import "SunChatViewController.h"
#import "YBPopupMenu.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
@interface SunMyServerTableViewController ()<SunMyServiceTableViewCellDelegate,YBPopupMenuDelegate>
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,strong)MJRefreshNormalHeader *header;

//保存点击的行数
@property(nonatomic,assign)NSInteger index;
@end

@implementation SunMyServerTableViewController

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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title=@"我的服务";
    UIButton *rigBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    rigBtn.frame=CGRectMake(0, 0, 20, 20);
    [rigBtn setBackgroundImage:[UIImage imageNamed:@"right-add"] forState:UIControlStateNormal];
    [rigBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:rigBtn];
    
    //去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    self.tableView.mj_header=header;
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePay) name:@"UpdatePayStatus" object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)updatePay
{
    NSUserDefaults *userDefault= [NSUserDefaults standardUserDefaults];
    NSString *orderCode=[userDefault objectForKey:@"OrderCode"];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"UpdatePayStatus*%@*%@",orderCode,login.usercode];
    
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
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"更改订单状态失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
-(void)rightBtnClick
{
    [self.navigationController pushViewController:[[SunServerCategoryViewController alloc]init] animated:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadData];
    
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetUserService*%@",login.usercode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        self.arrayData=[SunMyServerModel mj_objectArrayWithKeyValuesArray:json];
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
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunMyServiceTableViewCell *cell=[SunMyServiceTableViewCell cellWithTableView:tableView];
    cell.delegate=self;
    cell.btnData.tag=indexPath.row;
    SunMyServerModel *ser=self.arrayData[indexPath.row];
    cell.servermodel=ser;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark --自定义cell代理协议
-(void)tableViewCell:(SunMyServiceTableViewCell *)cell WithDetail:(UIButton *)sender
{
    
    SunMyServiceTableViewCell *serTb=cell;
    SunMyServerModel *ser=self.arrayData[sender.tag];
    NSArray *arraySer=nil;
    NSArray *arrayImg=nil;
    if ([ser.STATUS isEqualToString:@"待付款"]) {
        arraySer=@[@"服务简介",@"支付"];
        arrayImg=@[@"suggest_icon",@"pay_icon"];
    }else{
        arraySer=@[@"服务简介",@"查看消息"];
        arrayImg=@[@"suggest_icon",@"news_icon"];
    }
    [YBPopupMenu showRelyOnView:serTb.btnData titles:arraySer  icons:arrayImg menuWidth:140 delegate:self];
    self.index=sender.tag;
}

#pragma mark -YBPopupMenu代理协议

-(void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    //查看数据
    SunMyServerModel *server=self.arrayData[self.index];
    if (index==0) {
        //服务简介
        SunServerDetailViewController *detailVC= [[SunServerDetailViewController alloc]init];
        detailVC.title=server.SVRNAME;
        detailVC.serModel=server;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if(index==1){
        if ([server.STATUS isEqualToString:@"待付款"]) {
            //支付
            [self payServer:server];
        }else{
            //查看消息
            SunChatViewController *chat=[[SunChatViewController alloc]initWithConversationChatter:server.DOCCODE conversationType:EMConversationTypeChat];
            chat.ChatCode=server.DOCCODE;
            [self.navigationController pushViewController:chat animated:YES];
        }
    }

}


//支付界面
-(void)payServer:(SunMyServerModel *)server
{
    //获取本机Ip
    NSDictionary *dicIpInfo=[self getIPAddresses];
    NSString *myIp=dicIpInfo[@"pdp_ip0/ipv4"];
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"CreateWeChatCode*%@*%@*%@",server.SVRCODE,server.ORDCODE,myIp];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        SunPayResultModel *pay=[SunPayResultModel mj_objectWithKeyValues:json];
        
        SunBuyViewController *buy=  [[SunBuyViewController alloc]init];
        buy.payModel=pay;
        buy.SerCode=server.SVRCODE;
        [self.navigationController pushViewController:buy animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}


- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end
