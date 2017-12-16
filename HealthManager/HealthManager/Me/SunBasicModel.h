//
//  SunBasicModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//  基础模型

#import <Foundation/Foundation.h>



typedef void(^MrSettingItemOperation) ();
@interface SunBasicModel : NSObject

@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subTitle;

//行的高度
@property(nonatomic,assign)CGFloat cellHeight;

/**
 *  提醒数字
 */
@property (nonatomic,copy) NSString *badgeValue;

/**
 *  点击cell要执行的事情
 */
@property (nonatomic,copy) MrSettingItemOperation operation;

+(instancetype)itemWithIcon:(NSString *)icon title:(NSString *)title;
+(instancetype)itemWithTitle:(NSString *)title;
+(instancetype)item;


@end
