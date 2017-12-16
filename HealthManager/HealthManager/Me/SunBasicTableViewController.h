//
//  SunBasicTableViewController.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunGroupModel;
@interface SunBasicTableViewController : UITableViewController

//容纳所有分组
@property(nonatomic,strong)NSMutableArray *arrayData;

-(void)refreshData;
//组属性
-(SunGroupModel *)addToArrayData;

@end
