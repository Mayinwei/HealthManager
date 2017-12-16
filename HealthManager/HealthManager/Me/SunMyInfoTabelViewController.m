//
//  SunMyInfoTabelViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMyInfoTabelViewController.h"
#import "SunGroupModel.h"
#import "SunViewItemModel.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunMyInfoModel.h"

@interface SunMyInfoTabelViewController ()
@property(nonatomic,strong)UITextField *textName;
@property(nonatomic,strong)UITextField *textSex;
@property(nonatomic,strong)UITextField *textBir;
@property(nonatomic,strong)UITextField *textHeight;
@property(nonatomic,strong)UITextField *textWeight;
@property(nonatomic,strong)UITextField *textBIM;
@property(nonatomic,strong)UITextField *textMin;
@property(nonatomic,strong)UITextField *textHun;
@property(nonatomic,strong)UITextField *textID;
@property(nonatomic,strong)UITextField *textFa;
@property(nonatomic,strong)UITextField *textWen;
@property(nonatomic,strong)UITextField *textZhi;
@property(nonatomic,strong)UITextField *textHealth;
@property(nonatomic,strong)UITextField *textYi;

@end

#define CellHeightInfo 38
@implementation SunMyInfoTabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title=@"基本信息";
    self.view.backgroundColor=MrColor(240, 240, 240);
    self.tableView.showsVerticalScrollIndicator=NO;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"编辑" style: UIBarButtonItemStyleDone target:self action:@selector(upateInfo)];
    self.navigationItem.rightBarButtonItem.tintColor=[UIColor whiteColor];
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:15], NSFontAttributeName, nil] forState:UIControlStateNormal];

    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
    [self.view addGestureRecognizer:tap];
    
        //创建四组数据
    [self setUpGroup0];
    [self setUpGroup1];
    [self setUpGroup2];
    
    [self DisableText];
    //加载数据
    [self loadData];
}

-(void)viewClick
{
    [self.view endEditing:YES];
}
-(void)dealloc
{
[self.view endEditing:YES];
}
//禁用所有文本框
-(void)DisableText
{
    self.textName.enabled=NO;
    self.textSex.enabled=NO;
    self.textBir.enabled=NO;
    self.textHeight.enabled=NO;
    self.textWeight.enabled=NO;
    self.textBIM.enabled=NO;
    self.textMin.enabled=NO;
    self.textHun.enabled=NO;
    self.textID.enabled=NO;
    self.textFa.enabled=NO;
    self.textWen.enabled=NO;
    self.textZhi.enabled=NO;
    self.textHealth.enabled=NO;
    self.textYi.enabled=NO;
    
}

-(void)AbleText{
    self.textName.enabled=YES;
    self.textSex.enabled=YES;
    self.textBir.enabled=YES;
    self.textHeight.enabled=YES;
    self.textWeight.enabled=YES;
    self.textBIM.enabled=YES;
    self.textMin.enabled=YES;
    self.textHun.enabled=YES;
    self.textID.enabled=YES;
    self.textFa.enabled=YES;
    self.textWen.enabled=YES;
    self.textZhi.enabled=YES;
    self.textHealth.enabled=YES;
    self.textYi.enabled=YES;
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.contentInset=UIEdgeInsetsZero;

}

-(void)setUpGroup0
{
    SunGroupModel *group=[self addToArrayData];
    
    UITextField *textName=[[UITextField alloc]init];
    textName.placeholder=@"姓名";
    self.textName=textName;
    SunViewItemModel *arrow1=[SunViewItemModel itemWithTitle:@"姓名" view:textName];
    arrow1.cellHeight=CellHeightInfo;
    
    UITextField *textName2=[[UITextField alloc]init];
    self.textSex=textName2;
    textName2.placeholder=@"性别";
    SunViewItemModel *arrow2=[SunViewItemModel itemWithTitle:@"性别" view:textName2];
    
    UITextField *textName3=[[UITextField alloc]init];
    textName3.placeholder=@"出生日期";
    self.textBir=textName3;
    SunViewItemModel *arrow3=[SunViewItemModel itemWithTitle:@"出生日期" view:textName3];
    
    UITextField *textName4=[[UITextField alloc]init];
    textName4.placeholder=@"身高";
    self.textHeight=textName4;
    SunViewItemModel *arrow4=[SunViewItemModel itemWithTitle:@"身高" view:textName4];
    
    UITextField *textName5=[[UITextField alloc]init];
    textName5.placeholder=@"体重";
    self.textWeight=textName5;
    SunViewItemModel *arrow5=[SunViewItemModel itemWithTitle:@"体重" view:textName5];
    
    UITextField *textName6=[[UITextField alloc]init];
    textName6.placeholder=@"BMI";
    self.textBIM=textName6;
    SunViewItemModel *arrow6=[SunViewItemModel itemWithTitle:@"BIM" view:textName6];
    
    UITextField *textName7=[[UITextField alloc]init];
    textName7.placeholder=@"民族";
    self.textMin=textName7;
    SunViewItemModel *arrow7=[SunViewItemModel itemWithTitle:@"民族" view:textName7];
    
    UITextField *textName8=[[UITextField alloc]init];
    textName8.placeholder=@"婚姻状况";
    self.textHun=textName8;
    SunViewItemModel *arrow8=[SunViewItemModel itemWithTitle:@"婚姻状况" view:textName8];
    
    UITextField *textName9=[[UITextField alloc]init];
    textName9.placeholder=@"身份证号";
    self.textID=textName9;
    SunViewItemModel *arrow9=[SunViewItemModel itemWithTitle:@"身份证号" view:textName9];
    
    UITextField *textName10=[[UITextField alloc]init];
    textName10.placeholder=@"发证机关";
    self.textFa=textName10;
    SunViewItemModel *arrow10=[SunViewItemModel itemWithTitle:@"发证机关" view:textName10];
    
    group.items=@[arrow1,arrow2,arrow3,arrow4,arrow5,arrow6,arrow7,arrow8,arrow9,arrow10];
}

-(void)setUpGroup1
{
    
    SunGroupModel *group=[self addToArrayData];
    
    UITextField *textName1=[[UITextField alloc]init];
    textName1.placeholder=@"文化程度";
    self.textWen=textName1;
    SunViewItemModel *arrow1=[SunViewItemModel itemWithTitle:@"文化程度" view:textName1];
    arrow1.cellHeight=CellHeightInfo;
    
    UITextField *textName2=[[UITextField alloc]init];
    textName2.placeholder=@"职业";
    self.textZhi=textName2;
    SunViewItemModel *arrow2=[SunViewItemModel itemWithTitle:@"职业" view:textName2];
    
    group.items=@[arrow1,arrow2];
}

-(void)setUpGroup2
{
    SunGroupModel *group=[self addToArrayData];
    
    UITextField *textName1=[[UITextField alloc]init];
    textName1.placeholder=@"健康卡号";
    self.textHealth=textName1;
    SunViewItemModel *arrow1=[SunViewItemModel itemWithTitle:@"健康卡号" view:textName1];
    arrow1.cellHeight=CellHeightInfo;
    
    UITextField *textName2=[[UITextField alloc]init];
    textName2.placeholder=@"医保形式";
    self.textYi=textName2;
    SunViewItemModel *arrow2=[SunViewItemModel itemWithTitle:@"医保形式" view:textName2];
    
    group.items=@[arrow1,arrow2];
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetUserInfo*%@",login.usercode];
    
    

    
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
        NSArray *array=[SunMyInfoModel mj_objectArrayWithKeyValuesArray:json];
        //赋值
        SunMyInfoModel *info=array[0];
        self.textName.text=info.USERNAME;
        self.textSex.text=info.USEX;
        self.textBir.text=[info.BIRTHDAY componentsSeparatedByString:@" "][0];
        self.textHeight.text=info.UHIGHT;
        self.textWeight.text=info.UWEIGHT;
        self.textBIM.text=info.UBMI;
        self.textMin.text=info.NATIONALITY;
        self.textHun.text=info.MARSTATUS;
        self.textID.text=info.UserCard;
        self.textFa.text=info.ISSUEDEPART;
        self.textWen.text=info.CULTURALDEGREE;
        self.textZhi.text=info.OCCUPATION;
        self.textHealth.text=info.Healthcard;
        self.textYi.text=info.MEDINSURANCEFORM;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];

}

-(void)upateInfo
{
    //启用
    [self AbleText];
    [self.textName becomeFirstResponder];
    //修改标题
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
    {
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        //获取账户信息
        SunLogin *login=[SunAccountTool getAccount];
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        dic[@"access_token"]=login.access_token;
        dic[@"parma"]=[NSString stringWithFormat:@"updateBasicInfo*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@*%@",login.usercode,self.textName.text,self.textSex.text,self.textBir.text,self.textHeight.text,self.textWeight.text,self.textMin.text,self.textHun.text,self.textID.text,self.textFa.text,self.textWen.text,self.textZhi.text,self.textHealth.text,self.textYi.text,self.textBIM.text];
        
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
@end
