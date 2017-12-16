//
//  MrPicker.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "MrPicker.h"


@interface MrPicker()<UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIPickerView *Picker;
@property(nonatomic,assign)int index;
@end

@implementation MrPicker

-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}
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
        UIPickerView *Picker=[[UIPickerView alloc]init];
        //Picker.
        Picker.backgroundColor=[UIColor whiteColor];
        self.Picker=Picker;
        Picker.delegate=self;
        Picker.dataSource=self;
        [contentView addSubview:Picker];
        //按钮
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btn=btn;
        btn.titleLabel.font=[UIFont systemFontOfSize:17];
        [btn setTitle:@"确定" forState:UIControlStateNormal];
        //UIColor *color=MrColor(0, 221, 246);
        [btn setBackgroundImage:[UIImage imageNamed:@"btn-angle"] forState:UIControlStateNormal];
        [contentView addSubview:btn];
        [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark --- 与DataSource有关的代理方法
//返回列数（必须实现）
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回每列里边的行数（必须实现）
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrayData.count;
}

//设置组件中每行的标题row:行
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   return self.arrayData[row];
}

//选中行的事件处理
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
   self.index=(int)row;
}



//手势
-(void)tapClick
{
    [self animationContent];
}
-(void)btnClick
{
    
    NSString *title=self.arrayData[self.index];
    if ([self.delegate respondsToSelector:@selector(pickerWith:title:)]) {
        [self.delegate pickerWith:self title:title];
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
    self.Picker.frame=CGRectMake(0, 0, self.frame.size.width, datePickerH);
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



@end
