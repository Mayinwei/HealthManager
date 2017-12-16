//
//  SunBloodTableViewCell.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/3.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunBloodDetailModel;
@class SunDataBloodView;
@interface SunBloodTableViewCell : UITableViewCell
@property(nonatomic,strong)SunBloodDetailModel *bloodDetail;
@property(nonatomic,strong)SunDataBloodView *blood;
+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
