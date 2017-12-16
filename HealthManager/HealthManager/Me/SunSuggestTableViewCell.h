//
//  SunSuggestTableViewCell.h
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunSuggestModel;
@interface SunSuggestTableViewCell : UITableViewCell
@property(nonatomic,strong)SunSuggestModel *suggest;

+(instancetype)cellWithTabelView:(UITableView *)tableview;
- (float)getAutoCellHeight;
@end
