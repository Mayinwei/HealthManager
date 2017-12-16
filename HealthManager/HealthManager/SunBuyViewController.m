//
//  SunBuyViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//  支付

#import "SunBuyViewController.h"
#import "CCWebViewController.h"
#import "SunPayResultModel.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "WXApi.h"
#import "MD5.h"
#import <CommonCrypto/CommonDigest.h>

@interface SunBuyViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIImageView *infoImgView;
//是否选择了协议
@property(nonatomic,assign)BOOL isSelect;
@property(nonatomic,strong)UITextField *txtAdress;
@property(nonatomic,strong)UITextField *txtName;
@property(nonatomic,strong)UITextField *txtPhone;
@property(nonatomic,strong)UITextField *middleText;
@property(nonatomic,strong)UIButton *buyButton;

@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labDoc;
@property(nonatomic,strong)UILabel *labPric;
@end

@implementation SunBuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"支付";
    self.view.backgroundColor=MrColor(228, 227, 230);
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewClick)];
    [self.view addGestureRecognizer:tap];
    
    [self setMain];
    //收货地址
    [self setAddress];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.txtName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.txtAdress];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TextInput) name:UITextFieldTextDidChangeNotification object:self.txtPhone];
    
    
    //监听键盘滚动
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self loadData];
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetServerPayInfo*%@",self.SerCode];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        NSString *name=[json[@"DocName"] copy];
        NSString *svrName=[json[@"SvrName"] copy];
        NSString *price=[json[@"Price"] copy];
        
        self.labName.text=[NSString stringWithFormat:@"商品名称:%@",svrName];
        self.labDoc.text=[NSString stringWithFormat:@"购买医生:%@",name];
        self.labPric.text=[NSString stringWithFormat:@"价格:￥%@元",price];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载失败1"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.middleText=textField;
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
    
    CGFloat topY=CGRectGetMaxY(self.infoImgView.frame);
    //获取最大Y值
    CGFloat maxY=CGRectGetMaxY(self.middleText.superview.frame);
    scrollY=keyboardTop-margin-maxY-topY-12;
    
    if(scrollY<0)
    {
        // [[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
        CGFloat duration=[[[notifi userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView setAnimationCurve:[[[notifi userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
        [UIView animateWithDuration:duration animations:^{
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
        self.view.transform=CGAffineTransformIdentity;
    }];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)TextInput
{
    if (self.txtName.text.length>0&&self.txtAdress.text.length>0&&self.txtPhone.text.length>0&&self.isSelect) {
        self.buyButton.enabled=YES;
    }else{
        self.buyButton.enabled=NO;
    }
}

-(void)setMain
{
    UIImageView *infoImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buy_bg"]];
    self.infoImgView=infoImgView;
    [self.view addSubview:infoImgView];
    CGFloat leftPadding=10;
    
    
    UILabel *labName=[[UILabel alloc]init];
    self.labName=labName;
    labName.text=@"商品名称:";
    [infoImgView addSubview:labName];
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(infoImgView);
        make.top.equalTo(infoImgView).offset(20);
    }];
    
    UILabel *labDoc=[[UILabel alloc]init];
    self.labDoc=labDoc;
    labDoc.text=@"购买医生:";
    [infoImgView addSubview:labDoc];
    [labDoc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labName);
        make.top.equalTo(labName.mas_bottom).offset(13);
    }];
    
    UILabel *labPric=[[UILabel alloc]init];
    //labPric.font=[UIFont fontWithName:@"Courier-Bold" size:20];
    labPric.text=@"价格:";
    self.labPric=labPric;
    [infoImgView addSubview:labPric];
    [labPric mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labName);
        make.top.equalTo(labDoc.mas_bottom).offset(13);
    }];
    
    [infoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(leftPadding);
        make.right.equalTo(self.view).offset(-leftPadding);
        make.bottom.equalTo(labPric).offset(20);
        make.top.equalTo(self.view).offset(leftPadding);
    }];
    
}

//收货地址
-(void)setAddress
{
    UIImageView *adressImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"buy_bg"]];
    adressImgView.userInteractionEnabled=YES;
    [self.view addSubview:adressImgView];
    //微信头像
    CGFloat padding=12;
    UIImageView *headWeImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wx_logo"]];
    [adressImgView addSubview:headWeImg];
    [headWeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adressImgView).offset(padding);
        make.top.equalTo(adressImgView).offset(padding);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(48);
    }];
    //微信位子
    UILabel *labWeName=[[UILabel alloc]init];
    labWeName.text= @"微信支付";
    labWeName.font=[UIFont fontWithName:@"华文黑体" size:22];
    labWeName.font=kFont(20);
    [adressImgView addSubview:labWeName];
    [labWeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headWeImg.mas_right).offset(10);
        make.top.equalTo(headWeImg);
    }];
    
    
    UILabel *labSeTitle=[[UILabel alloc]init];
    labSeTitle.text= @"亿万用户的选择，更快更安全";
    labSeTitle.textColor=[UIColor lightGrayColor];
    labSeTitle.font=kFont(15);
    [adressImgView addSubview:labSeTitle];
    [labSeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headWeImg.mas_right).offset(10);
        make.bottom.equalTo(headWeImg);
    }];
    
    //推荐图标
    UIImageView *WeImg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"wx_tuijian"]];
    [adressImgView addSubview:WeImg];
    [WeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labWeName.mas_right);
        make.bottom.equalTo(labWeName);
        make.width.mas_equalTo(40);
        make.height.equalTo(labWeName).multipliedBy(0.7);
    }];
    //分隔线
    UIView *cutView1=[[UIView alloc]init];
    cutView1.backgroundColor=MrColor(228, 227, 230);
    [adressImgView addSubview:cutView1];
    [cutView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headWeImg.mas_bottom).offset(padding);
        make.left.equalTo(adressImgView).offset(padding);
        make.right.equalTo(adressImgView).offset(-padding);
        make.height.mas_equalTo(1);
    }];
    
    UILabel *labding=[[UILabel alloc]init];
    labding.text= @"收货地址";
    labding.textColor=[UIColor lightGrayColor];
    labding.font=kFont(15);
    [adressImgView addSubview:labding];
    [labding mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adressImgView).offset(10);
        make.top.equalTo(cutView1).offset(12);
    }];
    UIView *cutView2=[[UIView alloc]init];
    cutView2.backgroundColor=MrColor(228, 227, 230);
    [adressImgView addSubview:cutView2];
    [cutView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labding.mas_bottom).offset(padding);
        make.left.equalTo(adressImgView).offset(padding);
        make.right.equalTo(adressImgView).offset(-padding);
        make.height.mas_equalTo(1);
    }];
    //地址
    UIView *adressView=[self getTextFieldTypeWithTitle:@"地址" placeHold:@"请输入详细的收货地址"];
    self.txtAdress=[adressView subviews][1];
    [adressImgView addSubview:adressView];
    [adressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutView2.mas_bottom);
        make.left.equalTo(adressImgView);
        make.right.equalTo(adressImgView);
        make.height.mas_equalTo(45);
    }];
    //联系人
    UIView *nameView=[self getTextFieldTypeWithTitle:@"联系人" placeHold:@"请输入收货人姓名"];
    self.txtName=[nameView subviews][1];
    [adressImgView addSubview:nameView];
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(adressView.mas_bottom);
        make.left.equalTo(adressImgView);
        make.right.equalTo(adressImgView);
        make.height.equalTo(adressView);
    }];
    
    //联系电话
    UIView *phoneView=[self getTextFieldTypeWithTitle:@"联系电话" placeHold:@"请输入收货人电话"];
    self.txtPhone=[phoneView subviews][1];
    self.txtPhone.keyboardType=UIKeyboardTypeNumberPad;
    [adressImgView addSubview:phoneView];
    [phoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameView.mas_bottom);
        make.left.equalTo(adressImgView);
        make.right.equalTo(adressImgView);
        make.height.equalTo(adressView);
    }];
    self.isSelect=YES;
    UIButton *xieyiBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [xieyiBtn setBackgroundImage:[UIImage imageNamed:@"on_line"] forState:UIControlStateNormal];
    [adressImgView addSubview:xieyiBtn];
    xieyiBtn.titleLabel.font=kFont(15);
    [xieyiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(adressImgView).offset(16);
        make.top.equalTo(phoneView.mas_bottom).offset(12);
        make.width.mas_equalTo(15);
        make.height.mas_equalTo(15);
    }];
    [xieyiBtn addTarget:self action:@selector(xieyiBtn:) forControlEvents:UIControlEventTouchUpInside];
    //协议名称
    UITapGestureRecognizer *labTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labClick)];
    
    
    UILabel *labXie=[[UILabel alloc]init];
    labXie.userInteractionEnabled=YES;
    [labXie addGestureRecognizer:labTap];
    labXie.textColor=[UIColor blueColor];
    labXie.font=kFont(15);
    NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
     NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"《善意科技用户购买服务协议》" attributes:attribtDic];
    labXie.attributedText = attribtStr;
    [adressImgView addSubview:labXie];
    [labXie mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(xieyiBtn.mas_right).offset(3);
        make.centerY.equalTo(xieyiBtn);
    }];
    
    [adressImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(labXie).offset(12);
        make.top.equalTo(self.infoImgView.mas_bottom).offset(10);
        
    }];
    
    //支付按钮
    UIButton *buyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.buyButton=buyButton;
    [buyButton setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [buyButton setBackgroundImage:[UIImage imageNamed:@"common_btn_disable"] forState:UIControlStateDisabled];
    [buyButton setTitle:@"立即支付" forState:UIControlStateNormal];
    [self.view addSubview:buyButton];
    buyButton.enabled=NO;
    buyButton.titleLabel.font=kFont(15);
    [buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.top.equalTo(adressImgView.mas_bottom).offset(12);
        make.right.equalTo(self.view).offset(-padding);
        make.height.mas_equalTo(40);
    }];
    [buyButton addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)labClick
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"agreement" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];
    [CCWebViewController showWithContro:self withUrlStr:[url absoluteString] withTitle:@"用户协议"];
}

//单选按钮事件
-(void)xieyiBtn:(UIButton *)btn
{
    self.isSelect=!self.isSelect;
    if (self.isSelect) {
        [btn setBackgroundImage:[UIImage imageNamed:@"on_line"] forState:UIControlStateNormal];
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"check_no"] forState:UIControlStateNormal];
    }
    [self TextInput];

}

-(void)viewClick
{
    [self.view endEditing:YES];
}
//生成右边为文本框的视图
-(UIView *)getTextFieldTypeWithTitle:(NSString *)title placeHold:(NSString *)placeHold
{
    //添加内容
    UIView *contentView=[[UIView alloc]init];
    contentView.backgroundColor=[UIColor whiteColor];
    //左右间距
    CGFloat leftPadding=12;
    UILabel *titleLab=[[UILabel alloc]init];
    titleLab.text=title;
    titleLab.font=kFont(15);
    [contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(leftPadding);
        make.height.equalTo(contentView);
        make.top.equalTo(contentView);
    }];
    
    //文本框
    UITextField *text=[[UITextField alloc]init];
    text.placeholder=placeHold;
    text.delegate=self;
    text.font=titleLab.font;
    text.textAlignment=NSTextAlignmentRight;
    text.borderStyle=UITextBorderStyleNone;
    
    //text.keyboardType=UIKeyboardTypeNumberPad;
    [contentView addSubview:text];
    [text mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(contentView).offset(-leftPadding);
        make.centerY.equalTo(contentView);
        make.height.equalTo(contentView).multipliedBy(0.7);
        make.left.mas_equalTo(60);
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

//支付结果
-(void)payClick{
    
    //保存收货地址
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"insertRecInfo*%@*%@*%@*%@",self.payModel.Order,self.txtAdress.text,self.txtName.text,self.txtPhone.text];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        //保存订单code
       NSUserDefaults *userDefault= [NSUserDefaults standardUserDefaults];
        [userDefault setObject:self.payModel.Order forKey:@"OrderCode"];
        //支付
        [self jumpToBizPay];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
    
    
}

- (void)jumpToBizPay {
    //判断是否安装了微信
    if(![WXApi isWXAppInstalled])
    {
        [SVProgressHUD showErrorWithStatus:@"该设备暂未安装微信"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
        return ;
    }else if(![WXApi isWXAppSupportApi])
    {
        [SVProgressHUD showErrorWithStatus:@"安装的微信版本不支持支付"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:3.0];
        return ;
    }
    SunPayResultModel *pay=self.payModel;
    
    //生成签名
    time_t now;
    time(&now);
    NSString *timeStamp=[NSString stringWithFormat:@"%ld",now];
    
    NSString *md5Sign=[self createMD5SingForPay:@"wx1ff6993d14670f05" partnerid:@"1328894601" prepayid: pay.Prepay_Id package:@"Sign=WXPay" noncestr:pay.NoncerStr timestamp:[timeStamp intValue]];
    
    PayReq *request = [[PayReq alloc] init];
    /** 商家向财付通申请的商家id */
    request.partnerId =@"1328894601";
    /** 预支付订单 */
    request.prepayId=pay.Prepay_Id;
    /** 商家根据财付通文档填写的数据和签名 */
    request.package = @"Sign=WXPay";
    /** 随机串，防重发 */
    request.nonceStr= pay.NoncerStr;
    /** 时间戳，防重发 */
    request.timeStamp= [timeStamp intValue];
    /** 商家根据微信开放平台文档对数据做的签名 */
    request.sign= md5Sign;
    /*! @brief 发送请求到微信，等待微信返回onResp
     *
     * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
     * SendAuthReq、SendMessageToWXReq、PayReq等。
     * @param req 具体的发送请求，在调用函数后，请自己释放。
     * @return 成功返回YES，失败返回NO。
     */
    [WXApi sendReq: request];

}





-(NSString *)createMD5SingForPay:(NSString *)appid_key partnerid:(NSString *)partnerid_key prepayid:(NSString *)prepayid_key package:(NSString *)package_key noncestr:(NSString *)noncestr_key timestamp:(UInt32)timestamp_key{
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:appid_key forKey:@"appid"];
    [signParams setObject:noncestr_key forKey:@"noncestr"];
    [signParams setObject:package_key forKey:@"package"];
    [signParams setObject:partnerid_key forKey:@"partnerid"];
    [signParams setObject:prepayid_key forKey:@"prepayid"];
    [signParams setObject:[NSString stringWithFormat:@"%u",(unsigned int)timestamp_key] forKey:@"timestamp"];
    
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [signParams allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[signParams objectForKey:categoryId] isEqualToString:@""]
            && ![[signParams objectForKey:categoryId] isEqualToString:@"sign"]
            && ![[signParams objectForKey:categoryId] isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [signParams objectForKey:categoryId]];
        }
    }
    //添加商户密钥key字段
    NSString *WX_PartnerKey=@"00AA115C034E5BD51FB6FA234F1BBAB4";
    [contentString appendFormat:@"key=%@", WX_PartnerKey];
    NSString *result = [self md5:contentString];
    return result;
}

// MD5加密算法
-(NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    //加密规则，因为逗比微信没有出微信支付demo，这里加密规则是参照安卓demo来得
    unsigned char result[16]= "0123456789abcdef";
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    //这里的x是小写则产生的md5也是小写，x是大写则md5是大写，这里只能用大写，逗比微信的大小写验证很逗
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}










@end
