//
//  SunGroupModel.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunGroupModel : NSObject
@property (nonatomic,copy) NSString *header;
@property (nonatomic,copy) NSString *fotter;
@property(nonatomic,strong)NSArray *items;

//快速创建累
+(instancetype)group;
@end
