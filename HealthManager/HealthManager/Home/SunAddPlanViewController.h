//
//  SunAddPlanViewController.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SunAddType){
    SunAddTypePlan,
    SunAddTypeRecord
};

@interface SunAddPlanViewController : UIViewController
@property(nonatomic,strong)NSString *MedDCode;

//添加的类型
@property(nonatomic,assign)NSInteger *type;


@end
