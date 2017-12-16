//
//  SunChatViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/17.
//  Copyright © 2017年 马银伟. All rights reserved.
//  聊天功能

#import "SunChatViewController.h"
#import "EaseUI.h"
#import "EaseSDKHelper.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "EMCDDeviceManager.h"
#import "MBProgressHUD+Add.h"
#import "SunChatTypeInfoModel.h"
#import "EaseSDKHelper.h"
#import "SunFMDBTool.h"
@interface SunChatViewController ()<EaseMessageViewControllerDelegate,EaseMessageViewControllerDataSource,EMCallManagerDelegate>

@property(nonatomic,strong)NSDictionary *myDict;
@property(nonatomic,strong)NSDictionary *otherDict;
@end

@implementation SunChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_background"] forBarMetrics:UIBarMetricsDefault];
    
    self.showRefreshHeader = YES;
    //设置代理和数据源
    self.delegate=self;
    self.dataSource=self;
    
    //获取聊天双方头像和昵称
    SunLogin *login=[SunAccountTool getAccount];
    //设置title
    NSString *otherType=@"";
    if ([login.type isEqualToString:@"个人用户"]) {
        otherType=@"机构用户";
    }else{
        otherType=@"个人用户";
    }
    self.otherDict=[SunFMDBTool nameWithUserCode:self.ChatCode type:otherType];
    self.title=self.otherDict[@"nick"];
    
    self.myDict=[SunFMDBTool nameWithUserCode:login.usercode type:login.type];
}

//录音按钮的回调
-(void)messageViewController:(EaseMessageViewController *)viewController didSelectRecordView:(UIView *)recordView withEvenType:(EaseRecordViewType)type
{
    /*
     EaseRecordViewTypeTouchDown,//录音按钮按下
     EaseRecordViewTypeTouchUpInside,//手指在录音按钮内部时离开
     EaseRecordViewTypeTouchUpOutside,//手指在录音按钮外部时离开
     EaseRecordViewTypeDragInside,//手指移动到录音按钮内部
     EaseRecordViewTypeDragOutside,//手指移动到录音按钮外部
     */
    //根据type类型，用户自定义处理UI的逻辑
    switch (type) {
        case EaseRecordViewTypeTouchDown:
        {
            //开始录音
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView  recordButtonTouchDown];
            }
            //[self startRecordSound];
        }
            break;
        case EaseRecordViewTypeTouchUpInside:
        {
            //完成录音
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            //[self endRecordSound];
            [self.recordView removeFromSuperview];
            
        }
            break;
        case EaseRecordViewTypeTouchUpOutside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
            break;
        case EaseRecordViewTypeDragInside:
        {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragInside];
            }
        }
            break;
        case EaseRecordViewTypeDragOutside:
        {
            //取消发送语音
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonDragOutside];
            }
        }
            break;
    }
    
}

-(void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    
    if (self.deleteConversationIfNull) {
        //判断当前会话是否为空，若符合则删除该会话
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId isDeleteMessages:NO completion:nil];
        }
    }
}

#pragma mark - EMClientDelegate

//账号异常时
- (void)userAccountDidLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userAccountDidRemoveFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)userDidForbidByServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

/*!
 @method
 @brief 是否允许长按
 @discussion 获取是否允许长按的回调，默认是NO
 @param viewController 当前消息视图
 @param indexPath 长按消息对应的indexPath
 @result
 */
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    //样例给出的逻辑是长按cell之后显示menu视图
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
    }
    return YES;
}

/*!
 @method
 @brief 将EMMessage类型转换为符合<IMessageModel>协议的类型
 @discussion 将EMMessage类型转换为符合<IMessageModel>协议的类型,设置用户信息,消息显示用户昵称和头像
 @param viewController 当前消息视图
 @param EMMessage 聊天消息对象类型
 @result 返回<IMessageModel>协议的类型
 */
- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    //用户可以根据自己的用户体系，根据message设置自己昵称和头像
    id<IMessageModel> model = nil;
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];//默认头像
    if(model.isSender){
        
        //发送方
        model.avatarURLPath = [NSString stringWithFormat:@"%@%@",MyHeaderUrl,self.myDict[@"head"]];//头像网络地址
        model.nickname =self.myDict[@"nick"];//用户昵称
    }else{
        
        //发送方
        model.avatarURLPath = [NSString stringWithFormat:@"%@%@",MyHeaderUrl,self.otherDict[@"head"]];//头像网络地址
        model.nickname = self.otherDict[@"nick"];//用户昵称
    }
    return model;
}
@end
