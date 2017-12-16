//
//  SunDeviceBindiewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunDeviceBindiewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunDeviceBindInfoViewController.h"
@interface SunDeviceBindiewController ()
@property(nonatomic,strong)UITextField *text;
@property(nonatomic,strong)UIButton *btn;
@end

@implementation SunDeviceBindiewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=MrColor(240, 240, 240);
    self.navigationItem.title=@"绑定设备";
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    
    
    //查询按钮
    //按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn=btn;
    [btn setTitle:@"查询" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn_disable"] forState:UIControlStateDisabled];
    [self.view addSubview:btn];
    btn.enabled=NO;
    btn.titleLabel.font=kFont(15);
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(2);
        make.right.equalTo(self.view).offset(-2);
        make.bottom.equalTo(self.view).offset(-2);
        make.height.mas_equalTo(45);
    }];
    [btn addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    
    //注册通知
    //注册通知用于接收扫码传递
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scanFun:) name:@"SunDeviceBindiewController" object:nil];
    
    UIView *searView=[self getTypeWitLeft:@"设备序列号"];
    [self.view addSubview:searView];
    [searView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(3);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped)];
    
    [self.view addGestureRecognizer:singleTap];
}

//通知事件
-(void)scanFun:(NSNotification *)not
{
    if ([not.userInfo[@"Info"] rangeOfString:@"NoFound"].location !=NSNotFound) {
        NSString *SugarDev=[not.userInfo[@"Info"] componentsSeparatedByString:@"*"][1];
        self.text.text=SugarDev;
        self.btn.enabled=YES;
    }else{
    
        self.text.text=not.userInfo[@"Info"];
        self.btn.enabled=YES;
    }
}

-(void)fingerTapped
{
    [self.view endEditing:YES];
}

-(UIView *)getTypeWitLeft:(NSString *)left
{
    //添加内容
    UIView *contentView=[[UIView alloc]init];
    contentView.backgroundColor=[UIColor whiteColor];
    //左右间距
    CGFloat leftPadding=16;
    UILabel *titleLab=[[UILabel alloc]init];
    titleLab.text=left;
    titleLab.font=kFont(15);
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.centerY.equalTo(contentView);
    }];
    [titleLab setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    //设置label1的content compression 为1000
    [titleLab setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan"]];
    imgView.contentMode=UIViewContentModeScaleToFill;
    [contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-10);
        make.top.equalTo(contentView).offset(8);
        make.bottom.equalTo(contentView).offset(-8);
        make.width.equalTo(imgView.mas_height);
    }];
    UITapGestureRecognizer *imgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick)];
    imgView.userInteractionEnabled=YES;
    [imgView addGestureRecognizer:imgTap];
    //文本框
    UITextField *text=[[UITextField alloc]init];
    //扫码赋值
    if (self.EquCode!=nil&&![self.EquCode isEqualToString:@""]) {
        text.text=self.EquCode;
        self.btn.enabled=YES;
    }
    self.text=text;
    text.placeholder=@"请输入设备序列号";
    text.font=kFont(15);
    [contentView addSubview:text];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange) name:UITextFieldTextDidChangeNotification object:text];
    [text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLab.mas_right).offset(10);
        make.right.equalTo(imgView.mas_left);
        make.height.equalTo(imgView);
        make.centerY.equalTo(imgView);
    }];
    return contentView;
}
-(void)textChange
{
    if (self.text.text.length!=0) {
        self.btn.enabled=YES;
    }else{
        self.btn.enabled=NO;
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)imgClick
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"SunDeviceBindiewController" forKey:@"NotificationName"];
    //设置同步
    [defaults synchronize];
    
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"QRCodeViewController" bundle:nil];
    //初始化
    UIViewController *vc= sb.instantiateInitialViewController;
    [self.navigationController presentViewController:vc animated:YES completion:nil ];
}
//查找
-(void)searchClick
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"ValidationDeviceTrue*%@",self.text.text];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        SunDeviceBindInfoViewController *info=[[SunDeviceBindInfoViewController alloc]init];
        info.EquCode=self.text.text;
        [self.navigationController pushViewController:info animated:YES];
        //清空文本框
        self.text.text=@"";
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}



@end
