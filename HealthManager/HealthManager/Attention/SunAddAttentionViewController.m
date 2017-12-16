//
//  SunAddAttentionViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//  添加关注

#import "SunAddAttentionViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"


@interface SunAddAttentionViewController ()
@property(nonatomic,strong)UIButton *addBtn;
@property(nonatomic,strong)UITextField *nameText;
@property(nonatomic,strong)UITextField *cartText;
@end

@implementation SunAddAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"添加关注";
    self.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    //添加控件
    [self setUpContrl];
    //判断是否是扫码进来的
    if (![self.text isEqualToString:@""]&&self.text!=nil) {
        self.cartText.text=[self.text componentsSeparatedByString:@","][1];
        self.nameText.text=[self.text componentsSeparatedByString:@","][0];
        self.addBtn.enabled=YES;
        
    }
}
-(void)setUpContrl
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped)];
    
    [self.view addGestureRecognizer:singleTap];
    
    UIView *nameView=[self getTextFieldTypeWithTitle:@"姓名"];
    [self.view addSubview:nameView];
    self.nameText=nameView.subviews[1];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.top.equalTo(self.view).offset(8);
    }];
    
    UIView *cartView=[self getTextFieldTypeWithTitle:@"身份证"];
    [self.view addSubview:cartView];
    self.cartText=cartView.subviews[1];
    [cartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(nameView);
        make.top.equalTo(nameView.mas_bottom);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.nameText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.cartText];
    
    //按钮
    CGFloat leftPadding=8;
    UIButton *addBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addBtn];
    self.addBtn=addBtn;
    addBtn.enabled=NO;
    [addBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"common_btn_disable"] forState:UIControlStateDisabled];
    addBtn.titleLabel.font=kFont(15);
    [addBtn addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding);
        make.right.equalTo(self.view).offset(-leftPadding);
        make.height.height.mas_equalTo(40);
        make.top.equalTo(cartView.mas_bottom).offset(20);
    }];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)TextInput
{
    if (self.nameText.text.length!=0&&self.cartText.text.length!=0) {
        self.addBtn.enabled=YES;
    }else{
        self.addBtn.enabled=NO;
    }
}
//查找
-(void)searchClick
{
//    if (self.cartText.text.length<=15) {
//        //15位
//        NSString *regex = @"/^[1-9]\d{7}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}$/";
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//        if(![pred evaluateWithObject: self.cartText.text])
//        {
//            [SVProgressHUD showErrorWithStatus:@"身份证格式不正确"];
//            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
//            return ;
//        }
//    }else{
//        //18位
//        NSString *regex = @"/^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{4}$/";
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//        if(![pred evaluateWithObject: self.cartText.text])
//        {
//            [SVProgressHUD showErrorWithStatus:@"身份证格式不正确"];
//            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
//            return ;
//        }
//    }
    
    
//    BOOL isTure =[self checkUserIdCard:self.cartText.text];
//    if (!isTure) {
//        [SVProgressHUD showErrorWithStatus:@"身份证格式不正确"];
//        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
//        return ;
//    }李四
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"InsertAttention*%@*%@*%@",login.usercode,self.cartText.text,self.nameText.text];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"消息已发出"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"操作失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

#pragma 正则匹配用户身份证号15或18位
- (BOOL)checkUserIdCard: (NSString *) idCard
{
    NSString *pattern = @"(^[0-9]{15})|([0−9]17([0−9]|X))";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCard];
    return isMatch;
}

//生成右边为文本框的视图
-(UIView *)getTextFieldTypeWithTitle:(NSString *)title
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
    text.placeholder=@"请输入";
    text.font=titleLab.font;
    text.textAlignment=NSTextAlignmentRight;
    text.borderStyle=UITextBorderStyleNone;
    [contentView addSubview:text];
    [text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
        make.height.equalTo(contentView).multipliedBy(0.7);
        make.width.mas_equalTo(200);
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


-(void)fingerTapped
{
    [self.view endEditing:YES];
}

@end
