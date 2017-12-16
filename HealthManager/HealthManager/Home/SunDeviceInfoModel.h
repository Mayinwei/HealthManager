//
//  SunDeviceInfoModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/12.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunDeviceInfoModel : NSObject
@property(nonatomic,strong)NSString *ID;
@property(nonatomic,strong)NSString *EQUCODE;
@property(nonatomic,strong)NSString *EQUCATEGORY;
@property(nonatomic,strong)NSString *COMPANYNO;
@property(nonatomic,strong)NSString *EQUTYPE;
@property(nonatomic,strong)NSString *EQUNAME;
@property(nonatomic,strong)NSString *MAXUSERCOUNT;
@property(nonatomic,strong)NSString *CREATEPERSON;
@property(nonatomic,strong)NSString *CREATETIME;
@property(nonatomic,strong)NSString *EQUSUBTYPE;
@property(nonatomic,strong)NSString *CheckCode;
@property(nonatomic,strong)NSString *CHECKCODETIME;
@property(nonatomic,strong)NSString *Flag;
@end
