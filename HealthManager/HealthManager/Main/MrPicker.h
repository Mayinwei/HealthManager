//
//  MrPicker.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MrPicker;
@protocol MrPickerDelegate <NSObject>

-(void)pickerWith:(MrPicker *)picker title:(NSString *)title;

@end
@interface MrPicker : UIView


//按钮背景颜色
@property(nonatomic,strong)UIColor *btnBgColor;
//底部按钮
@property(nonatomic,strong)UIButton *btn;
//数据
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,weak) id<MrPickerDelegate> delegate;
@end
