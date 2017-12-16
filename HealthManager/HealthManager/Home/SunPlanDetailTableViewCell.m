//
//  SunPlanDetailTableViewCell.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunPlanDetailTableViewCell.h"

@implementation SunPlanDetailTableViewCell

+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"plandetail";
    SunPlanDetailTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunPlanDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //名称
        UILabel *labName=[[UILabel alloc]init];
        labName.font=kFont(15);
        self.labName=labName;
        [self addSubview:labName];
        //计量
        UILabel *labNum=[[UILabel alloc]init];
        labNum.font=labName.font;
        self.labNum=labNum;
        [self addSubview:labNum];
        //方法
        UILabel *labWay=[[UILabel alloc]init];
        labWay.font=labName.font;
        self.labWay=labWay;
        [self addSubview:labWay];
        //时间
        UILabel *labTime=[[UILabel alloc]init];
        labTime.textColor=[UIColor lightGrayColor];
        labTime.font=labName.font;
        self.labTime=labTime;
        [self addSubview:labTime];
        
    }
    return self;
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(17);
        make.height.equalTo(self).multipliedBy(0.333);
    }];
    [self.labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.labName);
        make.left.equalTo(self.labName.mas_right).offset(15);
        make.height.equalTo(self.labName);
    }];
    //方式
    [self.labWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName);
        make.top.equalTo(self.labName.mas_bottom);
        make.height.equalTo(self.labName);
    }];
    //时间
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName);
        make.top.equalTo(self.labWay.mas_bottom);
        make.height.equalTo(self.labName);
    }];
}

@end
