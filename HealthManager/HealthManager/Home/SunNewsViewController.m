//
//  SunNewsViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/11.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunNewsViewController.h"
#import "SunNewsView.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"

@interface SunNewsViewController ()
@property(nonatomic,strong)SunNewsView *att;
@property(nonatomic,strong)SunNewsView *healthView;
@end

@implementation SunNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background_white"] forBarMetrics:UIBarMetricsDefault];
    self.navigationItem.title=@"消息";
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    //[btn setBackgroundImage:[UIImage imageNamed:@"foward-left"] forState:UIControlStateNormal];
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    //21 125 251
    UIColor *titlec=MrColor(33, 135, 244);
    [btn setTitleColor:titlec forState:UIControlStateNormal];
    btn.frame=(CGRect){CGPointZero,CGSizeMake(50, 22)};
    [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self setUpContro];
    
    [self loadData];
}


-(void)setUpContro
{
    //添加内容
    SunNewsView *setting=[SunNewsView sunNewsWithImage:@"config" firseTitle:@"系统消息" secondTitle:@"暂无新消息"];
    CGFloat sW=[UIScreen mainScreen].bounds.size.width;
    //行间距
    CGFloat padding=10;
    //setting.frame=CGRectMake(0, padding, sW, 60);
    [self.view addSubview:setting];
    [setting mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(sW);
        make.height.mas_equalTo(60);
        make.top.equalTo(self.view).offset(64+padding);
    }];
    //关注
    UITapGestureRecognizer *tapAtt=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(attentionClick)];
    SunNewsView *att=[SunNewsView sunNewsWithImage:@"compas" firseTitle:@"关注信息" secondTitle:@"暂无消息"];
    self.att=att;
    [self.view addSubview:att];
    [att addGestureRecognizer:tapAtt];
    [att mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(setting);
        make.size.equalTo(setting);
        make.top.equalTo(setting.mas_bottom).offset(padding);
    }];
    //订单
    SunNewsView *order=[SunNewsView sunNewsWithImage:@"file" firseTitle:@"我的订单" secondTitle:@"暂无订单"];
    [self.view addSubview:order];
    [order mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(att);
        make.size.equalTo(att);
        make.top.equalTo(att.mas_bottom).offset(padding);
    }];
    order.hidden=YES;
    //健康建议
    UITapGestureRecognizer *tapHealth=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(healthClick)];
    SunNewsView *health=[SunNewsView sunNewsWithImage:@"statistics" firseTitle:@"健康建议" secondTitle:@"暂无消息"];
    self.healthView=health;
    [health addGestureRecognizer:tapHealth];
    [self.view addSubview:health];
    [health mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(att);
        make.size.equalTo(att);
        make.top.equalTo(att.mas_bottom).offset(padding);
    }];

}

-(void)healthClick
{
    //发送通知进行跳转
    [self dismissViewControllerAnimated:YES completion:nil];
    //创建个通知
    NSDictionary *dic=[NSDictionary dictionaryWithObject:@"SunSuggestTableViewController" forKey:@"Info"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SunHomeViewController" object:self userInfo:dic];

}

//关注跳转
-(void)attentionClick
{
    //发送通知进行跳转
    [self dismissViewControllerAnimated:YES completion:nil];
    //创建个通知
    NSDictionary *dic=[NSDictionary dictionaryWithObject:@"SunAttentionRequestTableViewController" forKey:@"Info"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SunHomeViewController" object:self userInfo:dic];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:15],
       
       
       NSForegroundColorAttributeName:[UIColor blackColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



//加载数据
-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetNotification*%@",login.usercode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //判断之前是否添加过
        if (![[json[@"GuanNum"] copy] isEqualToString:@"0"]) {
            //添加未读标记
            UIView *redView=[[UIView alloc]init];
            redView.backgroundColor=[UIColor redColor];
            redView.layer.cornerRadius=3.5;
            redView.layer.masksToBounds=YES;
            [self.att addSubview:redView];
            [redView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.att.subviews[0]);
                make.bottom.equalTo(self.att.subviews[0]);
                make.width.mas_equalTo(7);
                make.height.mas_equalTo(7);
            }];
            UILabel *lab=self.att.subviews[2];
            lab.text=@"有新消息";
        }
        //判断之前是否添加过
        if (![[json[@"ZhuanNum"] copy] isEqualToString:@"0"]) {
            //添加未读标记
            UIView *redView=[[UIView alloc]init];
            redView.backgroundColor=[UIColor redColor];
            redView.layer.cornerRadius=3.5;
            redView.layer.masksToBounds=YES;
            [self.healthView addSubview:redView];
            [redView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.att.subviews[0]);
                make.bottom.equalTo(self.att.subviews[0]);
                make.width.mas_equalTo(5);
                make.height.mas_equalTo(5);
            }];
            UILabel *lab=self.healthView.subviews[2];
            lab.text=@"有新消息";
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];


}




@end
