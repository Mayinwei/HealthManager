//
//  SunSugarTableViewCell.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/4.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunSugarDetailModel;
@class SunDataSugarView;
@interface SunSugarTableViewCell : UITableViewCell

@property(nonatomic,strong)SunSugarDetailModel *sugarDetail;
@property(nonatomic,strong)SunDataSugarView *sugar;
+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
