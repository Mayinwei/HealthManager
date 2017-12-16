//
//  SunNewFeatureViewController.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//  新特性界面

#import "SunNewFeatureViewController.h"
#import "SunLogViewController.h"
//新特性页的宏
#define SunScrollImgNum 4
@interface SunNewFeatureViewController ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIPageControl *pageControll;
@end

@implementation SunNewFeatureViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加一个scrollView
    UIScrollView *scrollView=[[UIScrollView alloc] init];
    scrollView.frame=[UIScreen mainScreen].bounds;
    [self.view addSubview:scrollView];
    scrollView.delegate=self;
    //添加照片
    CGFloat imgW=scrollView.frame.size.width;
    CGFloat imgH=scrollView.frame.size.height;
    
    UIPageControl *page=[[UIPageControl alloc]init];
    self.pageControll=page;
    page.numberOfPages=SunScrollImgNum;
    page.currentPageIndicatorTintColor=MrColor(52, 178, 246);
    page.pageIndicatorTintColor=MrColor(189, 189, 189);
    [self.view addSubview:page];
    CGFloat pageW=100;
    page.frame=CGRectMake((imgW-pageW)/2, imgH-50, pageW, 10);
    //禁止page点击
    page.userInteractionEnabled=NO;
    
    
    for (int i=0; i<SunScrollImgNum; i++) {
        NSString *imgName=[NSString stringWithFormat:@"newFeature_%d",i+1];
        UIImageView *img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imgName]];
        img.frame=CGRectMake(i*imgW, 0, imgW, imgH);
        [scrollView addSubview:img];
        if (i+1==SunScrollImgNum) {
            [self setUpButton:img];
        }
    }
    
    //设置滚动
    scrollView.contentSize=CGSizeMake(SunScrollImgNum*imgW, 0);
    //取消弹簧效果
    scrollView.bounces=NO;
    scrollView.pagingEnabled=YES;
    scrollView.showsHorizontalScrollIndicator=NO;
    
   
}

//在最后一页添加按钮
-(void)setUpButton:(UIImageView *)imgView
{
    //添加交互功能
    imgView.userInteractionEnabled=YES;
    UIButton *startBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"common_btn"] forState:UIControlStateNormal];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"common_btn_hightlight"] forState:UIControlStateHighlighted
     ];
    startBtn.titleLabel.font=[UIFont systemFontOfSize:14];;
    [startBtn setTitle:@"进入善医" forState:UIControlStateNormal];
    [imgView addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(100, 35));
        make.centerX.equalTo(imgView.mas_centerX);
        make.bottom.equalTo(self.pageControll.mas_top).offset(-10);
    }];
    [startBtn addTarget:self action:@selector(btn_insert) forControlEvents:UIControlEventTouchUpInside];
}

-(void)btn_insert
{
    self.view.window.rootViewController=[[SunLogViewController alloc] init];

}

#pragma mark --scrollView的代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //水平滚动距离
    CGFloat offsetX=scrollView.contentOffset.x;
    //计算出页码
    double pageDouble=offsetX/self.view.frame.size.width;
    int pageInt=(int)(pageDouble+0.5);
    self.pageControll.currentPage=pageInt;

}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
