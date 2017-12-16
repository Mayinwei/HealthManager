//
//  SunMeTabelViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunBasicModel;
@interface SunMeTabelViewCell : UITableViewCell

//基础类型
@property(nonatomic,strong)SunBasicModel *basicModel;

+(instancetype)cellWithTableView:(UITableView *)tableView;
@end
