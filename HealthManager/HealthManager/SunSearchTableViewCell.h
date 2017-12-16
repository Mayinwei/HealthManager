//
//  SunSearchTableViewCell.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunSearchDocModel;
@interface SunSearchTableViewCell : UITableViewCell
@property(nonatomic,strong)SunSearchDocModel *searchDoc;


+(instancetype)cellWithTableView:(UITableView *)tableview;
@end
