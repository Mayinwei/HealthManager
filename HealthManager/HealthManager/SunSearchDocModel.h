//
//  SunSearchDocModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunSearchDocModel : NSObject
@property(nonatomic,copy)NSString *DOCCODE;
@property(nonatomic,copy)NSString *USERNAME;
//职务
@property(nonatomic,copy)NSString *POST;
//部门
@property(nonatomic,copy)NSString *DEPT;
//擅长
@property(nonatomic,copy)NSString *PROFILE;
//医院
@property(nonatomic,copy)NSString *HOSNAME;
@property(nonatomic,copy)NSString *HEADPIC;
@property(nonatomic,copy)NSString *ORGCODE;
@end
