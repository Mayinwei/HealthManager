//
//  SunAddPlanViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//  添加计划

#import "SunAddPlanViewController.h"
#import "PKYStepper.h"
#import "MrDatePicker.h"
#import "MrPicker.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"

@interface SunAddPlanViewController ()<UITextFieldDelegate,MrDatePickerDelegate,MrPickerDelegate>
@property(nonatomic,strong)UITextField *timeText;
@property(nonatomic,strong)UITextField *nameText;
@property(nonatomic,strong)UITextField *waysText;
@property(nonatomic,strong)UITextField *unitText;
@property(nonatomic,strong)UITextField *middleText;
@property(nonatomic,strong)PKYStepper *setpper;
@end

@implementation SunAddPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"添加计划";
    self.view.backgroundColor=[UIColor whiteColor];
    
    
    //添加顶部控件
    [self setUpTop];
}

-(void)setUpTop
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped)];
    
    [self.view addGestureRecognizer:singleTap];
    
    CGFloat leftPadding=13;
    //时间
    UITextField *timeText=[[UITextField alloc]init];
    self.timeText=timeText;
    timeText.borderStyle=UITextBorderStyleRoundedRect;
    timeText.font=kFont(16);
    timeText.placeholder=@"请选择用药时间";
    timeText.delegate=self;
    [self.view addSubview:timeText];
    [timeText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.left.equalTo(self.view).offset(leftPadding);
        make.right.equalTo(self.view).offset(-leftPadding);
        make.height.mas_equalTo(38);
    }];
    //药品名称
    UITextField *nameText=[[UITextField alloc]init];
    self.nameText=nameText;
    nameText.delegate=self;
    nameText.placeholder=@"请输入药品名称";
    nameText.borderStyle=UITextBorderStyleRoundedRect;
    nameText.font=timeText.font;
    [self.view addSubview:nameText];
    [nameText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timeText.mas_bottom).offset(8);
        make.centerX.equalTo(timeText);
        make.size.equalTo(timeText);
    }];
    
    //服用方式
    UITextField *waysText=[[UITextField alloc]init];
    self.waysText=waysText;
    waysText.delegate=self;
    waysText.placeholder=@"请选择服用方式";
    waysText.borderStyle=UITextBorderStyleRoundedRect;
    waysText.font=timeText.font;
    [self.view addSubview:waysText];
    [waysText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameText.mas_bottom).offset(8);
        make.centerX.equalTo(timeText);
        make.size.equalTo(timeText);
    }];
    //剂量
    UILabel *labTitle=[[UILabel alloc]init];
    labTitle.text=@"用药剂量:";
    //labTitle.textColor=[UIColor lightGrayColor];
    labTitle.font=timeText.font;
    [self.view addSubview:labTitle];
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(timeText).offset(4);
        make.height.equalTo(timeText);
        make.top.equalTo(waysText.mas_bottom).offset(8);
    }];
    PKYStepper *setpper=[[PKYStepper alloc]init];
    self.setpper=setpper;
    setpper.value=1;
    setpper.minimum=1;
    UIColor *color=MrColor(33, 135, 244);
    setpper.valueChangedCallback=^(PKYStepper *stepper, float count) {
        stepper.countLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    };
    [setpper setLabelTextColor:color];
    [setpper setButtonTextColor:color forState:UIControlStateNormal];
    [setpper setBorderColor:color];
    [setpper setup];
    [self.view addSubview:setpper];
    [setpper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labTitle.mas_right).offset(8);
        make.height.equalTo(labTitle);
        make.centerY.equalTo(labTitle);
        make.width.mas_equalTo(150);
    }];
    //剂量
    //服用方式
    UITextField *unitText=[[UITextField alloc]init];
    self.unitText=unitText;
    unitText.textColor=[UIColor blackColor];
    unitText.delegate=self;
    unitText.textAlignment=NSTextAlignmentCenter;
    unitText.placeholder=@"片";
    unitText.borderStyle=UITextBorderStyleRoundedRect;
    unitText.font=timeText.font;
    [self.view addSubview:unitText];
    [unitText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(setpper);
        make.left.equalTo(setpper.mas_right).offset(8);
        make.width.mas_equalTo(40);
        make.height.equalTo(setpper);
    }];
    
    //按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    btn.titleLabel.font=kFont(15);
    //btn.enabled=NO;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(2);
        make.right.equalTo(self.view).offset(-2);
        make.bottom.equalTo(self.view).offset(-2);
        make.height.mas_equalTo(45);
    }];
    [btn addTarget:self action:@selector(completeClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}


-(void)fingerTapped
{
    [self.view endEditing:YES];
}
#pragma mark --文本框协议
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==self.waysText) {
        [self.view endEditing:YES];
        self.middleText=textField;
        //服用方式
        MrPicker *picker=[[MrPicker alloc]init];
        picker.delegate=self;
        NSArray *array = [NSArray arrayWithObjects:@"餐前口服",@"餐后口服",nil];
        [picker.arrayData addObjectsFromArray:array];
        [self.view addSubview:picker];
        picker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }else if(textField==self.timeText)
    {
        [self.view endEditing:YES];
        MrDatePicker *picker=[[MrDatePicker alloc]init];
        switch ((int)self.type) {
            case SunAddTypePlan:
                picker.pickerModel=@"UIDatePickerModeTime";
                break;
        }
        [self.view addSubview:picker];
        picker.delegate=self;
        [picker.datePicker setMaximumDate:nil];
        picker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }else if(textField==self.unitText){
        [self.view endEditing:YES];
        self.middleText=textField;
        //服用方式
        MrPicker *picker=[[MrPicker alloc]init];
        picker.delegate=self;
        NSArray *array = [NSArray arrayWithObjects:@"片",@"ml",@"克",nil];
        [picker.arrayData addObjectsFromArray:array];
        [self.view addSubview:picker];
        picker.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    }
    if(textField==self.nameText)
    {
    return YES;
    }
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //回收键盘,取消第一响应者
    [textField resignFirstResponder]; return YES;
    
}



-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.nameText==textField)
    {
        
    }
    
}

-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time
{
    switch ((int)self.type) {
        case SunAddTypePlan:
            self.timeText.text=[time componentsSeparatedByString:@" "][1];
            break;
        case SunAddTypeRecord:
            self.timeText.text=time;
            break;
        
    }
    
}
//picke协议
-(void)pickerWith:(MrPicker *)picker title:(NSString *)title
{
    self.middleText.text=title;
}

//完成
-(void)completeClick
{
    if([self.timeText.text isEqualToString:@""]||self.timeText.text==nil){
        [SVProgressHUD showErrorWithStatus:@"请选择时间"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    if([self.nameText.text isEqualToString:@""]||self.nameText.text==nil){
        [SVProgressHUD showErrorWithStatus:@"请填写药品名称"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    if([self.waysText.text isEqualToString:@""]||self.waysText.text==nil){
        [SVProgressHUD showErrorWithStatus:@"请选择服药方式"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    
    switch ((int)self.type) {
        case SunAddTypePlan:
            dic[@"parma"]=[NSString stringWithFormat:@"SetMedPlanDet*%@*%@*%@*%@*%@*%@",self.MedDCode,self.nameText.text,self.timeText.text,self.setpper.countLabel.text,self.unitText.text,self.waysText.text];
            break;
        case SunAddTypeRecord:
            dic[@"parma"]=[NSString stringWithFormat:@"SetMedExec**%@*%@*%@*%@*%@*%@",login.usercode,self.nameText.text,self.setpper.countLabel.text,self.unitText.text,self.waysText.text,self.timeText.text];
            break;
            
    }
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"添加成功"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"添加失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}
@end
