//
//  SunDeviceTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunDeviceModel;
@interface SunDeviceTableViewCell : UITableViewCell
@property(nonatomic,strong)SunDeviceModel *deviceModel;

+(instancetype)cellWithTabelView:(UITableView *)tableview;
@end
