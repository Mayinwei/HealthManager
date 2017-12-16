//
//  SunSearchTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/16.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSearchTableViewCell.h"
#import "SunSearchDocModel.h"
#import "UIImageView+WebCache.h"

@interface SunSearchTableViewCell()

@property(nonatomic,strong)UIImageView *headImgView;
@property(nonatomic,strong)UILabel *labName;
@property(nonatomic,strong)UILabel *labShan;
@property(nonatomic,strong)UILabel *labzhi;
@property(nonatomic,strong)UILabel *labAd;
@property(nonatomic,strong)UIImageView *flagView;

@end
@implementation SunSearchTableViewCell


+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"search";
    SunSearchTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //头像
        UIImageView *imgView=[[UIImageView alloc]init];
        self.headImgView=imgView;
        [self.contentView addSubview:imgView];
        //医生标志
        UIImageView *flagView=[[UIImageView alloc]init];
        self.flagView=flagView;
        [self.contentView addSubview:flagView];
        //名字
        UILabel *labName=[[UILabel alloc]init];
        self.labName=labName;
        [self.contentView addSubview:labName];
        
        //擅长
//        UILabel *labShan=[[UILabel alloc]init];
//        self.labShan=labShan;
//        labShan.font=kFont(14);
//        labShan.textColor=[UIColor lightGrayColor];
//        [self.contentView addSubview:labShan];
        
        //职务
        UILabel *labzhi=[[UILabel alloc]init];
        self.labzhi=labzhi;
        labzhi.font=kFont(14);
        labzhi.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:labzhi];
        
        //医院科室
        UILabel *labAd=[[UILabel alloc]init];
        labAd.font=kFont(14);
        labAd.textColor=[UIColor lightGrayColor];
        self.labAd=labAd;
        [self.contentView addSubview:labAd];
        
        self.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat padding=10;
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(padding+4);
        make.top.equalTo(self.contentView).offset(padding-3);
        make.bottom.equalTo(self.contentView).offset(-padding+3);
        make.width.equalTo(self.headImgView.mas_height);
    }];
    
    //姓名
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView);
        make.left.equalTo(self.headImgView.mas_right).offset(padding);
        
    }];
    [self.flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.labName.mas_right).offset(3);
        make.top.equalTo(self.labName);
        make.bottom.equalTo(self.labName);
        make.width.mas_equalTo(37);
    }];
    //职务
    [self.labzhi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.left.equalTo(self.labName);
       // make.right.equalTo(self.contentView);
    }];
    
    //医院
    [self.labAd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImgView);
        make.left.equalTo(self.labName);
        //make.right.equalTo(self.contentView);
    }];
}

-(void)setSearchDoc:(SunSearchDocModel *)searchDoc
{
    _searchDoc=searchDoc;
    //头像
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,searchDoc.HEADPIC]] ;
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
    [self.flagView setImage:[UIImage imageNamed:@"doc_flag"]];
    //星星
    self.labName.text=searchDoc.USERNAME;
    self.labzhi.text=searchDoc.POST;
    if (![searchDoc.HOSNAME isEqualToString:@""]&&![searchDoc.DEPT isEqualToString:@""]) {
        self.labAd.text=[NSString stringWithFormat:@"%@/%@",searchDoc.HOSNAME,searchDoc.DEPT];
    }
    
}
@end
