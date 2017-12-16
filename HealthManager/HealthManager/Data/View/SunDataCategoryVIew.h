//
//  SunDataCategoryVIew.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/20.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunDataCategoryView;
@protocol SunDataCategoryViewDelegate <NSObject>

-(void)sunDataCategory:(SunDataCategoryView *)sun;

@end
@interface SunDataCategoryView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *leftImgView;
@property (weak, nonatomic) IBOutlet UILabel *firstLab;
@property (weak, nonatomic) IBOutlet UILabel *secondLab;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;
@property(nonatomic,strong)id<SunDataCategoryViewDelegate> delegate;
- (IBAction)joinClick:(id)sender;



+(instancetype)viewFromNib;
@end
