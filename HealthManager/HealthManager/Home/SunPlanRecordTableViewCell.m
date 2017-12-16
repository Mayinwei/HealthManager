//
//  SunPlanRecordTableViewCell.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/10.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunPlanRecordTableViewCell.h"

@implementation SunPlanRecordTableViewCell

+(instancetype)cellWithTabelView:(UITableView *)tableview
{
    static NSString *ID=@"record";
    SunPlanRecordTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunPlanRecordTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
        [self.contentView addSubview:labName];
        //计量
        UILabel *labNum=[[UILabel alloc]init];
        labNum.font=labName.font;
        self.labNum=labNum;
        [self.contentView addSubview:labNum];
        //方法
        UILabel *labWay=[[UILabel alloc]init];
        labWay.font=labName.font;
        self.labWay=labWay;
        [self.contentView addSubview:labWay];
        //时间
        UILabel *labTime=[[UILabel alloc]init];
        labTime.textColor=[UIColor lightGrayColor];
        labTime.font=kFont(20);
        self.labTime=labTime;
        [self.contentView addSubview:labTime];
        //日期
        UILabel *labDate=[[UILabel alloc]init];
        labDate.textColor=[UIColor lightGrayColor];
        labDate.font=labName.font;
        self.labDate=labDate;
        [self.contentView addSubview:labDate];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat lefPadding=20;
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(lefPadding);
        make.top.equalTo(self).offset(5);
    }];
    //计量
    [self.labNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.labName);
        make.centerX.equalTo(self);
    }];
    //时间
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-lefPadding);
        make.centerY.equalTo(self.labName);
    }];
    //方式
    [self.labWay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(lefPadding);
        make.bottom.equalTo(self).offset(-5);
    }];
    
    [self.labDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-lefPadding);
        make.centerY.equalTo(self.labWay);
    }];
    
}

@end
