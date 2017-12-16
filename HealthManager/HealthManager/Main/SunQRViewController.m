//
//  SunQRViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/10.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunQRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SunDeviceBindiewController.h"
#import "SunNavigationController.h"

@interface SunQRViewController ()<AVCaptureMetadataOutputObjectsDelegate>

- (IBAction)qrClose:(id)sender;
//开灯
- (IBAction)openLight:(id)sender;


//会话
@property(nonatomic,strong)AVCaptureSession *session;
//输入设备
@property(nonatomic,strong)AVCaptureDeviceInput *deviceInput;
//输出设备
@property(nonatomic,strong)AVCaptureMetadataOutput *outPut;

//预览图
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

//划线图层
@property(nonatomic,strong)CALayer *drawLayer;

@end

@implementation SunQRViewController

//懒加载
//会话
-(AVCaptureSession *)session
{
    if (_session==nil) {
        _session=[[AVCaptureSession alloc] init];
    }
    return _session;
}

//输入设备
-(AVCaptureDeviceInput *)deviceInput
{
    if (_deviceInput==nil) {
        //获取摄像头
     AVCaptureDevice *dev=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

        NSError *error=nil;
        _deviceInput=[AVCaptureDeviceInput deviceInputWithDevice:dev error:&error];
        if (error==nil) {
            return _deviceInput;
        }else{
            NSLog(@"%@", error);
        }
    }
    return _deviceInput;
}

//输出设备
-(AVCaptureMetadataOutput *)outPut
{
    if (_outPut==nil) {
        _outPut=[[AVCaptureMetadataOutput alloc] init];
        
    }
    return _outPut;
}
//预览图
-(AVCaptureVideoPreviewLayer *)previewLayer
{
    if (_previewLayer==nil) {
        _previewLayer=[[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        
    }
    return _previewLayer;
}

-(CALayer *)drawLayer
{
    if (_drawLayer==nil) {
        _drawLayer=[[CALayer alloc] init];
    }
    return _drawLayer;
}

//控制器创建完毕，子控制器不一定创建完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background_tou"] forBarMetrics:UIBarMetricsDefault];
    //添加view
    UIView *bgView=[[UIView alloc]init];
    bgView.backgroundColor=[UIColor blackColor];
    bgView.alpha=0.4;
    bgView.frame=CGRectMake(0, -20, SCREEN_WIDTH, 64);
    [self.navigationController.navigationBar insertSubview:bgView atIndex:0];
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted)
        {
            [[[UIAlertView alloc] initWithTitle:nil message:@"本应用无访问相机的权限，如需访问，可在设置中修改" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil] show];
            return;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //开始动画
    [self startAnimation];
    //开始扫描
    [self startScan];
    
}



-(void)startAnimation
{
    UIView *contentView=[[UIView alloc]init];
    contentView.layer.masksToBounds=YES;
    [self.view addSubview:contentView];
    //添加布局
    contentView.backgroundColor=[UIColor clearColor];
    CGFloat wH=200;
    CGFloat x=(SCREEN_WIDTH-wH)/2;
    CGFloat y=(SCREEN_HEIGHT-wH)/2;
    contentView.frame=CGRectMake(x, y, wH, wH);
    //添加线框
    UIImageView *bgImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"qrcode_border"]];
    [contentView addSubview:bgImgView];
    bgImgView.frame=CGRectMake(0, 0, wH, wH);
    //冲击波
    UIImageView *scanImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"qrcode_scanline_qrcode"]];
    [contentView addSubview:scanImgView];
    scanImgView.frame=CGRectMake(0, -wH, wH, wH);
    
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionRepeat animations:^{
        scanImgView.transform=CGAffineTransformMakeTranslation(0, wH*2);
    } completion:^(BOOL finished) {
        scanImgView.transform=CGAffineTransformIdentity;
    }];
}

-(void)startScan
{
    //1.判断是否能够将输入添加到会话
    if(![self.session canAddInput:self.deviceInput])
    {return ;}
    //2.判断是否能够将输出添加到会话
    if(![self.session canAddOutput:self.outPut])
    {return ;}
    //3.讲输入输出添加到会话
    [self.session addInput:self.deviceInput];
   
    [self.session addOutput:self.outPut];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    //4.设置输出能够解析的数据类型
    //解析任何类型，这个要放到添加会话之后
    self.outPut.metadataObjectTypes=self.outPut.availableMetadataObjectTypes;
    
    //5.设置输出对想的代理，只要解析成功就通知代理
    [self.outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //添加预览图层
    self.previewLayer.frame=[UIScreen mainScreen].bounds;
    self. previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // layer.videoGravity = AVLayerVideoGravityResize;
  
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    //6.告诉session开始扫描
    [self.session startRunning];
}




//获取扫描结果
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    @try {
        
    
    
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *name=[defaults objectForKey:@"NotificationName"];
        // 0.移除边线
        [self clearDrawLayer];
        //self.resultLable.text=[metadataObjects.lastObject stringValue];
        NSString *result=[metadataObjects.lastObject stringValue];
        //判断是否有换行符
        if([result rangeOfString:@"\n"].location !=NSNotFound&&result!=nil)
        {
            result=[result stringByReplacingOccurrencesOfString:@"\n" withString:@"*"];
            AudioServicesPlaySystemSound((UInt32)1015);
            SunDeviceBindiewController *bind=[[SunDeviceBindiewController alloc]init];
            bind.EquCode=[result componentsSeparatedByString:@"*"][1];
            [self dismissViewControllerAnimated:YES completion:nil];
            //创建个通知
            NSDictionary *dic=[NSDictionary dictionaryWithObject:[result componentsSeparatedByString:@"*"][1] forKey:@"Info"];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
            //停止扫描
            [self.session stopRunning];
        }//else if([name isEqualToString:@"SunDeviceBindiewController"]){return;}
        //判断是否是网址，只让首页扫码跳转
        else if([result rangeOfString:@"http://"].location !=NSNotFound&&result!=nil)
        {
            AudioServicesPlaySystemSound((UInt32)1015);
            [self dismissViewControllerAnimated:YES completion:nil];
            //创建个通知
            NSDictionary *dic=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"SunUrl*%@",result] forKey:@"Info"];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
            //停止扫描
            [self.session stopRunning];
        }else if([result rangeOfString:@"SunAttention"].location !=NSNotFound&&result!=nil)
        {
            //扫描关注
            AudioServicesPlaySystemSound((UInt32)1015);
            [self dismissViewControllerAnimated:YES completion:nil];
            //创建个通知
            NSDictionary *dic=[NSDictionary dictionaryWithObject:result forKey:@"Info"];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
            //停止扫描
            [self.session stopRunning];
        }else{
            //普通不能识别的文本（可能是血糖仪）
            AudioServicesPlaySystemSound((UInt32)1015);
            [self dismissViewControllerAnimated:YES completion:nil];
            //创建个通知
            NSDictionary *dic=[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"NoFound*%@",result] forKey:@"Info"];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:dic];
            //停止扫描
            [self.session stopRunning];
        }
        //如果什么也不是，跳转空页,显示结果
        
        // 1.绘制路径
        for( NSObject *object in metadataObjects)
        {
            if([ object isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
            {
                // 转换元数据对象坐标
                AVMetadataMachineReadableCodeObject *codeObject =(AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataObject *)object];
                
                [self drawLine:codeObject];
            }
        }
        //停止扫描
        [self.session stopRunning];
    } @catch (NSException *exception) {
        //停止扫描
        [self.session stopRunning];
    }
    
}


- (IBAction)qrClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}





-(void)drawLine:(AVMetadataMachineReadableCodeObject *)codeObj
{
   
    //判断是否是空
    if([codeObj.corners count]==0)
    {
        return;
    }
    // 2.创建图层
    CAShapeLayer *layer = [[CAShapeLayer alloc]init];
    layer.lineWidth = 4;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    
    // 3.1创建路径
    UIBezierPath  *path = [[UIBezierPath alloc]init];
    CGPoint point = CGPointZero;
    // 3.2移动到第一个点
    int index = 0;
    
    // 取出第0个点
    CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)codeObj.corners[index++], &point);
    
    [path moveToPoint:point ];
    // 3.3设置其它点
    while (index < codeObj.corners.count)
    {
        CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)codeObj.corners[index++], &point);
        [path addLineToPoint:point];
    }
    // 3.4关闭路径
    [path closePath];    
    
    layer.path=path.CGPath;
    [self.drawLayer addSublayer:layer];
    self.drawLayer.frame=[UIScreen mainScreen].bounds;
    [self.previewLayer addSublayer:self.drawLayer];
}

-(void) clearDrawLayer{
    // 1.判断是否有边线
    if (self.drawLayer.sublayers.count == 0 || self.drawLayer.sublayers == nil)
    {
        return;
    }
    // 2.移除所有边线
    for (CALayer *layer in self.drawLayer.sublayers)
    {
        [layer removeFromSuperlayer];
    }
}

//开灯或关灯
- (IBAction)openLight:(UIButton *)btn {
    
    btn.selected = !btn.isSelected;
    
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch]) {
        
        [device lockForConfiguration:nil];
        
        if (btn.selected) {
            
            [device setTorchMode:AVCaptureTorchModeOn];
            
        }else{
            
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
        
    }
}
@end
