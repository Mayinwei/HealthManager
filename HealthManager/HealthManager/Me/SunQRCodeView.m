//
//  SunQRCodeView.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunQRCodeView.h"
#import <CoreImage/CoreImage.h>

@interface SunQRCodeView()
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UILabel *lb;
@end
@implementation SunQRCodeView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置背影颜色
        self.backgroundColor=[UIColor colorWithWhite:0 alpha:0.4];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tap];
        //添加图片
        UIImageView *imgView=[[UIImageView alloc]init];
        self.imgView=imgView;
        [self addSubview:imgView];
        //添加标题
        UILabel *lb=[[UILabel alloc]init];
        self.lb=lb;
        lb.font=kFont(17);
        lb.textColor=[UIColor whiteColor];
        lb.text=@"我的二维码";
        [self addSubview:lb];
    }
    return self;
}

-(void)tapClick
{
    [self removeFromSuperview];
}

-(void)setText:(NSString *)text
{
    _text=text;
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
        make.height.equalTo(self.imgView.mas_width);
    }];
    [self erweima:text];
    [self.lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imgView.mas_top).offset(-10);
        make.centerX.equalTo(self);
    }];
}

-(void)erweima:(NSString *)text;

{
    
    //二维码滤镜
    
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //恢复滤镜的默认属性
    
    [filter setDefaults];
    
    //将字符串转换成NSData
    
    NSData *data=[text dataUsingEncoding:NSUTF8StringEncoding];
    
    //通过KVO设置滤镜inputmessage数据
    
    [filter setValue:data forKey:@"inputMessage"];
    
    //获得滤镜输出的图像
    
    CIImage *outputImage=[filter outputImage];
    
    //将CIImage转换成UIImage,并放大显示
    
    _imgView.image=[self createNonInterpolatedUIImageFormCIImage:outputImage withSize:100.0];
    
    
    
    //如果还想加上阴影，就在ImageView的Layer上使用下面代码添加阴影
    
    _imgView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
    
    _imgView.layer.shadowRadius=1;//设置阴影的半径
    
    _imgView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
    
    _imgView.layer.shadowOpacity=0.3;
    
    
    
}



//改变二维码大小

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建bitmap;
    
    size_t width = CGRectGetWidth(extent) * scale;
    
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    
    CGContextScaleCTM(bitmapRef, scale, scale);
    
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 保存bitmap到图片
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    CGContextRelease(bitmapRef);
    
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
    
}


@end
