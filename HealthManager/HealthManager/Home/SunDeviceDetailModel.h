//
//  SunDeviceDetailModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunDeviceDetailModel : NSObject
@property(nonatomic,strong)NSString *ID;
@property(nonatomic,strong)NSString *EQUCODE;
@property(nonatomic,strong)NSString *EQUCATEGORY;
@property(nonatomic,strong)NSString *COMPANYNO;
@property(nonatomic,strong)NSString *EQUTYPE;
@property(nonatomic,strong)NSString *EQUNAME;
@property(nonatomic,strong)NSString *MAXUSERCOUNT;
@property(nonatomic,strong)NSString *CREATEPERSON;
/**
 *  登记时间
 */
@property(nonatomic,strong)NSString *CREATETIME;
@property(nonatomic,strong)NSString *EQUSUBTYPE;
@property(nonatomic,strong)NSString *CheckCode;
/**
 *  激活有效时间
 */
@property(nonatomic,strong)NSString *CHECKCODETIME;
/**
 *  标记
 */
@property(nonatomic,strong)NSString *Flag;

@end
