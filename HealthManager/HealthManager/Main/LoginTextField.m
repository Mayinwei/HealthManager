//
//  LoginTextField.m
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/8.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import "LoginTextField.h"

@implementation LoginTextField


+(instancetype)fieldWithText:(NSString *)title image:(NSString *)imageName isPwd:(BOOL) ispwd
{
    UITextField *textField=[[LoginTextField alloc]init];
    if (ispwd) {
        textField.secureTextEntry=YES;
    }
    textField.backgroundColor=[UIColor grayColor];
    
    textField.alpha=0.6;
    
    //键盘类型
    textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    
     
    textField.font=[UIFont systemFontOfSize:14];
    textField.font = [UIFont boldSystemFontOfSize:15.0];
    
    textField.textColor=[UIColor whiteColor];
    
    //清除按钮
    textField.clearButtonMode=UITextFieldViewModeWhileEditing;
    
    
    //设置左侧图片
    textField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName ]];
    textField.leftViewMode = UITextFieldViewModeAlways;
    
//    //设置文字颜色
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:
//                                      @{NSForegroundColorAttributeName:[UIColor whiteColor],
//                                        NSFontAttributeName:textField.font
//                                        }];
    UIColor *color = [UIColor whiteColor];
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:color}];
    //[textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    
    textField.borderStyle=UITextBorderStyleRoundedRect;
    return textField;
}


//重写修改位置
-(CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 15; //像右边偏15
    return iconRect;
}
//重写修改文字文字位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
     return CGRectInset(bounds, 45, 0);
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    
    return CGRectInset(bounds, 45, 0);
    
}

@end
