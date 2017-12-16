//
//  SunMyServerModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunMyServerModel : NSObject
@property(nonatomic,copy)NSString *DOCCODE;
@property(nonatomic,copy)NSString *DOCNAME;
@property(nonatomic,copy)NSString *SVRCODE;
@property(nonatomic,copy)NSString *SVRNAME;
@property(nonatomic,copy)NSString *STATUS;
@property(nonatomic,copy)NSString *ORDCODE;
@property(nonatomic,copy)NSString *SPBDATE;
@property(nonatomic,copy)NSString *SPEDATE;
@property(nonatomic,copy)NSString *SVRPIC;

//服务分类 专项和定制
@property(nonatomic,copy)NSString *SVRCATE;
@end
