//
//  SunCutImageView.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/13.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SunCutImageView : NSObject
/**
 *  剪裁图片为圆形
 *
 *  @param image 图片image
 *  @param inset 位置
 *  @param color 边框颜色
 *
 *  @return UIImage
 */
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset lineColor:(UIColor *)color;
@end
