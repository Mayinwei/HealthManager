//
//  LoginTextField.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/8.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTextField : UITextField
+(instancetype)fieldWithText:(NSString *)title image:(NSString *)imageName isPwd:(BOOL) ispwd;
@end
