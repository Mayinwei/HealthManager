//
//  SunCutImageView.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/13.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "SunCutImageView.h"

@implementation SunCutImageView



+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset lineColor:(UIColor *)color {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,3);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}
@end
