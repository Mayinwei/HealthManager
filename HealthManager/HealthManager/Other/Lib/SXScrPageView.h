//
//  SXScrPageView.h
//  SXscrollerPageView
//
//  Created by ShaoPro on 15/12/21.
//  Copyright © 2015年 ShaoPro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

#define BasicBackGroundColor  [UIColor colorWithRed:102/255.0 green:51/255.0 blue:0/255.0 alpha:1]
#define ColorWithRGB(r,g,b,p)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:p]


#define ScreenHeight    [UIScreen mainScreen].bounds.size.height
#define ScreenWidth     [UIScreen mainScreen].bounds.size.width

typedef void(^imageClickBlock)(NSInteger index);
/**
 *  轮播广告：
 */
@interface SXScrPageView : UIView


/**
 *  轮播的ScrollView
 */
@property(strong,nonatomic) UIScrollView * direct;
/**
 *  轮播的页码
 */
@property(strong,nonatomic) UIPageControl *pageVC;
/**
 *  轮播的时间
 */
@property(assign,nonatomic) CGFloat time;

/**
 *      代码的精进，并非是一朝一夕，首先在写代码时，我们要明确一个原则,如何才能让代码更优雅,
        态度决定高度！
        所以，更多的时候,往往都是羡慕别人写的代码清洁又优雅，那为什么不知道去尝试让自己的代码也
        变得整洁。。。
 
        1.一个功能模块，公共组件，要有极高的可移植性，和简便易用性质。
        就拿随处可见的轮播广告来说，在使用时，我们希望的是一行代码就能做到集成和使用。
 
 
        那么，该如何进行实现呢，首先，一个" @interface SXScrPageView : UIView "类，作为
        我们实现轮播广告的类。 在下面的方法，写上一个初始方法，很清晰明了，在使用时只需要传来相
        对应的参数就行了。。
 */

/**
 *  初始化图片轮播图方法
 *
 *  @param frame          坐标
 *  @param imageNameArray 图片数组
 *  @param clickBlock     点击事件的Block回调
 *
 *  @return 当前对象
 */
+(instancetype)direcWithtFrame:(CGRect)frame
                      ImageArr:(NSArray *)imageNameArray
            AndImageClickBlock:(imageClickBlock)clickBlock;



//开始定时器
-(void)beginTimer;

//销毁定时器
-(void)stopTimer;


@end
