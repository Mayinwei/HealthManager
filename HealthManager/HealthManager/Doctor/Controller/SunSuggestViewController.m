//
//  SunSuggestViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/24.
//  Copyright © 2017年 马银伟. All rights reserved.
//  填写专家建议

#import "SunSuggestViewController.h"
#import "MaTextView.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"

@interface SunSuggestViewController ()<UITextViewDelegate>
@property(nonatomic,weak)UITextView *textView;
@property(nonatomic,weak)UIBarButtonItem *btnItem;
@end

@implementation SunSuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //修改标题颜色
    UINavigationBar *bar = [UINavigationBar appearance];
    [bar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background_white"] forBarMetrics:UIBarMetricsDefault];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    //21 125 251
    UIColor *titlec=MrColor(33, 135, 244);
    [btn setTitleColor:titlec forState:UIControlStateNormal];
    btn.frame=(CGRect){CGPointZero,CGSizeMake(50, 22)};
    [btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
    UIButton *btnSave=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    [btnSave setTitleColor:titlec forState:UIControlStateNormal];
    [btnSave setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    btnSave.frame=(CGRect){CGPointZero,CGSizeMake(50, 22)};
    [btnSave addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem=[[UIBarButtonItem alloc] initWithCustomView:btnSave];
    self.btnItem=btnItem;
    btnItem.enabled=NO;
    //添加右侧保存按钮
    self.navigationItem.rightBarButtonItem=btnItem;
    
    //添加控件
    [self setUpMain];
}

-(void)save
{

    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"SendSuggest*%@*%@*%@*%@",login.usercode,self.PtsCode,self.textView.text,self.title];
    
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
        [self close];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"添加失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
}

-(void)setUpMain
{
    MaTextView *textView=[[MaTextView alloc]init];
    self.textView=textView;
    textView.font=kFont(15);
    [self.view addSubview:textView];
    textView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //添加一个收回键盘按钮
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [topView setBarStyle:UIBarStyleBlackOpaque];
    
    //定义完成按钮
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"关闭键盘" style:UIBarButtonItemStyleDone  target:self action:@selector(resignKeyboard)];
    
    //在toolBar上加上这些按钮
    NSArray * buttonsArray = [NSArray arrayWithObjects:doneButton,nil];
    [topView setItems:buttonsArray];
    [textView setInputAccessoryView:topView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValChange) name:UITextViewTextDidChangeNotification object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)textValChange
{
    self.btnItem.enabled=self.textView.text.length>0;
}

-(void)resignKeyboard
{
    [self.textView resignFirstResponder];
}

-(void)close
{
    [self resignKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
