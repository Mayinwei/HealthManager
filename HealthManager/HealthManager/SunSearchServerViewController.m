//
//  SunSearchServerViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//  查找服务

#import "SunSearchServerViewController.h"
#import "UITableView+EmptyData.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "SunSearchDocModel.h"
#import "SunSearchTableViewCell.h"
#import "SunDocInfoViewController.h"

@interface SunSearchServerViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIGestureRecognizerDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *arrayData;
@end

@implementation SunSearchServerViewController

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=MrColor(240, 240, 240);
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
    tap.delegate=self;
    [self.view addGestureRecognizer:tap];
    
    [self setUpMain];
    //去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
-(void)viewClick
{
    [self.view endEditing:YES];
    
}

-(void)setUpMain
{
    UIView *topView=[[UIView alloc]init];
    topView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(46);
    }];
    
    UITextField *searchText=[[UITextField alloc]init];
    searchText.delegate=self;
    searchText.placeholder=@"请输入医生/医院/科室的名字";
    searchText.font=kFont(14);
    searchText.layer.cornerRadius=5;
    searchText.layer.borderWidth=2;
    //searchText.textAlignment=NSTextAlignmentCenter;
    searchText.returnKeyType = UIReturnKeySearch;
    searchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //MrColor(220, 220, 220)
    UIColor *co=[UIColor lightGrayColor];
    searchText.layer.borderColor=co.CGColor;
    
     UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0,0,15.0, 20)];
    searchText.leftView = blankView;
    searchText.leftViewMode =UITextFieldViewModeAlways;
    
    [topView addSubview:searchText];
    [searchText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(20);
        make.right.equalTo(topView).offset(-20);
        make.top.equalTo(topView).offset(8);
        make.bottom.equalTo(topView).offset(-8);
    }];
    //分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(240, 240, 240);
    [topView addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView);
        make.right.equalTo(topView);
        make.bottom.equalTo(topView);
        make.height.mas_equalTo(1);
    }];
    
    //添加tableview
    UITableView *tableView=[[UITableView alloc]init];
    tableView.delegate=self;
    tableView.dataSource=self;
    self.tableView=tableView;
    [self.view addSubview:tableView];
    tableView.frame=CGRectMake(0, 46, SCREEN_WIDTH, SCREEN_HEIGHT-64-46);
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    [self loadData:textField.text];
    return YES;
}

-(void)loadData:(NSString *)searKey
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetDocList2*%@*%@",self.SearchType,[searKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
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
        self.arrayData=[SunSearchDocModel mj_objectArrayWithKeyValuesArray:json];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunSearchTableViewCell *cell=[SunSearchTableViewCell cellWithTableView:tableView];
    cell.searchDoc=self.arrayData[indexPath.row];    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    SunSearchDocModel *docModel=self.arrayData[indexPath.row];
    SunDocInfoViewController *docInfo=[[SunDocInfoViewController alloc]init];
    docInfo.searchDoc=docModel;
    docInfo.SerType=self.SearchType;
    [self.navigationController pushViewController:docInfo animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}
@end
