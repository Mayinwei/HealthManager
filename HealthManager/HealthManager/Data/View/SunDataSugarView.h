//
//  SunDataSugarView.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/20.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunDataSugarView;
@protocol SunDataSugarViewDelegate  <NSObject>
-(void)sugarViewPlaySound:(SunDataSugarView *)sugar;
@end

@interface SunDataSugarView : UIView
@property(nonatomic,strong)UILabel *higLab;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UIButton *soundButton;
@property(nonatomic,strong)UILabel *sTimeLab;
//不需要设置值
@property(nonatomic,strong)UILabel *labTitle;
@property(nonatomic,strong)UILabel *higUnit;

@property(nonatomic,weak)id<SunDataSugarViewDelegate> delegate;
@end
