//
//  SunRegisterViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//  注册

#import "SunRegisterViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJExtension.h"
#import "SunErrorModel.h"


@interface SunRegisterViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UITextField *textYan;
@property(nonatomic,strong)UITextField *textPhone;
@property(nonatomic,strong)UITextField *textName;
@property(nonatomic,strong)UITextField *textPwd1;
@property(nonatomic,strong)UITextField *textPwd2;
@property(nonatomic,strong)UITextField *middleText;
@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)UIButton *btnYan;

//保存发送的验证码
@property(nonatomic,strong)NSString *RandomSer;
@end

@implementation SunRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=MrColor(242, 242, 242);
    //初始化导航条
    [self setUpNav];
    //布局界面
    [self setUpControl];
    
    
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo)];
    [self.view addGestureRecognizer:tapGesture];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden=NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}
-(void)Actiondo
{
    [self.view endEditing:YES];
}
-(void)setUpNav
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, 44)];
    [navigationBar  setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault ];
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:@"注册"];
    
    //设置导航栏的字体
    NSMutableDictionary *textAttr=[NSMutableDictionary dictionary];
    textAttr[NSForegroundColorAttributeName]=[UIColor whiteColor];
    //设置阴影为0
    //textAttr[NSShadowAttributeName]=[NSValue valueWithUIOffset:UIOffsetZero];
    textAttr[NSFontAttributeName]=[UIFont systemFontOfSize:22];
    [navigationBar setTitleTextAttributes:textAttr];
    
    //创建UIBarButton 可根据需要选择适合自己的样式
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStyleDone target:self action:@selector(navigationBackButton)];
    //设置barbutton
    navigationBarTitle.leftBarButtonItem = item;
    [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14], NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
    
    [self.view addSubview: navigationBar];
    
    UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    statusBarView.backgroundColor=MrColor(33, 135, 244);
    [self.view addSubview:statusBarView];

}

-(void)setUpControl
{
    UIImageView *imgIcon=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    imgIcon.layer.cornerRadius=13;
    imgIcon.layer.masksToBounds=YES;
    [self.view addSubview:imgIcon];
    [imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(100);
        make.height.equalTo(imgIcon.mas_width);
    }];
    
    //用户名
    UIView *nameView=[self getViewWithPlaceholder:@"登录名" isPwd:NO];
    self.textName=nameView.subviews[0];
    [self.view addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-60);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(43);
    }];
    //手机号
    UIView *phoneView=[self getViewWithPlaceholder:@"手机号" isPwd:NO];
    self.textPhone=phoneView.subviews[0];
    [self.view addSubview:phoneView];
    [phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameView.mas_bottom);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(nameView.mas_height);
    }];
    
    //验证码
    CGFloat yanW=100;
    UIView *yanView=[self getViewWithPlaceholder:@"验证码" isPwd:NO];
    self.textYan=yanView.subviews[0];
    self.textYan.delegate=self;
    [self.view addSubview:yanView];
    [yanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneView.mas_bottom);
        make.width.equalTo(self.view).offset(-yanW);
        make.left.equalTo(self.view);
        make.height.equalTo(nameView.mas_height);
    }];
    
    //验证码按钮
    UIButton *btnYan=[UIButton buttonWithType:UIButtonTypeCustom];
    btnYan.titleLabel.font=kFont(13);
    self.btnYan=btnYan;
    btnYan.enabled=NO;
    [btnYan setTitle:@"发送验证码" forState:UIControlStateNormal];
    [btnYan setBackgroundImage:[UIImage imageNamed:@"btn-angle"] forState:UIControlStateNormal];
    [btnYan setBackgroundImage:[UIImage imageNamed:@"btn-angle-disable"] forState:UIControlStateDisabled];
    
    [btnYan addTarget:self action:@selector(sendClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnYan];
    [btnYan mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(yanView.mas_right);
        make.top.equalTo(phoneView.mas_bottom);
        make.height.equalTo(nameView.mas_height);
        make.width.mas_equalTo(yanW);
    }];

    //密码
    UIView *pwdView1=[self getViewWithPlaceholder:@"密码" isPwd:YES];
    self.textPwd1=pwdView1.subviews[0];
    self.textPwd1.delegate=self;
    [self.view addSubview:pwdView1];
    [pwdView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(yanView.mas_bottom);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(nameView.mas_height);
    }];
    UIView *pwdView2=[self getViewWithPlaceholder:@"确认密码" isPwd:YES];
    [self.view addSubview:pwdView2];
    self.textPwd2=pwdView2.subviews[0];
    self.textPwd2.delegate=self;
    [pwdView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pwdView1.mas_bottom);
        make.width.equalTo(self.view);
        make.left.equalTo(self.view);
        make.height.equalTo(pwdView1.mas_height);
    }];
    
    //注册按钮
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn=btn;
    [btn setTitle:@"注册" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"common_btn_disable"] forState:UIControlStateDisabled];
    btn.titleLabel.font=kFont(15);
    [btn addTarget:self action:@selector(regiterClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    btn.enabled=NO;
    CGFloat leftPadding=10;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding);
        make.right.equalTo(self.view).offset(-leftPadding);
        make.top.equalTo(pwdView2.mas_bottom).offset(22);
        make.height.mas_equalTo(44);
    }];
    
    
    //注册通知监听文本框变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.textName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput2) name:UITextFieldTextDidChangeNotification object:self.textPhone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.textPhone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.textYan];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.textPwd1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.textPwd2];
    
    //监听键盘滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --文本框协议
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.middleText=textField;
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{

    [UIView animateWithDuration:0.1 animations:^{
        self.middleText.superview.transform=CGAffineTransformIdentity;
    }];
    self.middleText=nil;
}

//键盘出现
-(void)keyboardWillShow:(NSNotification *)notifi
{
    
    NSDictionary *userInfo = [notifi userInfo];
    NSValue* aValue        = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect= [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGFloat margin = 5;//文本框距键盘顶边最小距离
    CGFloat scrollY=0;
    
    //获取最大Y值
    CGFloat maxY=CGRectGetMaxY(self.middleText.superview.frame);
    scrollY=keyboardTop-margin-maxY;

    if(scrollY<0)
    {
        // [[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
        CGFloat duration=[[[notifi userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView setAnimationCurve:[[[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView animateWithDuration:duration animations:^{
            //self.middleText.superview.transform=CGAffineTransformMakeTranslation(0,scrollY);
            self.view.transform=CGAffineTransformMakeTranslation(0,scrollY);
        }];
    }
}
//键盘消失
-(void)keyboardWillHide:(NSNotification *)notifi
{
    
    CGFloat duration=[[[notifi userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView setAnimationCurve:[[[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView animateWithDuration:duration animations:^{
        //self.middleText.superview.transform=CGAffineTransformIdentity;
        self.view.transform=CGAffineTransformIdentity;
    }];
}





-(void)TextInput
{
    if (self.textName.text.length!=0&&self.textPhone.text.length!=0&&self.textYan.text.length!=0&&self.textPwd1.text.length!=0&&self.textPwd2.text.length!=0) {
        self.btn.enabled=YES;
    }else{
        self.btn.enabled=NO;
    }
    
}
-(void)TextInput2
{
    if (self.textPhone.text.length!=0) {
        self.btnYan.enabled=YES;
    }else{
        self.btnYan.enabled=NO;
    }
}

//注册
-(void)regiterClick
{
    if (![self.textYan.text isEqualToString:self.RandomSer]) {
        [SVProgressHUD showErrorWithStatus:@"验证码输入错误"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    
    
    if (![self.textPwd1.text isEqualToString:self.textPwd2.text]) {
        [SVProgressHUD showErrorWithStatus:@"密码输入不一致"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return;
    }
    
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"parma"]=[NSString stringWithFormat:@"RegisterUser*%@*%@*%@",self.textName.text,self.textPhone.text,self.textPwd1.text];
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"注册成功请登录"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        
        [self navigationBackButton];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"注册失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

//发送验证码
-(void)sendClick
{
    [self setUpBtn];
    if (![self valiMobile:self.textPhone.text]) {
        [SVProgressHUD showErrorWithStatus:@"手机号格式不正确"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        return;
    }
    int num = (arc4random() % 10000);
    self.RandomSer = [NSString stringWithFormat:@"%.4d", num];
    
    NSString *urlString= [NSString stringWithFormat:@"您的验证码是:%@ 【善医科技】",self.RandomSer];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"reg"]=@"101100-WEB-HUAX-107645";
    dic[@"pwd"]=@"ARRJMULV";
    dic[@"sourceadd"]=@"123";
    dic[@"phone"]=self.textPhone.text;
    dic[@"content"]=urlString;

    
    
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:@"http://www.stongnet.com/sdkhttp/sendsms.aspx" parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"发送验证码失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    }];
    
}

-(void)setUpBtn{
    __block int timeout=30; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.btnYan setTitle:@"发送验证码" forState:UIControlStateNormal];
                self.btnYan.enabled = YES;
            });
        }else{
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:1];
                [self.btnYan setTitle:[NSString stringWithFormat:@"%@秒后重新发送",strTime] forState:UIControlStateNormal];
                [UIView commitAnimations];
                self.btnYan.enabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
//判断手机号码格式是否正确
- (BOOL)valiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}


-(UIView *)getViewWithPlaceholder:(NSString *)holder isPwd:(BOOL)isPwd
{
    UIView *view=[[UIView alloc]init];
    view.backgroundColor=[UIColor whiteColor];
    
    CGFloat topPadding=8;
    UITextField *textField=[[UITextField alloc]init];
    if(isPwd)
    {
        textField.secureTextEntry=YES;
    }
    textField.placeholder=holder;
    textField.font=kFont(15);
    [view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.left.equalTo(view).offset(25);
        make.right.equalTo(view).offset(-25);
        make.top.equalTo(view).offset(topPadding);
        make.bottom.equalTo(view).offset(-topPadding);
    }];
    //底部分割线
    UIView *cutView=[[UIView alloc]init];
    cutView.backgroundColor=MrColor(230, 230, 230);
    [view addSubview:cutView];
    [cutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.width.equalTo(textField).offset(10);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(view);
    }];
    return view;
}

-(void)navigationBackButton
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
