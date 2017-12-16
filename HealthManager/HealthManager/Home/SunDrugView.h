//
//  SunDrugView.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/14.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunDrugView;
@protocol SunDrugViewDelegate <NSObject>

-(void)sunDrugViewFu:(SunDrugView *)drugView;
-(void)sunDrugViewAgain:(SunDrugView *)drugView;
@end

@interface SunDrugView : UIView
@property(nonatomic,strong)UIImageView *bagImgView;
@property(nonatomic,strong)UILabel *name;

@property(nonatomic,strong)UILabel *num;
@property(nonatomic,strong)UILabel *ways;
@property(nonatomic,strong)UILabel *timeName;
@property(nonatomic,strong)UILabel *time;
@property(nonatomic,strong)UIButton *fuBtn;
@property(nonatomic,strong)UIButton *againBtn;
@property(nonatomic,weak)id<SunDrugViewDelegate> delegate;
@end
