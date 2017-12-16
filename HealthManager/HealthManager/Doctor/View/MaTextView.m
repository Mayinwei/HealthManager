//
//  MaTextView.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/27.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "MaTextView.h"

@interface MaTextView()

@property(nonatomic,weak)UILabel *placeHolderLab;
@end
@implementation MaTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *lab=[[UILabel alloc]init];
        self.placeHolderLab=lab;
        lab.text=@"给患者一些专业性建议...";
        lab.numberOfLines=0;
        lab.font=kFont(15);
        lab.textColor=[UIColor lightGrayColor];
        [self addSubview:self.placeHolderLab];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self]; //通知:监听文字的改变
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textDidChange
{
    self.placeHolderLab.hidden=self.hasText;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
   
   CGRect labRect= [self.placeHolderLab.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH,MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.placeHolderLab.font} context:nil];
    
    self.placeHolderLab.frame=CGRectMake(5, 8, SCREEN_WIDTH-10, labRect.size.height);
}

-(void)setPlaceHolderSer:(NSString *)placeHolderSer
{
    _placeHolderSer=placeHolderSer;
    self.placeHolderLab.text=placeHolderSer;
    //刷新界面
    [self setNeedsLayout];
}


-(void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor=placeHolderColor;
    self.placeHolderLab.textColor=placeHolderColor;
}
@end
