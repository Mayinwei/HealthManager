//
//  SunMedicalViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMedicalViewController.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"


@interface SunMedicalViewController ()
@property(nonatomic,strong)UITextView *jiaTextView;
@property(nonatomic,strong)UITextView *jiTextView;
@property(nonatomic,strong)UITextView *naoTextView;
@property(nonatomic,strong)UIScrollView *contentView;
@end

@implementation SunMedicalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style: UIBarButtonItemStyleDone target:self action:@selector(upateInfo)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
    [self.view addGestureRecognizer:tap];
    //添加滚动
    UIScrollView *contentView=[[UIScrollView alloc]init];
    self.contentView=contentView;
    [self.view addSubview:contentView];
    contentView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    CGFloat topPadding=10;
    CGFloat height=160;
    //添加控件
    UIView *jiaView=[self viewWithTitle:@"家族病史"];
    self.jiaTextView=jiaView.subviews[1];
    [contentView addSubview:jiaView];
    jiaView.frame=CGRectMake(0, 0, SCREEN_WIDTH, height);
    //既往病史
    UIView *jiView=[self viewWithTitle:@"既往病史"];
    self.jiTextView=jiView.subviews[1];
    [contentView addSubview:jiView];
    jiView.frame=CGRectMake(0, CGRectGetMaxY(jiaView.frame)+topPadding, SCREEN_WIDTH, height);

    //脑卒中
    UIView *naoView=[self viewWithTitle:@"脑卒中病"];
    self.naoTextView=naoView.subviews[1];
    [contentView addSubview:naoView];
    naoView.frame=CGRectMake(0, CGRectGetMaxY(jiView.frame)+topPadding, SCREEN_WIDTH, height);
    contentView.contentSize=CGSizeMake(SCREEN_WIDTH, CGRectGetMaxY(naoView.frame)+topPadding*2);
    //禁用
    [self DisableText];
    //加载数据
    [self loadData];
    
    
    //监听键盘滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//键盘出现
-(void)keyboardWillShow:(NSNotification *)notifi
{
    
    NSDictionary *userInfo = [notifi userInfo];
    NSValue* aValue        = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect= [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGFloat margin = 20;//文本框距键盘顶边最小距离
    CGFloat scrollY=0;
    [self.view layoutIfNeeded];
    //判断既往病史是否是第一响应者
    if([self.jiTextView isFirstResponder])
    {
        //获取最大Y值
        scrollY=keyboardTop-margin-320;
    }else if([self.naoTextView isFirstResponder])
    {
        scrollY=keyboardTop-480-margin-20;
        
    }
    if(scrollY<0)
    {
       // [[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
        CGFloat duration=[[[notifi userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView setAnimationCurve:[[[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView animateWithDuration:duration animations:^{
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, scrollY,0);
            self.contentView.contentInset= insets;
            self.contentView.contentOffset=CGPointMake(0, -scrollY);
        }];
    }
}
//键盘消失
-(void)keyboardWillHide:(NSNotification *)notifi
{
    
    CGFloat duration=[[[notifi userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView setAnimationCurve:[[[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0,0);
        self.contentView.contentInset= insets;
        self.contentView.contentOffset=CGPointMake(0, 0);
    }];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewClick
{
    [self.view endEditing:YES];
    
}

-(UIView *)viewWithTitle:(NSString *)title
{

    UIView *view=[[UIView alloc]init];
    
    UILabel *lab=[[UILabel alloc]init];
    lab.text=title;
    lab.font=kFont(14);
    [view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view).offset(5);
        make.left.equalTo(view).offset(20);
    }];
    
    //文本框
    UITextView *textView=[[UITextView alloc]init];
    textView.font=lab.font;
    [view addSubview:textView];
    UIColor *color=MrColor(210, 210, 210);
    textView.layer.borderColor = color.CGColor;
    textView.layer.borderWidth =1.5;
    textView.layer.cornerRadius =5.0;
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab.mas_bottom).offset(5);
        make.left.equalTo(lab);
        make.right.equalTo(view).offset(-20);
        make.bottom.equalTo(view);
    }];
    
    return view;
}

//禁用所有文本框
-(void)DisableText
{

    [self.jiaTextView setEditable:NO];
    [self.jiTextView setEditable:NO];
    [self.naoTextView setEditable:NO];
}

-(void)AbleText
{
    [self.jiaTextView setEditable:YES];
    [self.jiTextView setEditable:YES];
    [self.naoTextView setEditable:YES];
}

-(void)upateInfo
{
    //启用
    [self AbleText];
    [self.jiaTextView becomeFirstResponder];
    //修改标题
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
    {
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        //获取账户信息
        SunLogin *login=[SunAccountTool getAccount];
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        dic[@"access_token"]=login.access_token;
        dic[@"parma"]=[NSString stringWithFormat:@"UpdateMedicalHistoryInfo*%@*%@*%@*%@",login.usercode,self.jiaTextView.text,self.jiTextView.text,self.naoTextView.text];
        [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
            //判断是否有错误
            SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
            if (errorModel.error!=nil) {
                [SVProgressHUD showErrorWithStatus:errorModel.msg];
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
                [SVProgressHUD dismissWithDelay:2.0];
                return;
            }
            //禁用
            [self DisableText];
            self.navigationItem.rightBarButtonItem.title=@"编辑";
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:@"操作失败"];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
        }];
    }
    self.navigationItem.rightBarButtonItem.title=@"保存";
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMedicalInfo*%@",login.usercode];
    
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
        self.jiTextView.text=[json[@"MEDHISTORY"] copy];
        self.jiaTextView.text=[json[@"FAMEDHISTORY"] copy];
        self.naoTextView.text=[json[@"STROKEDISEASE"] copy];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

@end
