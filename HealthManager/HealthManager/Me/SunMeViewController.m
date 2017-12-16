//
//  SunMeViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMeViewController.h"
#import "SunGroupModel.h"
#import "SunArrowItemModel.h"
#import "SunLableItemModel.h"
#import "SunDeviceTableViewController.h"
#import "Chameleon.h"
#import "SunCutImageView.h"
#import "SunMeButton.h"
#import "SunMyInfoTabelViewController.h"
#import "SunMyContactTableViewController.h"
#import "SunMedicalViewController.h"
#import "SunUpdatePwdViewController.h"
#import "SunSuggestTableViewController.h"
#import "SunSettingTableViewController.h"
#import "SunAttentionRequestTableViewController.h"
#import "SunQRCodeView.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "Chameleon.h"
#import "SunPlanModel.h"
#import "SunPlanDetailViewController.h"
#import "UIImageView+WebCache.h"


@interface SunMeViewController ()<UIAlertViewDelegate>
@property(nonatomic,weak)UIImageView *headImgView;
@property(nonatomic,weak)UILabel *labName;
@property(nonatomic,copy)NSString *guan;
@property(nonatomic,copy)NSString *suggest;
@property(nonatomic,copy)NSString *UserCart;
@property(nonatomic,strong)SunLogin *loign;
@property(nonatomic,weak)UIImageView *bgImageView;
@end

@implementation SunMeViewController

//行高
#define MyCellHeight 40;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 32,0);
    self.tableView.contentInset = insets;
    self.tableView.showsVerticalScrollIndicator=NO;
    
    self.loign=[SunAccountTool getAccount];
    //创建四组数据
    if ([self.loign.type isEqualToString:@"个人用户"]) {
        [self setUpGroup0];
        [self setUpGroup1];
        [self setUpGroup2];
    }
    
    [self setUpGroup3];
    
    //添加行头
    [self setUpTop];
    
    //禁止因为nav导致滚动距离边大
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    if([self.loign.type isEqualToString:@"个人用户"])
    {
        //加载一般用户数据
        [self loadPtsData];
    }else{
        [self loadDocData];
    }
    //用于接收系统3D touch的点击
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showScan:) name:@"myHomeTouch" object:nil];
    
    
}
-(void)showScan:(NSNotification *)not
{
    NSString *touchType= not.userInfo[@"type"];
    
    if([touchType isEqualToString:@"我的二维码"]){
        [self load3DTouch];
    }
    
}

//3D touch加载数据
-(void)load3DTouch
{
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMePageInfo*%@",login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSDictionary *dicResult=json;
        self.labName.text=[dicResult[@"UserName"] copy];
        self.UserCart=[dicResult[@"UserCard"] copy];
        [self tapClick];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.tableView.tableFooterView.backgroundColor=[UIColor redColor];
    [super viewDidAppear:animated];
    //设置导航栏背景图片
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background_tou"] forBarMetrics:UIBarMetricsDefault];
    
    //设置导航栏下面黑线隐藏
    UIImageView *navBarHairlineImageView= [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    navBarHairlineImageView.hidden=YES;
    
    self.tableView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

#pragma mark --滚动事件
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = SCREEN_WIDTH; // 图片宽度
    
    CGFloat yOffset = scrollView.contentOffset.y;  // 偏移的y值
    
    if (yOffset < 0) {
        
        CGFloat totalOffset = 220 + ABS(yOffset);
        
        CGFloat f = totalOffset / 220;
        
        self.bgImageView.frame =  CGRectMake(- (width * f - width) / 2, yOffset, width * f, totalOffset); //拉伸后的图片的frame应该是同比例缩放
    }
}



//加载数据
-(void)loadPtsData
{

    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMePageInfo*%@",login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSDictionary *dicResult=json;
        self.labName.text=[dicResult[@"UserName"] copy];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,[dicResult[@"HeadPic"] copy]]];
        [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
        //关注
        self.guan=[dicResult[@"GuanNum"] copy];
        self.suggest=[dicResult[@"ZhuanNum"] copy];
        self.UserCart=[dicResult[@"UserCard"] copy];
        
        [self setUpGroup2];
        [self setUpGroup3];
        [super refreshData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

-(void)loadDocData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetMeDocPageInfo*%@",login.usercode];
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSDictionary *dicResult=json;
        self.labName.text=[dicResult[@"UserName"] copy];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,[dicResult[@"HeadPic"] copy]]];
        [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
        
        [super refreshData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];

}


//找到导航栏下面的黑线，
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

-(void)setUpTop
{
    UIView *topView=[[UIView alloc]init];
    topView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 220);
    self.tableView.tableHeaderView=topView;
    UIImageView *bgImageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"me_bg"]];
    self.bgImageView=bgImageView;
    [topView addSubview: bgImageView];
    [bgImageView  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView);
        make.left.equalTo(topView);
        make.size.equalTo(topView);
    }];
    //添加头像
    UIImageView *headImgView=[[UIImageView alloc]init];
    self.headImgView=headImgView;
    headImgView.userInteractionEnabled=YES;
    headImgView.layer.cornerRadius=40;
    headImgView.layer.masksToBounds=YES;
    
    [topView addSubview:headImgView];
    if ([self.loign.type isEqualToString:@"个人用户"]) {
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapClick)];
        [headImgView addGestureRecognizer:tap];
    }
    [headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topView).offset(-18);
        make.centerX.equalTo(topView);
        make.size.mas_equalTo(80);
    }];
    //名称
    UILabel *labName=[[UILabel alloc]init];
    self.labName=labName;
    labName.text=@"";
    labName.textColor=[UIColor whiteColor];
    labName.font=kFont(18);
    [topView addSubview:labName];
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topView);
        make.top.equalTo(headImgView.mas_bottom).offset(8);
    }];

}

//显示二维码
-(void)tapClick
{
    if(self.UserCart.length==0||self.labName.text.length==0){
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"警告" message:@"个人信息不完整，请完善信息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        [alertview show];
        return;
    }
    SunQRCodeView *qrView=[[SunQRCodeView alloc]init];
    //格式不能变
    qrView.text=[NSString stringWithFormat:@"SunAttention*%@,%@",self.labName.text,self.UserCart];
    [self.view addSubview:qrView];
    [qrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self.navigationController pushViewController:[[SunMyInfoTabelViewController alloc]init] animated:YES];
    }

}
-(void)setUpGroup0
{
    SunGroupModel *group=[self addToArrayData];
    SunArrowItemModel *arrow1=[SunArrowItemModel itemWithIcon:@"Home" title:@"基本信息" destVcClass:[SunMyInfoTabelViewController class]];
    SunArrowItemModel *arrow2=[SunArrowItemModel itemWithIcon:@"Chess" title:@"联系方式" destVcClass:[SunMyContactTableViewController class]];
    SunArrowItemModel *arrow3=[SunArrowItemModel itemWithIcon:@"Calendar" title:@"病史记录" destVcClass:[SunMedicalViewController class]];
    arrow1.cellHeight=MyCellHeight;
    arrow2.cellHeight=MyCellHeight;
    arrow2.cellHeight=MyCellHeight;
    group.items=@[arrow1,arrow2,arrow3];
    
}
-(void)setUpGroup1
{
    SunGroupModel *group=[self addToArrayData];
    SunArrowItemModel *arrow1=[SunArrowItemModel itemWithIcon:@"Gadget" title:@"我的设备" destVcClass:[SunDeviceTableViewController class]];
    arrow1.cellHeight=MyCellHeight;
    group.items=@[arrow1];
}
-(void)setUpGroup2
{
    //清空数据
    if (self.arrayData.count>=4) {
        [self.arrayData removeObjectsInRange:NSMakeRange(2, 2)];
    }
    
    
    SunGroupModel *group=[self addToArrayData];
    SunArrowItemModel *arrow1=[SunArrowItemModel itemWithIcon:@"Clock" title:@"关注请求" destVcClass:[SunAttentionRequestTableViewController class]];
    arrow1.badgeValue=self.guan;
    group.items=@[arrow1];
    arrow1.cellHeight=MyCellHeight;
}
-(void)setUpGroup3
{
    SunGroupModel *group=[self addToArrayData];
    NSMutableArray *array=[NSMutableArray array];
    if ([self.loign.type isEqualToString:@"个人用户"]) {
        SunArrowItemModel *arrow1=[SunArrowItemModel itemWithIcon:@"Email" title:@"专家建议" destVcClass:[SunSuggestTableViewController class]];
        arrow1.badgeValue=self.suggest;
        arrow1.cellHeight=MyCellHeight;
        [array addObject:arrow1];
    }
    
    SunArrowItemModel *arrow2=[SunArrowItemModel itemWithIcon:@"Lock" title:@"修改密码" destVcClass:[SunUpdatePwdViewController class]];
    [array addObject:arrow2];
    SunArrowItemModel *arrow3=[SunArrowItemModel itemWithIcon:@"Mechanism" title:@"系统设置" destVcClass:[SunSettingTableViewController class]];
    [array addObject:arrow3];
    group.items=array;
    arrow2.cellHeight=MyCellHeight;
    arrow2.cellHeight=MyCellHeight;
}

@end
