//
//  SunMyServiceTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SunMyServerModel;
@class SunMyServiceTableViewCell;
@protocol SunMyServiceTableViewCellDelegate <NSObject>

-(void)tableViewCell:(SunMyServiceTableViewCell *)cell WithDetail:(UIButton *)sender;
@end
@interface SunMyServiceTableViewCell : UITableViewCell

@property(nonatomic,weak)UIButton *btnData;
@property(nonatomic,strong)SunMyServerModel *servermodel;

@property(nonatomic,weak)id<SunMyServiceTableViewCellDelegate> delegate;

+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
