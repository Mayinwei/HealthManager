//
//  SunMyServiceTableViewCell.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMyServiceTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "SunMyServerModel.h"
#import "WZLBadgeImport.h"
@interface SunMyServiceTableViewCell ()
@property(nonatomic,weak)UIImageView *headImgView;
@property(nonatomic,weak)UILabel *labName;
@property(nonatomic,weak)UILabel *labSerName;
@property(nonatomic,weak)UILabel *labTime;
@property(nonatomic,weak)UIImageView *newsImgView;

@end
@implementation SunMyServiceTableViewCell

+(instancetype)cellWithTableView:(UITableView*)tableview
{
    static NSString *ID=@"server";
    SunMyServiceTableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[SunMyServiceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
        //名字
        UILabel *labName=[[UILabel alloc]init];
        self.labName=labName;
        [self.contentView addSubview:labName];
        
        //服务名称
        UILabel *labSerName=[[UILabel alloc]init];
        self.labSerName=labSerName;
        labSerName.font=kFont(14);
        labSerName.textColor=[UIColor lightGrayColor];
        [self.contentView addSubview:labSerName];
        //到期时间
        UILabel *labTime=[[UILabel alloc]init];
        labTime.font=kFont(14);
        labTime.textColor=[UIColor lightGrayColor];
        self.labTime=labTime;
        [self.contentView addSubview:labTime];
        
                
                //新消息标志
                UIImageView *newsImgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mynews_icon"]];
                self.newsImgView=newsImgView;
                [self.contentView addSubview:newsImgView];
        
                
                //右侧加号
                UIButton *btnData=[UIButton buttonWithType:UIButtonTypeCustom];
                [btnData setBackgroundImage:[UIImage imageNamed:@"serdetail_icon"] forState:UIControlStateNormal];
                self.btnData=btnData;
                [btnData addTarget:self action:@selector(sugData:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:btnData];
                
    }
    return self;
}

-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGFloat leftPadding=12;
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8);
        make.left.equalTo(self.contentView).offset(15);
        make.bottom.equalTo(self.contentView).offset(-8);
        //make.size.mas_equalTo(CGSizeMake(50, 66));
        make.width.equalTo(self.headImgView.mas_height);
    }];
    //医生名称
    [self.labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headImgView);
        make.left.equalTo(self.headImgView.mas_right).offset(leftPadding);
    }];
    //服务名称
    [self.labSerName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImgView);
        make.left.equalTo(self.labName);
    }];
    //时间
    [self.labTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headImgView.mas_bottom);
        make.left.equalTo(self.labName);
    }];
    
    //加号
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
}

//加号
-(void)sugData:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tableViewCell:WithDetail:)]) {
        [self.delegate tableViewCell:self WithDetail:sender];
    }
}

-(void)setServermodel:(SunMyServerModel *)servermodel
{
    _servermodel=servermodel;
    
    //头像
    NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",MyHeaderUrl,servermodel.SVRPIC]] ;
    [self.headImgView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"default_img"]];
    //医生
    self.labName.text=servermodel.DOCNAME;
    self.labSerName.text=servermodel.SVRNAME;
    //时间
    self.labTime.text=[NSString stringWithFormat:@"期限:%@-%@",[servermodel.SPBDATE componentsSeparatedByString:@" "][0],[servermodel.SPEDATE componentsSeparatedByString:@" "][0]];
    
    if([self setupUnreadMessageCountWithCode:servermodel.DOCCODE]>0)
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
