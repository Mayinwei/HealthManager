//
//  SunHomeViewController.h
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <UIKit/UIKit.h>

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";


@interface SunHomeViewController : UIViewController
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
//问一问lable
@property(nonatomic,weak)UIImageView *imgWen;

@end
