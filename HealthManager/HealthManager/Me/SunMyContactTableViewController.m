//
//  SunMyContactTableViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  联系方式

#import "SunMyContactTableViewController.h"
#import "SunGroupModel.h"
#import "SunViewItemModel.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunMyContactModel.h"

@interface SunMyContactTableViewController ()
@property(nonatomic,strong)UITextField *textAdress;
@property(nonatomic,strong)UITextField *textPhone;
@property(nonatomic,strong)UITextField *textMobel1;
@property(nonatomic,strong)UITextField *textMobel2;
@property(nonatomic,strong)UITextField *textEmail;
@property(nonatomic,strong)UITextField *textQQ;
@end

#define CellHeightInfo 38
@implementation SunMyContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [self DisableText];
    //加载数据
    [self loadData];
}
-(void)setUpGroup0
{
    SunGroupModel *group=[self addToArrayData];
    
    UITextField *textName=[[UITextField alloc]init];
    textName.placeholder=@"详细地址";
    self.textAdress=textName;
    SunViewItemModel *arrow1=[SunViewItemModel itemWithTitle:@"详细地址" view:textName];
    arrow1.cellHeight=CellHeightInfo;
    group.items=@[arrow1];
}
-(void)viewClick
{
    [self.view endEditing:YES];
    
}

-(void)setUpGroup1
{
    SunGroupModel *group=[self addToArrayData];
    
    UITextField *textName=[[UITextField alloc]init];
    textName.placeholder=@"手机号";
    self.textPhone=textName;
    SunViewItemModel *arrow1=[SunViewItemModel itemWithTitle:@"手机号" view:textName];
    arrow1.cellHeight=CellHeightInfo;
    
    UITextField *textName1=[[UITextField alloc]init];
    textName1.placeholder=@"家庭手机1";
    self.textMobel1=textName1;
    SunViewItemModel *arrow2=[SunViewItemModel itemWithTitle:@"家庭手机1" view:textName1];
    arrow2.cellHeight=CellHeightInfo;
    
    UITextField *textName2=[[UITextField alloc]init];
    textName2.placeholder=@"家庭手机2";
    self.textMobel2=textName2;
    SunViewItemModel *arrow3=[SunViewItemModel itemWithTitle:@"家庭手机2" view:textName2];
    arrow3.cellHeight=CellHeightInfo;
    
    UITextField *textName3=[[UITextField alloc]init];
    textName3.placeholder=@"电子邮箱";
    self.textEmail=textName3;
    SunViewItemModel *arrow4=[SunViewItemModel itemWithTitle:@"电子邮箱" view:textName3];
    arrow4.cellHeight=CellHeightInfo;
    
    UITextField *textName4=[[UITextField alloc]init];
    textName4.placeholder=@"QQ";
    self.textQQ=textName4;
    SunViewItemModel *arrow5=[SunViewItemModel itemWithTitle:@"QQ" view:textName4];
    arrow5.cellHeight=CellHeightInfo;
    
    group.items=@[arrow1,arrow2,arrow3,arrow4,arrow5];
}

-(void)DisableText
{
    self.textQQ.enabled=NO;
    self.textEmail.enabled=NO;
    self.textAdress.enabled=NO;
    self.textPhone.enabled=NO;
    self.textMobel1.enabled=NO;
    self.textMobel2.enabled=NO;
}

-(void)AbleText
{
    self.textQQ.enabled=YES;
    self.textEmail.enabled=YES;
    self.textAdress.enabled=YES;
    self.textPhone.enabled=YES;
    self.textMobel1.enabled=YES;
    self.textMobel2.enabled=YES;
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
        NSArray *array=[SunMyContactModel mj_objectArrayWithKeyValuesArray:json];
        //赋值
        SunMyContactModel *info=array[0];
        self.textAdress.text=info.ADDRESS;
        self.textPhone.text=info.MOBILENO;
        self.textMobel1.text=info.DEPENO1;
        self.textMobel2.text=info.DEPENO2;
        self.textEmail.text=info.EMAIL;
        self.textQQ.text=info.QQ;
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
    [self.textAdress becomeFirstResponder];
    //修改标题
    if([self.navigationItem.rightBarButtonItem.title isEqualToString:@"保存"])
    {
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        //获取账户信息
        SunLogin *login=[SunAccountTool getAccount];
        NSMutableDictionary *dic=[NSMutableDictionary dictionary];
        dic[@"access_token"]=login.access_token;
        dic[@"parma"]=[NSString stringWithFormat:@"updateContactInfo*%@*%@*%@*%@*%@*%@*%@",login.usercode,self.textAdress.text,self.textPhone.text,self.textMobel1.text,self.textMobel2.text,self.textEmail.text,self.textQQ.text];
        
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
