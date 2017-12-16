//
//  SunPlanDetailTableViewCell.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SunPlanDetailTableViewCell : UITableViewCell
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labNum;
@property(nonatomic,strong)UILabel *labWay;
@property(nonatomic,strong)UILabel *labTime;


+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
