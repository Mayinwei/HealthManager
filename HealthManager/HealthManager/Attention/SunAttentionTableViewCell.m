//
//  SunAttentionTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/9.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunAttentionTableViewCell.h"
#import "SunAttentionModel.h"

@interface SunAttentionTableViewCell()
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labSex;
@property(nonatomic,strong)UILabel *labAge;
@property(nonatomic,strong)UIImageView *warningImgView;
@end

@implementation SunAttentionTableViewCell

+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"attr";
    SunAttentionTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunAttentionTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //头像
        UIImageView *imgView=[[UIImageView alloc]init];
        self.imgView=imgView;
        [self.contentView addSubview:imgView];
        //名称
        UILabel *labName=[[UILabel alloc]init];
        self.labName=labName;
        labName.font=kFont(20);
        [self.contentView addSubview:labName];
        //性别
        UILabel *labSex=[[UILabel alloc]init];
        self.labSex=labSex;
        labSex.font=kFont(14);
        [self.contentView addSubview:labSex];
        //年龄
        UILabel *labAge=[[UILabel alloc]init];
        self.labAge=labAge;
        labAge.font=kFont(14);
        [self.contentView addSubview:labAge];
        //警告标志
        UIImageView *warningImgView=[[UIImageView alloc]init];
        self.warningImgView=warningImgView;
        [self.contentView addSubview:warningImgView];
        //显示右侧箭头
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    
}

-(void)setAttModel:(SunAttentionModel *)attModel
{
    _attModel=attModel;
    //设置数据
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,attModel.HEADPIC]];
    
    [self.imgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
    self.labName.text=attModel.USERNAME;
    self.labAge.text=[NSString stringWithFormat:@"%@岁",attModel.AGE];
    self.labSex.text=attModel.USEX;
    //设置尺寸
    self.contentView.frame=CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(50);
        make.centerY.equalTo(self.contentView);
        make.width.equalTo(self.imgView.mas_height);
    }];
    
    
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imgView.mas_right).offset(15);
        make.top.equalTo(self.imgView);
        
    }];
    
    [self.labSex mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName);
        make.bottom.equalTo(self.imgView.mas_bottom);
        
    }];
    
    [self.labAge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labSex.mas_right).offset(18);
        make.centerY.equalTo(self.labSex);
        
    }];
    
    [self.warningImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imgView);
        make.size.equalTo(self.imgView);
        make.right.equalTo(self.contentView).offset(-40);
    }];
    
    [self layoutIfNeeded];
    //添加图像圆角
    CGFloat w=self.imgView.frame.size.width;
    //    UIGraphicsBeginImageContextWithOptions(self.imgView.bounds.size, NO, 0);
    //    //贝塞尔曲线
    //    [[UIBezierPath bezierPathWithRoundedRect:self.imgView.bounds cornerRadius:w/2] addClip];
    //    [img drawInRect:self.imgView.bounds];
    //    self.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    
    self.imgView.layer.cornerRadius=w/2;
    self.imgView.layer.masksToBounds=YES;
}

@end
