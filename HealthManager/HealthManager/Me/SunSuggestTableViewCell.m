//
//  SunSuggestTableViewCell.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunSuggestTableViewCell.h"
#import "SunSuggestModel.h"
#import "UIImageView+WebCache.h"
#import "SunCutImageView.h"

@interface SunSuggestTableViewCell()
@property(nonatomic,strong)UIImageView *headImgView;
@property(nonatomic,strong) UILabel *labName;
@property(nonatomic,strong)UILabel *labTime;
@property(nonatomic,strong)UILabel *labCont;
@end

@implementation SunSuggestTableViewCell

+(instancetype)cellWithTabelView:(UITableView *)tableview
{
    static NSString *ID=@"suggest";
    SunSuggestTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunSuggestTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //头像
        UIImageView *headImgView=[[UIImageView alloc]init];
        
        self.headImgView=headImgView;
        [self.contentView addSubview:headImgView];
        //名称
        UILabel *labName=[[UILabel alloc]init];
        self.labName=labName;
        labName.font=kFont(14);
        [self.contentView addSubview:labName];
        //时间
        UILabel *labTime=[[UILabel alloc]init];
        labTime.textColor=[UIColor lightGrayColor];
        self.labTime=labTime;
        labTime.font=kFont(12);
        [self.contentView addSubview:labTime];
        //内容
        UILabel *labCont=[[UILabel alloc]init];
        //labCont.lineBreakMode = UILineBreakModeWordWrap;
        //换行
        labCont.numberOfLines=0;
        self.labCont=labCont;
        labCont.font=kFont(14);
        [self.contentView addSubview:labCont];
        
        
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat leftPadding=15;
    //头像
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(leftPadding);
        make.height.mas_equalTo(35);
        make.width.equalTo(self.headImgView.mas_height);
    }];
    //名称
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView);
        make.left.equalTo(self.headImgView.mas_right).offset(12);
        make.height.equalTo(self.headImgView).multipliedBy(0.5);
    }];
    //时间
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labName.mas_bottom);
        make.left.equalTo(self.labName);
        make.height.equalTo(self.labName);
    }];
    //内容
    [self.labCont mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView.mas_bottom).offset(8);
        make.left.equalTo(self.headImgView);
        make.right.equalTo(self.contentView).offset(-leftPadding);
        //最大高度
        
        //make.width.lessThanOrEqualTo(@(SCREEN_WIDTH-leftPadding*2));
    }];
    
}
//计算高度
- (float)getAutoCellHeight {

    [self layoutIfNeeded];
    
     CGSize titleSize = [self.labCont.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    return  titleSize.height+self.labCont.frame.origin.y+ 8;

}

-(void)setSuggest:(SunSuggestModel *)suggest
{
    
    _suggest=suggest;
    
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,suggest.HEADPIC]];
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
    //self.headImgView.image=[SunCutImageView circleImage:self.imageView.image withParam:0 lineColor:nil];
    
    //名称
    self.labName.text=suggest.DOCNAME;
    //时间
    self.labTime.text=suggest.QDATE;
    //内容
    self.labCont.text=suggest.SGTCONTENT;
    
//    self.labCont.text=@"fdsafdsafdsafdsafdsafdsafdsa";
}
@end
