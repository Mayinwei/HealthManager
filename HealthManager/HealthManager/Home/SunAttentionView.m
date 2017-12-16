//
//  SunAttentionView.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/13.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunAttentionView.h"
#import "SunCutImageView.h"
@interface SunAttentionView()

@end
@implementation SunAttentionView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImageView *imgView=[[UIImageView alloc]init];
        [self addSubview: imgView];
        
        self.imgView=imgView;
        
        UILabel *lable=[[UILabel alloc]init];
        [self addSubview:lable];
        lable.font=[UIFont systemFontOfSize:14];
        self.lable=lable;
        lable.textAlignment=NSTextAlignmentCenter;
        
        UIView *cutView=[[UIView alloc]init];
        cutView.backgroundColor=MrColor(0, 192, 248);
        self.cutView=cutView;
        [self addSubview:cutView];
    }
    return self;
}

//设置尺寸
-(void)layoutSubviews{    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self);
        make.height.equalTo(self.imgView.mas_width);
        make.left.mas_equalTo(0);
    }];
    //必须要有尺寸
   self.imgView.image = [SunCutImageView circleImage:self.imgView.image withParam:0 lineColor:[UIColor clearColor]];
    

    [self.lable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self);
        make.top.equalTo(self.imgView.mas_bottom);
        make.bottom.equalTo(self.mas_bottom).offset(-3);
    }];
    
    //添加底部分割线
    
    if (!self.isAdd) {
        [self.cutView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.height.mas_equalTo(3);
            make.left.equalTo(self);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    
}


@end
