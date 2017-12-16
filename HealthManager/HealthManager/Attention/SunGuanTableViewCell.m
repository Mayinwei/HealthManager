//
//  SunGuanTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//


#import "SunGuanTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SunGuanInfoModel.h"
@interface SunGuanTableViewCell()
@property(nonatomic,strong)UIImageView *headImage;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labSex;
@property(nonatomic,strong)UILabel *labAge;
@property(nonatomic,strong)UILabel *labResult;
@property(nonatomic,strong)UIButton *btnOk;
@property(nonatomic,strong)UILabel *labTime;

@end

@implementation SunGuanTableViewCell

+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"guan";
    SunGuanTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunGuanTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
    
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *headImage=[[UIImageView alloc]init];
        [self.contentView addSubview:headImage];
        self.headImage=headImage;
        //名称
        UILabel *labName=[[UILabel alloc]init];
        labName.font=kFont(15);
        [self.contentView addSubview:labName];
        self.labName=labName;
        //性别
        UILabel *labSex=[[UILabel alloc]init];
        labSex.font=labName.font;
        [self.contentView addSubview:labSex];
        self.labSex=labSex;
        //年龄
        UILabel *labAge=[[UILabel alloc]init];
        labAge.font=labName.font;
        [self.contentView addSubview:labAge];
        self.labAge=labAge;
        //结果
        UILabel *labResult=[[UILabel alloc]init];
        labResult.font=kFont(14);
        labResult.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:labResult];
        self.labResult=labResult;
        
        //请求时间
        UILabel *labTime=[[UILabel alloc]init];
        labTime.font=kFont(13);
        labTime.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:labTime];
        self.labTime=labTime;
        
        //操作按钮
        UIButton *btnOk=[UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOk=btnOk;
        btnOk.titleLabel.font=kFont(13);
        [btnOk setTitle:@"同意" forState:UIControlStateNormal];
        [btnOk setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
        [self.contentView addSubview:btnOk];
        [btnOk  addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
    
}

-(void)btnClick
{
    [self.delegate guanCell:self];
//    if([self.delegate respondsToSelector:@selector(cellWithTableView:)])
//    {
//        
//    }
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.equalTo(self.contentView).multipliedBy(0.7);
        make.width.equalTo(self.headImage.mas_height);
        make.left.equalTo(self.contentView).offset(17);
    }];
    CGFloat leftPadding=8;
    //名称
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImage);
        make.left.equalTo(self.headImage.mas_right).offset(leftPadding);
    }];
    //性别
    [self.labSex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImage);
        make.left.equalTo(self.labName.mas_right).offset(leftPadding);
    }];
    //年龄
    [self.labAge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImage);
        make.left.equalTo(self.labSex.mas_right).offset(leftPadding);
    }];
    //请求时间
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImage.mas_bottom);
        make.left.equalTo(self.labName);
    }];
    
    //结果
    [self.labResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-17);
    }];
    //按钮
    [self.btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-17);
        make.height.equalTo(self.contentView).multipliedBy(0.5);
        make.width.mas_equalTo(60);
    }];
}

-(void)setGuanModel:(SunGuanInfoModel *)guanModel
{
    _guanModel=guanModel;
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,guanModel.HEADPIC]];
    NSString *placeHead=@"";
    if ([guanModel.Sex isEqualToString:@"男"]) {
        placeHead=@"man";
    }else{
        placeHead=@"woman";
    }
    [self.headImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:placeHead]];
    
    //名称
    self.labName.text=guanModel.UserName;
    self.labAge.text=[NSString stringWithFormat:@"%@岁",guanModel.Age];
    self.labSex.text=guanModel.Sex;
    self.labTime.text=guanModel.CONFIRMTIME;
    if ([guanModel.type isEqualToString:@"1"]||[guanModel.type isEqualToString:@"3"])
    {
        if ([guanModel.STATUS isEqualToString:@"0"]) {
            self.btnOk.hidden=NO;
            self.labResult.hidden=YES;
        }else if ([guanModel.STATUS isEqualToString:@"1"]) {
            self.btnOk.hidden=YES;
            self.labResult.hidden=NO;
            self.labResult.text=@"已同意";
            
        }else if ([guanModel.STATUS isEqualToString:@"2"]){
            self.btnOk.hidden=YES;
            self.labResult.hidden=NO;
            self.labResult.text=@"已拒绝";
        }
    }else
    {
        if ([guanModel.STATUS isEqualToString:@"0"]) {
            self.btnOk.hidden=YES;
            self.labResult.hidden=NO;
            self.labResult.text=@"等待对方处理";
        }else if (![guanModel.STATUS isEqualToString:@"1"]) {
            self.btnOk.hidden=YES;
            self.labResult.hidden=NO;
            self.labResult.text=@"对方已同意";
            
        }else if (![guanModel.STATUS isEqualToString:@"2"]){
            self.btnOk.hidden=YES;
            self.labResult.hidden=NO;
            self.labResult.text=@"对方已拒绝";
        }
    }
    
}

@end
