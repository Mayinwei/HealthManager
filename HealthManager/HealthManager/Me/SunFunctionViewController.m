//
//  SunFunctionViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/22.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunFunctionViewController.h"

@interface SunFunctionViewController ()

@end

@implementation SunFunctionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"功能介绍";
    self.view.backgroundColor=[UIColor whiteColor];
    UIScrollView *contentView=[[UIScrollView alloc]init];
    contentView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:contentView];
    
    
    UILabel *labelText=[[UILabel alloc]init];
    labelText.numberOfLines=0;
    CGFloat leftPadding=8;
    labelText.font=kFont(14);
    labelText.text=@" 医疗数据共享解决方案\n善医科技建立了一套统一的、严格的数据交换标准，规范了数据格式 ，帮助用户尽可能采用规定的数据标准。从而了解决数据孤岛遍布、通用行业标准和沟通平台缺乏的问题；善医将通过整合和连接各方供需，促进医疗健康产业间的交流，探索数据合作的新模式。 \n  善医医疗数据共享解决方案是建立信息资源物理分散、逻辑集中的信息共享模式，提供一定范围内跨部门、跨地区的普遍信息共享，方便用户发现、定位和共享多种形态的信息资源，支持政府的经济调节、市场监管、社会管理和公共服务，支持政府、医院、企业、个人用户等等之间按需信息交换与共享，支持不同异构应用系统间信息交换与共享，实现信息资源的高可靠性、可用性，实现了应用系统之间的无缝共享和信息交换。\n  目前我们与中国高血压联盟、中国医学科学院生物医学工程研究所、中国老年保险协会与长寿专业委员会、正安（北京）医疗设备有限公司开展了紧密且富有成效的合作。\n  动态血压解决方案\n24小时动态血压：使用动态血压监测仪器测定一个人昼夜24小时内，每间隔一定时间内的血压值称为动态血压。\n  24小时动态血压作用：早期高血压病的诊断；协助鉴别原发性、继发性和复杂高血压；指导合理用药，更好地预防心脑血管并发症的发生，预测高血压的并发症和死亡的发生和发展。\n选择善医的五大优势：\n  1.设备多元化：根据用户需求可接入指定设备\n  2.操作简易化：一键设置测量方案，简单快捷\n  3.监测报告化：测量结束后自动生成监测报告\n  4.数据可视化：以图表等形式展现，有助于医生快速诊断\n  5.团队专业化：专业的技术及售后团队，为您的使用提供全方位的保障";
    
    CGSize titleSize = [labelText.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-leftPadding*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
 
    [contentView addSubview:labelText];
    //contentView.bounces=NO;
    contentView.contentSize=CGSizeMake(SCREEN_WIDTH,800);
    labelText.frame=CGRectMake(leftPadding, leftPadding, SCREEN_WIDTH-leftPadding*2, titleSize.height);
//    [labelText mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(contentView).offset(leftPadding);
//        make.right.equalTo(contentView).offset(-leftPadding);
//        make.top.equalTo(contentView).offset(leftPadding);
//    }];
}

@end
