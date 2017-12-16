//
//  SunServerDetailViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//  服务详情

#import "SunServerDetailViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "UIImageView+WebCache.h"
#import "SunBuyViewController.h"
#import "SunPayResultModel.h"
#import "SunMyServerModel.h"
#import "SunPayResultModel.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
@interface SunServerDetailViewController ()
@property(nonatomic,strong)UIScrollView *contentScroll;
@property(nonatomic,strong)UILabel *labPric;
@property(nonatomic,strong)UILabel *labNo;
@end

@implementation SunServerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.title=@"服务详情";
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIScrollView *contentScroll=[[UIScrollView alloc]init];
    self.contentScroll=contentScroll;
    contentScroll.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:contentScroll];
    contentScroll.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-53-64);
    
    
    //加载内容
    [self setMain];
    [self loadData];
}


-(void)setMain
{
    //暂无介绍
    UILabel *labNo=[[UILabel alloc]init];
    self.labNo=labNo;
    labNo.hidden=YES;
    labNo.textAlignment=NSTextAlignmentCenter;
    labNo.text=@"暂无介绍";
    labNo.font=kFont(15);
    labNo.textColor=[UIColor lightGrayColor];
    [self.contentScroll addSubview:labNo];
    [labNo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentScroll).offset(20);
        make.width.equalTo(self.contentScroll);
    }];
    
    UIView *botView=[[UIView alloc]init];
    botView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:botView];
    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(53);
    }];
    //分隔线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=[UIColor lightGrayColor];
    [botView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(botView);
        make.right.equalTo(botView);
        make.top.equalTo(botView);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=@"购买价格:";
    labTitle.font=kFont(15);
    labTitle.textColor=[UIColor lightGrayColor];
    [botView addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(botView);
        make.left.equalTo(botView).offset(30);
    }];
    
    UILabel *labPric=[[UILabel alloc]init];
    self.labPric=labPric;
    labPric.text=@"￥0.00";
    labPric.textColor=MrColor(227, 51, 51);
    labPric.font=[UIFont fontWithName:@"Courier-Bold" size:20];
    [botView addSubview:labPric];
    [labPric mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(labTitle);
        make.left.equalTo(labTitle.mas_right).offset(15);
    }];
    
    //购买按钮
    UIButton *buyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    buyBtn.titleLabel.font= kFont(13);
    [botView addSubview:buyBtn];
    [buyBtn setTitle:@"购买" forState:UIControlStateNormal];
    [buyBtn setBackgroundImage:[UIImage imageNamed:@"common-btn-red"] forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(buyClick) forControlEvents:UIControlEventTouchUpInside];
    [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(botView).offset(-30);
        make.centerY.equalTo(botView);
        make.height.equalTo(botView).multipliedBy(0.6);
        make.width.mas_equalTo(60);
    }];
    
    //判断是否显示付款
    if([self.serModel.STATUS isEqualToString:@"新增"])
    {
        botView.hidden=YES;
        CGFloat scrollH=self.contentScroll.frame.size.height;
        scrollH +=53;
        self.contentScroll.frame=CGRectMake(0, 0, SCREEN_WIDTH, scrollH);
    }
}
-(void)buyClick
{
    //获取本机Ip
    NSDictionary *dicIpInfo=[self getIPAddresses];
    NSString *myIp=dicIpInfo[@"pdp_ip0/ipv4"];
    //判断是否是0元
    if ([self.labPric.text floatValue]==0) {
        [SVProgressHUD showErrorWithStatus:@"商品价格不正确"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"getPayService*%@*%@*%@*%@*%@",self.serModel.SVRCATE,self.serModel.DOCCODE,login.usercode,self.serModel.SVRCODE,myIp];
    
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
        buy.SerCode=self.serModel.SVRCODE;
        [self.navigationController pushViewController:buy animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetServerInfo*%@",self.serModel.SVRCODE];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSString *strPrc=[json[@"Price"] copy];
        NSString *ipic=[json[@"IPic"] copy];
        NSString *apic=[json[@"APic"] copy];
        self.labPric.text=[NSString stringWithFormat:@"%@元",strPrc];
        //判断是否有图片
        if ([ipic isEqualToString:@""]&&[apic isEqualToString:@""]) {
            [self.labNo removeFromSuperview];
            return;
        }
        //图片高度
        CGFloat h=300;
        //拼接生成图片
        int iCount=(int)[ipic componentsSeparatedByString:@","].count;
        for (int i=0; i<iCount; i++) {
            UIImageView *imgView=[[UIImageView alloc]init];
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,[ipic componentsSeparatedByString:@","][i]]] ;
            [imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_img_big"]];
            //获取最后一个试图
            [self.contentScroll addSubview:imgView];
            
            imgView.frame=CGRectMake(0, i*h, SCREEN_WIDTH, h);
            
        }
        //第二个
        int aCount=(int)[apic componentsSeparatedByString:@","].count;
        for (int i=0; i<aCount; i++) {
            UIImageView *imgView=[[UIImageView alloc]init];
            //imgView.contentMode=UIViewContentModeScaleAspectFit;
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,[apic componentsSeparatedByString:@","][i]]] ;
            [imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_img_big"]];
            //获取最后一个试图
            [self.contentScroll addSubview:imgView];
            imgView.frame=CGRectMake(0, (i+iCount)*h, SCREEN_WIDTH, h);
            
        }
        
        self.contentScroll.contentSize=CGSizeMake(SCREEN_WIDTH, (iCount+aCount)*h);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
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
