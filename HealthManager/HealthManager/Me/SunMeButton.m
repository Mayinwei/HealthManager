//
//  SunMeButton.m
//  HealthManager
//
//  Created by 李金星 on 2017/1/13.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunMeButton.h"

#define LableHeight 15
@implementation SunMeButton



//重写文字位置
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, contentRect.size.height-LableHeight, contentRect.size.width, LableHeight);
}

//重写图片位置
-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat w=contentRect.size.width/1.5;
    CGFloat x=contentRect.size.width-w;
    return CGRectMake(x/1.5, 0, w, contentRect.size.height-LableHeight-8);
}

@end
