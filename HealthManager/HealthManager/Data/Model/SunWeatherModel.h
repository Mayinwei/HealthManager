//
//  SunWeatherModel.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/22.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunWeatherModel : NSObject
@property(nonatomic,strong)NSDictionary *location;
@property(nonatomic,strong)NSString *last_update;
@property(nonatomic,strong)NSDictionary *now;
@end
