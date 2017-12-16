//
//  SunBuyViewController.h
//  HealthManager
//
//  Created by 李金星 on 2017/2/14.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SunPayResultModel;
@interface SunBuyViewController : UIViewController
@property(nonatomic,strong)NSString *SerCode;
@property(nonatomic,strong)SunPayResultModel *payModel;
@end
