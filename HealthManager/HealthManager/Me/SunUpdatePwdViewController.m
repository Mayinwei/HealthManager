//
//  SunUpdatePwdViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunUpdatePwdViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunLogViewController.h"
#import "MD5.h"

@interface SunUpdatePwdViewController ()
@property(nonatomic,strong)UITextField *oldText;
@property(nonatomic,strong)UITextField *Text1;
@property(nonatomic,strong)UITextField *Text2;
@property(nonatomic,strong)UIButton *btn;
@end

@implementation SunUpdatePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=MrColor(230, 230, 230);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
    [self.view addGestureRecognizer:tap];
    
    CGFloat topPadding=10;
    UIView *oldView=[self getTextFieldTypeWithTitle:@"旧密码" placeholder:@"请输入旧密码"];
    self.oldText=oldView.subviews[1];
    [self.view addSubview:oldView];
    [oldView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topPadding);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    UIView *newView1=[self getTextFieldTypeWithTitle:@"新密码" placeholder:@"请输入新密码"];
    self.Text1=newView1.subviews[1];
    [self.view addSubview:newView1];
    [newView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(oldView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(oldView);
    }];
    
    UIView *newView2=[self getTextFieldTypeWithTitle:@"确认新密码" placeholder:@"请输入再次输入"];
    [self.view addSubview:newView2];
    self.Text2=newView2.subviews[1];
    [newView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(newView1.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(oldView);
    }];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn=btn;
    btn.enabled=NO;
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn_disable"] forState:UIControlStateDisabled];
    [btn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(5);
        make.right.equalTo(self.view).offset(-5);
        make.top.equalTo(newView2.mas_bottom).offset(30);
        make.height.mas_equalTo(40);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.oldText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.Text1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.Text2];
}

-(void)TextInput
{
    if (self.Text1.text.length>0&&self.Text2.text.length>0&&self.oldText.text.length>0) {
        self.btn.enabled=YES;
    }
}

-(void)completeClick
{
    //判断两次密码是否输入一样
    if (![self.Text1.text isEqualToString:self.Text2.text]) {
        [SVProgressHUD showErrorWithStatus:@"两次密码输入不一致"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    
    dic[@"parma"]=[NSString stringWithFormat:@"UpdatePASSWORD*%@*%@*%@",login.usercode,[MD5 getmd5WithString:self.oldText.text],[MD5 getmd5WithString:self.Text1.text]];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"修改成功,请重新登录"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        //删除登录文件
        [self deleteFile];
        self.view.window.rootViewController=[[SunLogViewController alloc] init];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    
}

-(void)deleteFile
{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    //文件名
    NSString *path=[doc stringByAppendingPathComponent:@"account.data"];
   [fileManager removeItemAtPath:path error:nil];
}

-(void)viewClick
{
    [self.view endEditing:YES];
}

//生成右边为文本框的视图
-(UIView *)getTextFieldTypeWithTitle:(NSString *)title placeholder:(NSString *)placeholder
{
    //添加内容
    UIView *contentView=[[UIView alloc]init];
    contentView.backgroundColor=[UIColor whiteColor];
    //左右间距
    CGFloat leftPadding=16;
    UILabel *titleLab=[[UILabel alloc]init];
    titleLab.text=title;
    titleLab.font=kFont(13);
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.height.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
    //文本框
    UITextField *text=[[UITextField alloc]init];
    text.secureTextEntry=YES;
    text.placeholder=placeholder;
    text.font=titleLab.font;
    text.textAlignment=NSTextAlignmentRight;
    text.borderStyle=UITextBorderStyleNone;
    [contentView addSubview:text];
    [text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
        make.height.equalTo(contentView).multipliedBy(0.7);
        make.left.equalTo(titleLab.mas_left).offset(20);
    }];
    //添加分隔线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [contentView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.right.equalTo(contentView).offset(-leftPadding);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(contentView);
    }];
    return contentView;
}


@end
