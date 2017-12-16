//
//  SunPlanDetailViewController.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SunPlanDetailViewController : UIViewController
/**
 *  计划明细编码
 */
@property(nonatomic,strong)NSString *MedDCode;
/**
 *  开始时间
 */
@property(nonatomic,strong)NSString *StartTime;
@end
