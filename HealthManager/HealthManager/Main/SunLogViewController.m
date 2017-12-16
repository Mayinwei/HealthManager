//
//  SunLogViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/8.
//  Copyright © 2016年 马银伟. All rights reserved.
//  登录页

#import "SunLogViewController.h"
#import "LoginTextField.h"
#import "SunTabBarController.h"
#import "AFNetworking.h"
#import "SunLogin.h"
#import "SunAccountTool.h"
#import "MD5.h"
#import "SunRegisterViewController.h"
#import "SunNavigationController.h"
#import <Hyphenate/EMSDK.h>
#import "DemoCallManager.h"
#import "SunDocTabBarController.h"
#import "AppDelegate.h"
//重力感应头文件
#import <CoreMotion/CoreMotion.h>


static const CGFloat CRMotionViewRotationMinimumTreshold = 0.1f;
static const CGFloat CRMotionGyroUpdateInterval = 1 / 100;
static const CGFloat CRMotionViewRotationFactor = 10.0;


@interface SunLogViewController ()
{
    NSTimeInterval updateInterval;
}
@property (nonatomic,strong) UITextField *logText;
@property (nonatomic,strong) UITextField *pwdText;
//背景图片
@property(nonatomic,strong)UIImageView *bgView;
//重力感应
@property (nonatomic,strong) CMMotionManager *motionManager;
@property (nonatomic, assign) CGFloat countX;
@property (nonatomic, assign) CGFloat countY;
@end

@implementation SunLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
    
   [self startMonitoring];
}

- (void)startMonitoring
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = CRMotionGyroUpdateInterval;
    }
     _motionManager.accelerometerUpdateInterval = 0.05; // 告诉manager，更新频率是100Hz
    WeakSelf(mySelf);
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable]) {
        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        
                                        CGFloat rotationRateY = gyroData.rotationRate.y;
                                        CGFloat rotationRateX = gyroData.rotationRate.x;
                            
                                       
                                        mySelf.countX +=rotationRateX;
                                        mySelf.countY +=rotationRateY;
                                        if (fabs(rotationRateX) >= CRMotionViewRotationMinimumTreshold&&fabs(rotationRateY) >= CRMotionViewRotationMinimumTreshold) {

                                            if (ABS(mySelf.countY) > CRMotionViewRotationFactor/2) {
                                                rotationRateY = 0;
                                            }
                                            if (ABS(mySelf.countX) > CRMotionViewRotationFactor/2) {
                                                rotationRateX = 0;
                                            }
                                            
                                            [UIView animateWithDuration:0.2f
                                                                  delay:0.0f
                                                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut
                                                             animations:^{
                                                                 CGPoint imgCenter=mySelf.bgView.center;
                                                                 imgCenter.x=imgCenter.x+rotationRateX;
                                                                 imgCenter.y=imgCenter.y+rotationRateY;
                                                                 mySelf.bgView.center=imgCenter;
                                                             }
                                                             completion:nil];//end animateWithDuration
                                        }
                                    }];
    }
}

-(void) setUp{
    //添加一个背景图片层
    UIImageView *bgView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"log_bg_1"]];
    bgView.frame=CGRectMake(0, 0, SCREEN_WIDTH+CRMotionViewRotationFactor*3, SCREEN_HEIGHT+CRMotionViewRotationFactor*3);
    bgView.center=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    self.bgView=bgView;
    [self.view addSubview:bgView];
    //添加遮罩层
    UIView *zV=[[UIView alloc]init];
    zV.backgroundColor =[[UIColor clearColor] colorWithAlphaComponent:0.6];
    
    zV.frame=bgView.frame;
    [self.view addSubview:zV];
    
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo)];
    
    [zV addGestureRecognizer:tapGesture];
    //设置logo
    UIImageView *logoView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(80);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    } ];
    
    //添加文本框
    UITextField *loginView=[LoginTextField fieldWithText:@"登录名/手机号/身份证号" image:@"login2" isPwd:NO];
    UITextField *pwdView=[LoginTextField fieldWithText:@"密码" image:@"pwd" isPwd:YES];
    self.logText=loginView;
    self.pwdText=pwdView;
    [self.view addSubview:loginView ];
    [self.view addSubview:pwdView ];
    //空隙
    CGFloat padding=50;
    CGFloat height=45;
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(zV.mas_centerY).centerOffset(CGPointMake(0, -50));;
        make.centerX.equalTo(zV.mas_centerX);
        make.width.equalTo(self.view).multipliedBy(0.75);
        make.height.mas_equalTo(height);
    }];
    
    [pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(loginView).with.offset(padding+8);
        make.centerX.equalTo(loginView);
        make.size.equalTo(loginView);
    }];
    
    //添加登录按钮
    UIButton *btn=[[UIButton alloc] init];
    [btn setTitle:@"登录" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
     [btn setBackgroundImage:[UIImage imageNamed:@"common_btn_hightlight"] forState:UIControlStateHighlighted];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(loginView);
        make.height.equalTo(loginView).offset(8);
        make.top.equalTo(pwdView).with.offset(padding*1.5);
        make.centerX.equalTo(loginView);
    }];
    
    [btn addTarget:self action:@selector(log) forControlEvents:UIControlEventTouchUpInside];
    
    //创建忘记密码文字
    UILabel *lab=[[UILabel alloc] init];
    lab.text=@"";
    lab.font=[UIFont systemFontOfSize:16];
    lab.textColor=[UIColor whiteColor];
    lab.textAlignment=NSTextAlignmentCenter;
    [self.view addSubview:lab];
    
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(btn);
        make.top.equalTo(btn).offset(padding);
        make.left.equalTo(zV).offset(padding);
    }];
    //添加分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=[UIColor grayColor];
    [self.view addSubview:cutView];
    CGFloat botPadding=50;
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(btn);
        make.height.mas_equalTo(2);
        make.bottom.equalTo(zV).offset(-botPadding);
        make.centerX.equalTo(self.view);
    }];
    
    //创建忘记密码文字
    UILabel *labRe=[[UILabel alloc] init];
    labRe.text=@"点击注册账号";
    labRe.textColor=[UIColor whiteColor];
    labRe.font=[UIFont systemFontOfSize:16];
    labRe.textAlignment=NSTextAlignmentCenter;
    labRe.userInteractionEnabled=YES;
    UITapGestureRecognizer*tapRegiser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(registerClick)];
    
    [labRe addGestureRecognizer:tapRegiser];
    [self.view addSubview:labRe];
    
    [labRe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(cutView);
        make.height.mas_equalTo(40);
        make.top.equalTo(cutView.mas_bottom);
        make.centerX.equalTo(cutView);
    }];

}
-(void)registerClick
{
    SunRegisterViewController *reg=[[SunRegisterViewController alloc]init];
    //转场动画
    [reg setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:reg animated:YES completion:nil];
}

-(void)Actiondo
{
    //隐藏键盘
    [self.logText resignFirstResponder];
    [self.pwdText resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden=YES;
    
}


-(void)log{
    //隐藏键盘
    [self.view endEditing:YES];
    //判断是否填写数据
    if (self.logText.text.length==0){
        [SVProgressHUD showErrorWithStatus:@"请输入账号"];
        return ;
    }
    if (self.pwdText.text.length==0) {
        [SVProgressHUD showErrorWithStatus:@"请输入密码"];
        return ;
    }
    
    
    //AFN 管理网络
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    NSString *loginName=[self.logText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    dic[@"LoginName"]=loginName;
    dic[@"Password"]= [MD5 getmd5WithString:self.pwdText.text] ;
    //读取dev_token
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    NSString *token=[userDefault objectForKey:@"deviceToken"];
    //NSLog(@"access_token=%@",token);
    if ([token isEqualToString:@""]|| token==nil) {
         dic[@"dev_token"]=@"";
    }else{
         dic[@"dev_token"]=token;
    }
    
    [manager GET:MyURL parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
            [SVProgressHUD show];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [SVProgressHUD dismiss];
        //字典转模型
        SunLogin *login= [SunLogin accessTokenWithDic:responseObject];
        if([login.usercode isEqualToString:@"no"])
        {
            [SVProgressHUD showErrorWithStatus:@"账号或密码错误"];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            self.pwdText.text=@"";
            return;
        }
        //数据持久化
        [SunAccountTool saveSunLogin:login];
        //环信登录
        [self HuanXinFunctionWithType:login.type];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"登录失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    
    
    
    
    
}

//环信相关方法
-(void)HuanXinFunctionWithType:(NSString *)type{
    //判断是否自动登录
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (!isAutoLogin) {
        //获取自己的usercode作为登录名称
        SunLogin *login=[SunAccountTool getAccount];
        NSString *pwd=HuanPwd;
        EMError *error = [[EMClient sharedClient] loginWithUsername:login.usercode  password:pwd];
        if (error.code==EMErrorUserNotFound) {
            //用户不存在，进行注册
            EMError *regError =[[EMClient sharedClient] registerWithUsername:login.usercode password:pwd];
            if (regError==nil) {
                [[EMClient sharedClient] loginWithUsername:login.usercode  password:pwd];
                [[EMClient sharedClient].options setIsAutoLogin:YES];
            }
        }else if(error==nil)
        {
            //登录成功
            [[EMClient sharedClient].options setIsAutoLogin:YES];
        }
    }
    UITabBarController *tab=nil;
    if ([type isEqualToString:@"个人用户"]) {
        tab=  [[SunTabBarController alloc] init];
    }else{
        tab=  [[SunDocTabBarController alloc] init];
    }
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [[DemoCallManager sharedManager] setMainController:tab];
    app.mainViewController=tab;
    self.view.window.rootViewController=tab;
}
@end
