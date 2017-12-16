//
//  SunPatientTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/24.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunPatientModel;
@class SunPatientTableViewCell;
@protocol SunPatientTableViewCellDelegate <NSObject>

-(void)tableVie:(SunPatientTableViewCell *)cell WithDetail:(UIButton *)sender;

@end
@interface SunPatientTableViewCell : UITableViewCell
@property(nonatomic,strong)SunPatientModel *patientModel;
@property(nonatomic,weak)UIButton *btnData;
@property(nonatomic,weak)id<SunPatientTableViewCellDelegate> delegate;

+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
