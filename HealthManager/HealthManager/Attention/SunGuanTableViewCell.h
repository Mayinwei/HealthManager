//
//  SunGuanTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunGuanTableViewCell;
@protocol SunGuanTableViewCellDelegate <NSObject>

-(void)guanCell:(SunGuanTableViewCell *)cell;

@end

@class SunGuanInfoModel;
@interface SunGuanTableViewCell : UITableViewCell
@property(nonatomic,strong)SunGuanInfoModel *guanModel;
@property(nonatomic,weak) id<SunGuanTableViewCellDelegate> delegate;

+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
