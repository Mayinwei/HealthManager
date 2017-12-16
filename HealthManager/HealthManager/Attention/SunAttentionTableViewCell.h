//
//  SunAttentionTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunAttentionModel;
@interface SunAttentionTableViewCell : UITableViewCell


@property(nonatomic,strong)SunAttentionModel *attModel;
+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
