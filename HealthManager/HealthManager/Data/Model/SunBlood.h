//
//  SunBlood.h
//  HealthManager
//
//  Created by 李金星 on 2016/12/28.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunBlood : NSObject
@property(nonatomic,strong)NSString *SYSTOLIC;
@property(nonatomic,strong)NSString *DIASTOLIC;
@property(nonatomic,strong)NSString *HEARTRATE;
@property(nonatomic,strong)NSString *RESULT;
@property(nonatomic,strong)NSString *STARTTIME;
//行号
@property(nonatomic,strong)NSString *ROWNUMBER;
@property(nonatomic,strong)NSString *Selected;
@end
