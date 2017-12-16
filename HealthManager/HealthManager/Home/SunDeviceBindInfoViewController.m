//
//  SunDeviceBindInfoViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/12.
//  Copyright © 2017年 马银伟. All rights reserved.
//  显示查找的设备

#import "SunDeviceBindInfoViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunDeviceInfoModel.h"
#import "SunDeviceTableViewController.h"
@interface SunDeviceBindInfoViewController ()
@property(nonatomic,strong)UILabel *labXu;
@property(nonatomic,strong)UILabel *labChang;
@property(nonatomic,strong)UILabel *labZiType;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labXing;
@property(nonatomic,strong)UIView *changView;

@property(nonatomic,strong)UIButton *btnYan;
@property(nonatomic,strong)UITextField *textYan;
@property(nonatomic,strong)UIView *yanView;
@property(nonatomic,strong)SunDeviceInfoModel *info;
@end


//行高
#define HeightView 40
@implementation SunDeviceBindInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"设备信息";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"绑定" style: UIBarButtonItemStyleDone target:self action:@selector(bindClick)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    //顶部
    [self setUpTop];
}

-(void)setUpTop
{
    //设备名称
    UIView *nameView=[self getTypeWitLeft:@"设备名称" right:@""];
    self.labName=nameView.subviews[1];
    [self.view addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(self.view);
    }];
    //序列号
    UIView *xuView=[self getTypeWitLeft:@"设备序列号" right:@""];
    [self.view addSubview:xuView];
    self.labXu=xuView.subviews[1];
    [xuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(HeightView);
        make.top.equalTo(nameView.mas_bottom);
    }];
    //设备类别
    UIView *ziView=[self getTypeWitLeft:@"设备类别" right:@""];
    self.labZiType=ziView.subviews[1];
    [self.view addSubview:ziView];
    [ziView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(xuView.mas_height);
        make.top.equalTo(xuView.mas_bottom);
    }];
    
    //设备型号
    UIView *xingView=[self getTypeWitLeft:@"设备型号" right:@""];
    self.labXing=xingView.subviews[1];
    [self.view addSubview:xingView];
    [xingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(xuView.mas_height);
        make.top.equalTo(ziView.mas_bottom);
    }];

    //厂家
    UIView *changView=[self getTypeWitLeft:@"设备设备厂家" right:@""];
    self.changView=changView;
    self.labChang=changView.subviews[1];
    [self.view addSubview:changView];
    [changView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(xuView.mas_height);
        make.top.equalTo(xingView.mas_bottom);
    }];
    
    
    //验证码
    CGFloat yanW=100;
    UIView *yanView=[self getViewWithPlaceholder:@"验证码" isPwd:NO];
    self.yanView=yanView;
    yanView.hidden=YES;
    self.textYan=yanView.subviews[0];
    [self.view addSubview:yanView];
    [yanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(changView.mas_bottom);
        make.width.equalTo(self.view).offset(-yanW);
        make.left.equalTo(self.view);
        make.height.equalTo(nameView.mas_height);
    }];
    //验证码按钮
    UIButton *btnYan=[UIButton buttonWithType:UIButtonTypeCustom];
    btnYan.titleLabel.font=kFont(13);
    self.btnYan=btnYan;
    btnYan.hidden=YES;
    [btnYan setTitle:@"发送验证码" forState:UIControlStateNormal];
    [btnYan setBackgroundImage:[UIImage imageNamed:@"btn-angle"] forState:UIControlStateNormal];
    [btnYan setBackgroundImage:[UIImage imageNamed:@"btn-angle-disable"] forState:UIControlStateDisabled];
    
    [btnYan addTarget:self action:@selector(sendClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnYan];
    [btnYan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(yanView.mas_right);
        make.centerY.equalTo(yanView);
        make.height.equalTo(nameView.mas_height);
        make.width.mas_equalTo(yanW);
    }];
    
    //加载数据
    [self loadData];
    
}

//加载数据
-(void)loadData
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetDeviceInfo*%@",self.EquCode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        SunDeviceInfoModel *info=[SunDeviceInfoModel mj_objectWithKeyValues:json];
        self.info=info;
        self.labName.text=info.EQUNAME;
        self.labXu.text=info.EQUCODE;
        self.labZiType.text=info.EQUCATEGORY;
        self.labXing.text=info.EQUTYPE;
        self.labChang.text=info.COMPANYNO;
        //判断是否有验证码
        if (![info.CheckCode isEqualToString:@""]) {
            self.yanView.hidden=NO;
            self.btnYan.hidden=NO;
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载设备信息失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}


//发送验证码
-(void)sendClick
{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"SendDeviceCheckCode*%@",self.EquCode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //倒计时
        [self setUpBtn];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载设备信息失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

-(void)setUpBtn{
    __block int timeout=30; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.btnYan setTitle:@"发送验证码" forState:UIControlStateNormal];
                self.btnYan.enabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [self.btnYan setTitle:[NSString stringWithFormat:@"%@秒后重新发送",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                self.btnYan.enabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}


-(UIView *)getViewWithPlaceholder:(NSString *)holder isPwd:(BOOL)isPwd
{
    UIView *view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    
    CGFloat topPadding=8;
    UITextField *textField=[[UITextField alloc]init];
    if(isPwd)
    {
        textField.secureTextEntry=YES;
    }
    textField.placeholder=holder;
    textField.font=kFont(15);
    [view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.left.equalTo(view).offset(16);
        make.right.equalTo(view).offset(-16);
        make.top.equalTo(view).offset(topPadding);
        make.bottom.equalTo(view).offset(-topPadding);
    }];
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [view addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.width.equalTo(textField).offset(10);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(view);
    }];
    return view;
}

-(UIView *)getTypeWitLeft:(NSString *)left right:(NSString *)right
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
        make.top.equalTo(contentView);
        make.centerY.equalTo(contentView);
    }];
    
    
    UILabel *rightLab=[[UILabel alloc]init];
    [contentView addSubview:rightLab];
    rightLab.font=titleLab.font;
    rightLab.text=right;
    [rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
    }];
    
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [contentView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.right.equalTo(contentView).offset(-leftPadding);
        make.bottom.equalTo(contentView);
        make.height.mas_equalTo(1);
        
    }];
    
    return contentView;
}

-(void)bindClick
{
    
    if(self.btnYan.hidden)
    {
        //无验证码
        [self NoCode];
    }else
    {
        [self haveCode];
    
    }
    
}


//有验证码
-(void)haveCode
{
    if (self.textYan.text.length==0) {
        [SVProgressHUD showErrorWithStatus:@"请输入验证码"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"AddYanDevice*%@*%@*%@*%@*%@*%@*%@*%@",login.usercode,self.EquCode,self.info.EQUCATEGORY,self.info.EQUSUBTYPE,self.info.EQUTYPE,self.info.COMPANYNO,self.info.EQUNAME,self.textYan.text];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        //返回到设备管理页面
        int count=(int)self.navigationController.viewControllers.count;
        UIViewController *viewCtl = self.navigationController.viewControllers[count-3];
        [self.navigationController popToViewController:viewCtl animated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载设备信息失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
//没有验证码
-(void)NoCode{
    //加载设备信息
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"AddDevice*%@*%@*%@*%@*%@*%@*%@",login.usercode,self.EquCode,self.info.EQUCATEGORY,self.info.EQUSUBTYPE,self.info.EQUTYPE,self.info.COMPANYNO,self.info.EQUNAME];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        
        //返回到设备管理页面
        int count=(int)self.navigationController.viewControllers.count;
        UIViewController *viewCtl = self.navigationController.viewControllers[count-3];
        [self.navigationController popToViewController:viewCtl animated:YES];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载设备信息失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];


}

@end
