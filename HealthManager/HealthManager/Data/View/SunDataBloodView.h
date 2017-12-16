//
//  SunDataBloodView.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/19.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SunDataBloodView;

@protocol SunDataBloodViewDelegate  <NSObject>
-(void)bloodViewPlaySound:(SunDataBloodView *)blood;
@end

@interface SunDataBloodView : UIView
@property(nonatomic,strong)UILabel *higLab;
@property(nonatomic,strong)UILabel *lowLab;
@property(nonatomic,strong)UILabel *rateLab;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UIButton *soundButton;

//不需要设置值
@property(nonatomic,strong)UILabel *labTitle;
@property(nonatomic,strong)UILabel *higUnit;
@property(nonatomic,strong)UILabel *rateUnit;
@property(nonatomic,strong)UILabel *cutLab;

@property(nonatomic,weak)id<SunDataBloodViewDelegate> delegate;
@end
