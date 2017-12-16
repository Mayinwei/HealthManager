//
//  SunInsertBloodDataViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/6.
//  Copyright © 2017年 马银伟. All rights reserved.
//  血压录入

#import "SunInsertBloodDataViewController.h"
#import "MrDatePicker.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"
#import "Chameleon.h"



@interface SunInsertBloodDataViewController ()<UITextFieldDelegate,MrDatePickerDelegate>

typedef enum ShowType{
    //右边是文本框类型
    ShowTextFieldType=0,
    //右边是时间类型
    ShowTimeType
}ShowType;

@property(nonatomic,strong)UIScrollView *scrollContent;
@property(nonatomic,strong)UILabel *timeLable;
@property(nonatomic,strong)UIButton *button;
//文本框
@property(nonatomic,strong)UITextField *higText;
@property(nonatomic,strong)UITextField *lowText;
@property(nonatomic,strong)UITextField *rateText;
//时间
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UILabel *dateLab;
@end

@implementation SunInsertBloodDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    self.navigationItem.title=@"血压录入";
    [self setUpContent];
}

-(void)setUpContent
{
    UIScrollView *scrollContent=[[UIScrollView alloc]init];
    self.scrollContent=scrollContent;
    scrollContent.showsVerticalScrollIndicator=NO;
    scrollContent.backgroundColor=MrColor(230, 230, 230);
    scrollContent.contentSize=CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    scrollContent.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    [self.view addSubview:scrollContent];
    
    self.scrollContent.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    
    [self.scrollContent addGestureRecognizer:singleTap];
    UIView *higView=[self getTextFieldTypeWithTitle:@"收缩压 (高压)" unit:@"mmHg"];
    [scrollContent addSubview:higView];
    self.higText=higView.subviews[2];
    [higView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollContent);
        make.left.equalTo(self.scrollContent);
        make.top.equalTo(self.scrollContent).offset(4);
        make.height.mas_equalTo(40);
    }];
    
    UIView *lowView=[self getTextFieldTypeWithTitle:@"舒张压 (低压)" unit:@"mmHg"];
    self.lowText=lowView.subviews[2];
    [scrollContent addSubview:lowView];
    [lowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollContent);
        make.left.equalTo(self.scrollContent);
        make.top.equalTo(higView.mas_bottom);
        make.height.equalTo(higView);
    }];
    
    UIView *rateView=[self getTextFieldTypeWithTitle:@"心率" unit:@"bpm"];
    self.rateText=rateView.subviews[2];
    [scrollContent addSubview:rateView];
    [rateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollContent);
        make.left.equalTo(self.scrollContent);
        make.top.equalTo(lowView.mas_bottom);
        make.height.equalTo(higView);
    }];
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *date=[dateFormatter stringFromDate:[NSDate date]];
    //注册通知监听文本框变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.higText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.lowText];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.rateText];
    //日期
    UIView *dateView=[self getTimeTypeWitTtile:@"测量日期" time:[date componentsSeparatedByString:@" "][0]];
    self.dateLab=dateView.subviews[2];
    [scrollContent addSubview:dateView];
    [dateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollContent);
        make.left.equalTo(self.scrollContent);
        make.top.equalTo(rateView.mas_bottom);
        make.height.equalTo(higView);
    }];
    //时间
    UIView *timeView=[self getTimeTypeWitTtile:@"测量时间" time:[date componentsSeparatedByString:@" "][1]];
    self.timeLab=timeView.subviews[2];
    [scrollContent addSubview:timeView];
    [timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.scrollContent);
        make.left.equalTo(self.scrollContent);
        make.top.equalTo(dateView.mas_bottom);
        make.height.equalTo(higView);
    }];
    
    //添加保存按钮
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    self.button=button;
    button.enabled=NO;
    [button setTitle:@"保 存" forState:UIControlStateNormal];
    button.titleLabel.font=kFont(15);
    [button setBackgroundImage:[UIImage imageNamed:@"btn-angle"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn-angle-disable"] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(saveClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-1);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(39);
    }];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer

{
    
    [self.scrollContent endEditing:YES];
}

//生成右边为文本框的视图
-(UIView *)getTextFieldTypeWithTitle:(NSString *)title unit:(NSString *)unit
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
    //单位
    UILabel *unitLab=[[UILabel alloc]init];
    unitLab.text=unit;
    unitLab.font=titleLab.font;
    [contentView addSubview:unitLab];
    [unitLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.height.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
    //文本框
    UITextField *text=[[UITextField alloc]init];
    text.placeholder=@"请输入";
    text.delegate=self;
    text.font=titleLab.font;
    text.textAlignment=NSTextAlignmentRight;
    text.borderStyle=UITextBorderStyleNone;
    //[text becomeFirstResponder];
    text.keyboardType=UIKeyboardTypeNumberPad;
    [contentView addSubview:text];
    [text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(unitLab.mas_left).offset(-2);
        make.centerY.equalTo(unitLab);
        make.height.equalTo(contentView).multipliedBy(0.7);
        make.width.mas_equalTo(60);
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



-(UIView *)getTimeTypeWitTtile:(NSString *) title time:(NSString *)time
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
    //箭头图表
    UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-right"]];
    [contentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
        make.height.equalTo(contentView).multipliedBy(0.5);
        make.width.equalTo(imgView.mas_height);
    }];
    //时间
    UILabel *timeLab=[[UILabel alloc]init];
    timeLab.userInteractionEnabled=YES;
    timeLab.text=time;
    timeLab.font=titleLab.font;
    timeLab.textColor=MrColor(180, 180, 180);
    [contentView addSubview:timeLab];
    [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(imgView.mas_left);
        make.height.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
    UITapGestureRecognizer *dateTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dateClick:)];
    [timeLab addGestureRecognizer:dateTap];
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
#pragma mark -- 文本框协议
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;
    
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > 3) {
        return NO;
    }
    return YES;
}
//手势方法
-(void)dateClick:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    self.timeLable=(UILabel *)tap.view;
    MrDatePicker *datePicker=[[MrDatePicker alloc]init];
    datePicker.delegate=self;
    if([self.timeLable.text length]<=5)
    {
        datePicker.pickerModel=@"UIDatePickerModeTime";
    }
    datePicker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-66);
    [self.view addSubview:datePicker];
}
#pragma  mark --时间选择协议
-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    if([self.timeLable.text length]>5)
    {
        self.timeLable.text=[time componentsSeparatedByString:@" "][0];
    }else{
        //时间
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *data=[dateFormatter dateFromString:time];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *dataString=[dateFormatter stringFromDate:data];
        self.timeLable.text=[dataString componentsSeparatedByString:@" "][1];
    }
}

//保存
-(void)saveClick
{
    NSString *regex = @"[0-9]*[1-9][0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if(![pred evaluateWithObject: self.higText.text]||![pred evaluateWithObject: self.lowText.text]||![pred evaluateWithObject: self.rateText.text])
    {
        [SVProgressHUD showErrorWithStatus:@"输入必须是数字"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return ;
    }
    //判断范围
    if([self.higText.text floatValue]>30&&[self.higText.text floatValue]<300)
    {
        [SVProgressHUD showErrorWithStatus:@"收缩压输入不合理"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    
    if([self.lowText.text floatValue]>30&&[self.lowText.text floatValue]<300)
    {
        [SVProgressHUD showErrorWithStatus:@"舒张压输入不合理"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    
    if([self.rateText.text floatValue]>30&&[self.rateText.text floatValue]<200)
    {
        [SVProgressHUD showErrorWithStatus:@"心率输入不合理"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    
    
    
    NSString *time=[NSString stringWithFormat:@"%@ %@:00.000",self.dateLab.text,self.timeLab.text];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    SunLogin *login=[SunAccountTool getAccount];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"insertBP*%@*%@*%@*%@**%@",login.usercode,self.higText.text,self.lowText.text,self.rateText.text,time];
    
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
        [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"录入数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}
-(void)TextInput
{
    if (self.higText.text.length!=0&&self.lowText.text.length!=0&&self.rateText.text.length!=0) {
        self.button.enabled=YES;
    }else{
        self.button.enabled=NO;
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
