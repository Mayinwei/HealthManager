//
//  MrDatePicker.h
//  Demo
//
//  Created by 李金星 on 2017/1/4.
//  Copyright © 2017年 天津市善医科技发展有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MrDatePicker;
@protocol MrDatePickerDelegate <NSObject>

-(void)datePickerWith:(MrDatePicker *)datepicker time:(NSString *)time;

@end

@interface MrDatePicker : UIView
//按钮背景颜色
@property(nonatomic,strong)UIColor *btnBgColor;
//日期类型 UIDatePickerModeTime
@property(nonatomic,strong)NSString *pickerModel;
//底部按钮
@property(nonatomic,strong)UIButton *btn;
//时间控件
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,weak) id<MrDatePickerDelegate> delegate;


@end
