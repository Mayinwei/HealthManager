//
//  SunDeviceTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/11.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunDeviceTableViewCell.h"
#import "SunDeviceModel.h"

@interface SunDeviceTableViewCell()
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labType;
@property(nonatomic,strong)UILabel *labCode;
@property(nonatomic,strong)UIImageView *imgView2;
@property(nonatomic,strong)UIImageView *imgHeadView;
@end
@implementation SunDeviceTableViewCell

+(instancetype)cellWithTabelView:(UITableView *)tableview
{
    static NSString *ID=@"record";
    SunDeviceTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunDeviceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //标志
        UIImageView *imgHeadView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"responsive"]];        
        [self.contentView addSubview:imgHeadView];
        self.imgHeadView=imgHeadView;
        //名称
        UILabel *labName=[[UILabel alloc]init];
        
        labName.font=kFont(15);
        self.labName=labName;
        [self.contentView addSubview:labName];
        //类型
        UILabel *labType=[[UILabel alloc]init];
        labType.font=labName.font;
        self.labType=labType;
        [self.contentView addSubview:labType];
        //编号
        UILabel *labCode=[[UILabel alloc]init];
        labCode.font=labName.font;
        labCode.textColor=MrColor(180, 180, 180);
        self.labCode=labCode;
        [self.contentView addSubview:labCode];
        //闹钟
        UIImageView *imgView2=[[UIImageView alloc]init];
        imgView2.userInteractionEnabled=YES;
        self.imgView2=imgView2;
        [self.contentView addSubview:imgView2];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    if (SCREEN_WIDTH<=320) {
        [self samilScreen];
    }else{
        [self bigScreen];
    }
    
}

-(void)samilScreen
{
    CGFloat lefPadding=20;
    [self.imgHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.left.equalTo(self.contentView).offset(lefPadding);
        make.width.equalTo(self.imgHeadView.mas_height);
    }];
    
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgHeadView.mas_right).offset(8);
        make.top.equalTo(self.contentView).offset(5);
    }];
    //类型
    [self.labType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgHeadView.mas_right).offset(8);
        make.top.equalTo(self.labName.mas_bottom);
    }];
    //编码
    [self.labCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgHeadView.mas_right).offset(8);
        make.bottom.equalTo(self.contentView).offset(-5);
    }];
    
    //闹钟
    [self.imgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(30);
        make.width.equalTo(self.imgView2.mas_height);
        make.right.equalTo(self).offset(-lefPadding*2);
    }];
}
-(void)bigScreen
{
    CGFloat lefPadding=20;
    [self.imgHeadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.bottom.equalTo(self.contentView).offset(-8);
        make.left.equalTo(self.contentView).offset(lefPadding);
        make.width.equalTo(self.imgHeadView.mas_height);
    }];
    
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgHeadView.mas_right).offset(8);
        make.top.equalTo(self.imgHeadView);
    }];
    //类型
    [self.labType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName.mas_right).offset(8);
        make.centerY.equalTo(self.labName);
    }];
    //编码
    [self.labCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgHeadView.mas_right).offset(8);
        make.bottom.equalTo(self.imgHeadView);
    }];
    
    //闹钟
    [self.imgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.height.mas_equalTo(30);
        make.width.equalTo(self.imgView2.mas_height);
        make.right.equalTo(self).offset(-lefPadding*2.4);
    }];
}

//设置数据
-(void)setDeviceModel:(SunDeviceModel *)deviceModel
{
    _deviceModel=deviceModel;
    
    
    self.labName.text=[NSString stringWithFormat:@"%@",[deviceModel.EQUNAME isEqualToString:@""]?@"无":deviceModel.EQUNAME];
    
    self.labType.text=[NSString stringWithFormat:@"类型:%@",[deviceModel.EQUSUBTYPE isEqualToString:@""]?@"无":deviceModel.EQUSUBTYPE];
    self.labCode.text=[NSString stringWithFormat:@"编号:%@",deviceModel.EQUCODE];
    if([deviceModel.EQUSUBTYPE isEqualToString:@"动态血压计"]){
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        if ([deviceModel.HASPLAN isEqualToString:@"有"]) {
            self.imgView2.image=[UIImage imageNamed:@"myclock"];
            
        }else{
            self.imgView2.image=[UIImage imageNamed:@"myclock-light"];
        }
    }
    

}

@end
