//
//  SunErrorModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/26.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunErrorModel : NSObject
@property(nonatomic,strong)NSString *error;
@property(nonatomic,strong)NSString *msg;
+(instancetype)sunErroWithArray:(id)json;
@end
