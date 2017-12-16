//
//  SunPatientTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/24.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunPatientTableViewCell.h"
#import "SunPatientModel.h"
#import "UIImageView+WebCache.h"
@interface SunPatientTableViewCell()
@property(nonatomic,weak)UIImageView *headImgView;
@property(nonatomic,weak)UILabel *labName;
@property(nonatomic,weak)UILabel *labDe;
@property(nonatomic,weak)UILabel *labWarning;

//新消息标志
@property(nonatomic,weak)UIImageView *newsImgView;
@end
@implementation SunPatientTableViewCell

+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"patient";
    SunPatientTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunPatientTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
        labName.font=kFont(16);
        self.labName=labName;
        [self.contentView addSubview:labName];
        //年龄，性别
        UILabel *labDe=[[UILabel alloc]init];
        labDe.font=labName.font;
        self.labDe=labDe;
        [self.contentView addSubview:labDe];
        
        //添加报警提示
        UILabel *labWarning=[[UILabel alloc]init];
        labWarning.font=labName.font;
        labWarning.textColor=MrColor(246, 61, 28);
        self.labWarning=labWarning;
        labWarning.text=@"有告警";
        [self.contentView addSubview:labWarning];
        
        //添加按钮
        UIButton *btnData=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnData setBackgroundImage:[UIImage imageNamed:@"serdetail_icon"] forState:UIControlStateNormal];
        self.btnData=btnData;
        [btnData addTarget:self action:@selector(sugData:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btnData];
        
        //新消息标志
        UIImageView *newsImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mynews_icon"]];
        self.newsImgView=newsImgView;
        [self.contentView addSubview:newsImgView];
        
    }
    return self;
    
}

-(void)sugData:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tableVie:WithDetail:)]) {
        [self.delegate tableVie:self WithDetail:sender];
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat padding=5;
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(padding);
        make.left.equalTo(self.contentView).offset(18);
        make.width.equalTo(self.headImgView.mas_height);
        make.bottom.equalTo(self.contentView).offset(-padding);
    }];
    
    //名称
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView);
        make.left.equalTo(self.headImgView.mas_right).offset(13);
    }];
    
    [self.labDe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView);
        make.left.equalTo(self.labName.mas_right).offset(10);
    }];
    
    [self.labWarning mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImgView);
        make.left.equalTo(self.labName);
    }];
    
    [self.btnData mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    //新消息
    [self.newsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.btnData.mas_left).offset(-30);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self layoutIfNeeded];
    CGFloat w=self.headImgView.frame.size.width;
    self.headImgView.layer.cornerRadius=w/2;
    self.headImgView.layer.masksToBounds=YES;
}

-(void)setPatientModel:(SunPatientModel *)patientModel
{
    _patientModel=patientModel;
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,patientModel.UserHead]];
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"man"]];
    //姓名
    self.labName.text=patientModel.USERNAME;
    self.labDe.text=[NSString stringWithFormat:@"%@  %@岁",patientModel.UserSex,patientModel.UserAge];

    self.labWarning.hidden=![patientModel.IsWarn isEqualToString:@"是"];
    
    if([self setupUnreadMessageCountWithCode:patientModel.PtsCode]>0)
    {
        [self.newsImgView setHidden:NO];
    }else{
        [self.newsImgView setHidden:YES];
    }
}

// 统计未读消息数
-(NSInteger)setupUnreadMessageCountWithCode:(NSString *)code
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        if ([conversation.conversationId isEqualToString:code]) {
            unreadCount += conversation.unreadMessagesCount;
        }
    }
    return unreadCount;
}




@end
