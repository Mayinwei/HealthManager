//
//  MrDatePicker.m
//  Demo
//
//  Created by Mr_yiniwei on 2017/1/4.
//  Copyright © 2017年 天津市善医科技发展有限公司. All rights reserved.
//  日历控件

#import "MrDatePicker.h"

@interface MrDatePicker()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *contentView;


@end
@implementation MrDatePicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //背景遮罩层
        UIView *bgView=[[UIView alloc]init];
        self.bgView=bgView;
        bgView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.4];
        //bgView.alpha=0.6;
        [self addSubview:bgView];
        //添加手势
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]init];
        [tap addTarget:self action:@selector(tapClick)];
        [bgView addGestureRecognizer:tap];
        //容器
        UIView *contentView=[[UIView alloc]init];
        self.contentView=contentView;
        [bgView addSubview:contentView];
        
        //日期控件
        UIDatePicker *datePicker=[[UIDatePicker alloc]init];
        self.datePicker=datePicker;
        datePicker.backgroundColor=[UIColor whiteColor];
        [datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];
        [datePicker setTimeZone:[NSTimeZone localTimeZone]];
        // 设置当前显示时间
        [datePicker setDate:[NSDate date] animated:YES];
        // 设置显示最大时间（此处为当前时间）
        [datePicker setMaximumDate:[NSDate date]];
        // 设置UIDatePicker的显示模式
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        [contentView addSubview:datePicker];
        //按钮
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btn=btn;
        btn.titleLabel.font=[UIFont systemFontOfSize:17];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        //UIColor *color=MrColor(0, 221, 246);
        //UIColor *color=MrColor(33, 135, 244);
        [btn setBackgroundImage:[UIImage imageNamed:@"btn-angle"] forState:UIControlStateNormal];
        [contentView addSubview:btn];
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

//手势
-(void)tapClick
{
    [self animationContent];
}
-(void)btnClick
{
    
    //获取时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:self.datePicker.date];
    if ([self.delegate respondsToSelector:@selector(datePickerWith:time:)]) {
        [self.delegate datePickerWith:self time:strDate];
    }
    [self animationContent];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.bgView.frame=self.frame;
    CGFloat contentViewHeight=249;
    CGFloat y=CGRectGetMaxY(self.frame);
    self.contentView.frame=CGRectMake(0, y, self.frame.size.width, contentViewHeight);
    //按钮
    CGFloat btnHeight=39;
    CGFloat btnY=self.contentView.frame.size.height-btnHeight;
    self.btn.frame=CGRectMake(0, btnY, self.frame.size.width, btnHeight);
    //日历控件
    CGFloat datePickerH=self.contentView.frame.size.height-btnHeight;
    self.datePicker.frame=CGRectMake(0, 0, self.frame.size.width, datePickerH);
    
    //执行动画
     __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.contentView.transform=CGAffineTransformMakeTranslation(0, -contentViewHeight);
    } completion:nil];
}

-(void)animationContent
{
    __weak typeof(self) weakSelf = self;
    CGFloat h=self.contentView.frame.size.height;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        weakSelf.contentView.transform=CGAffineTransformMakeTranslation(0, h);
        weakSelf.bgView.alpha-=0.1;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
//颜色转图片
-(UIImage*) createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//设置按钮背景颜色
-(void)setBtnBgColor:(UIColor *)btnBgColor
{
   [self.btn setBackgroundImage:[self createImageWithColor:btnBgColor] forState:UIControlStateNormal];
}

//日期类型
-(void)setPickerModel:(NSString *)pickerModel
{
    if ([pickerModel isEqualToString:@"UIDatePickerModeTime"]) {
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
    }
    
}

@end
