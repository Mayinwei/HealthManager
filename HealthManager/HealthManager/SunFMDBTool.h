//
//  SunFMDBTool.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/21.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunFMDBTool : NSObject

//根据code查找用户名称
+(NSDictionary *)nameWithUserCode:(NSString *)code type:(NSString *)type;
@end
