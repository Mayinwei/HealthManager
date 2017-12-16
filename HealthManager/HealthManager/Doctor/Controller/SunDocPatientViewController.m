//
//  SunDocPatientViewController.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/23.
//  Copyright © 2017年 马银伟. All rights reserved.
//

#import "SunDocPatientViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "SunAccountTool.h"
#import "SunLogin.h"
#import "MJRefresh.h"
#import "UITableView+EmptyData.h"
#import "SunPatientModel.h"
#import "MJExtension.h"
#import "SunPatientTableViewCell.h"
#import "YBPopupMenu.h"
#import "SunDataViewController.h"
#import "SunChatViewController.h"
#import "SunSuggestViewController.h"
#import "SunNavigationController.h"
#import <UserNotifications/UserNotifications.h>

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";
@interface SunDocPatientViewController ()<UITableViewDelegate,UITableViewDataSource,SunPatientTableViewCellDelegate,YBPopupMenuDelegate,EMClientDelegate,EMChatManagerDelegate>
//搜索类型
@property(nonatomic,copy)NSString *SearchTpe;

@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)MJRefreshNormalHeader *header;
@property(nonatomic,strong)NSMutableArray *arrayData;
@property(nonatomic,weak)UIImageView *showImgView;

@property(nonatomic,assign)NSInteger index;

//最后一个播放声音时间
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation SunDocPatientViewController


-(NSMutableArray *)arrayData
{
    if (_arrayData==nil) {
        _arrayData=[NSMutableArray array];
    }
    return _arrayData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"患者";
    self.view.backgroundColor=[UIColor whiteColor];
    
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-49)];
    tableView.delegate=self;
    tableView.dataSource=self;
    [self.view addSubview:tableView];
    self.tableView=tableView;
    //添加刷新表头
    MJRefreshNormalHeader *header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.header=header;
    self.tableView.mj_header=header;
    //去掉多余分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

// 统计未读消息数
-(NSInteger)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    return unreadCount;
}
-(void)refreshData
{
    [self loadData];
    [self.header endRefreshing];
};

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewDidAppear:animated];
    
    NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
    self.SearchTpe= [userDefault objectForKey:@"SearchType"];
    
    //显示数据
    [self loadData];
    
    //获取聊天记录未读数
    NSInteger unRead=[self setupUnreadMessageCount];
    
    if(unRead>0){
        self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%ld",(long)unRead];
    }else{
        self.tabBarItem.badgeValue=nil;
        
    }
}

-(void)loadData
{
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    //获取账户信息
    SunLogin *login=[SunAccountTool getAccount];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    dic[@"access_token"]=login.access_token;
    dic[@"parma"]=[NSString stringWithFormat:@"GetUserMsg*%@*%@*",login.usercode,self.SearchTpe];
    
    [manager POST:MyURL parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
        //判断是否有错误
        SunErrorModel *errorModel=[SunErrorModel sunErroWithArray:json];
        if (errorModel.error!=nil) {
            [SVProgressHUD showErrorWithStatus:errorModel.msg];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
            [SVProgressHUD dismissWithDelay:2.0];
            return;
        }
        
        self.arrayData=[SunPatientModel mj_objectArrayWithKeyValuesArray:json];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"加载数据失败"];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
        [SVProgressHUD dismissWithDelay:2.0];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView tableViewDisplayWitMsg:@"暂无数据" ifNecessaryForRowCount:self.arrayData.count];
    return self.arrayData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SunPatientTableViewCell *cell=[SunPatientTableViewCell cellWithTableView:tableView];
    cell.delegate=self;
    cell.btnData.tag=indexPath.row;
    cell.patientModel=self.arrayData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark --显示按钮协议方法
-(void)tableVie:(SunPatientTableViewCell *)cell WithDetail:(UIButton *)sender
{
    SunPatientTableViewCell *patCell=cell;
    [YBPopupMenu showRelyOnView:patCell.btnData titles:@[@"专家建议",@"查看消息",@"查看数据"]  icons:@[@"suggest_icon",@"news_icon",@"data_icon"]  menuWidth:140 delegate:self];
    self.index=sender.tag;
}

#pragma mark -三方协议
-(void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    //查看数据
    SunPatientModel *pat=self.arrayData[self.index];
    if (index==0) {
        //专家建议
        SunSuggestViewController *sg=[[SunSuggestViewController alloc]init];
        sg.title=pat.USERNAME;
        sg.PtsCode=pat.PtsCode;
        SunNavigationController *nav=[[SunNavigationController alloc] initWithRootViewController:sg];        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }else if(index==1){
        //查看消息
        SunChatViewController *chat=[[SunChatViewController alloc]initWithConversationChatter:pat.PtsCode conversationType:EMConversationTypeChat];
        chat.ChatCode=pat.PtsCode;
        [self.navigationController pushViewController:chat animated:YES];
    }else if(index==2){
        SunDataViewController *dataView=[[SunDataViewController alloc]init];
        dataView.otherUserCode=pat.PtsCode;
        dataView.otherUserName=pat.USERNAME;
        [self.navigationController pushViewController:dataView animated:YES];
        
    }
}



#pragma mark --环信接收消息
- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getGroupsWithoutPushNotification:nil];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

#pragma  mark --环信接收消息代理
-(void)didReceiveMessages:(NSArray *)aMessages
{
    BOOL isRefreshCons = YES;
    for(EMMessage *message in aMessages){
        BOOL needShowNotification = (message.chatType != EMChatTypeChat) ? [self _needShowNotification:message.conversationId] : YES;
        //修改bagValue
        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
        NSInteger unreadCount = 0;
        for (EMConversation *conversation in conversations) {
            unreadCount += conversation.unreadMessagesCount;
        }
        //获取现在bv
        NSInteger oldNum=[self.tabBarItem.badgeValue integerValue];
        unreadCount +=oldNum;
        if(unreadCount>0){
            self.tabBarItem.badgeValue=[NSString stringWithFormat:@"%ld",(long)unreadCount];
            
        }else{
            self.tabBarItem.badgeValue=nil;
            
        }
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
            switch (state) {
                case UIApplicationStateActive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateInactive:
                    [self playSoundAndVibration];
                    break;
                case UIApplicationStateBackground:
                    [self showNotificationWithMessage:message];
                    break;
                default:
                    break;
            }
#endif
        }
    }//end for
    
}
- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        //NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    NSString *alertBody = nil;
    if (options.displayStyle == EMPushDisplayStyleSimpleBanner) {
        //设置bagevalue值
        int badgeNumber= (int)[[UIApplication sharedApplication] applicationIconBadgeNumber];
        badgeNumber+=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    else{
        return ;
    }
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    
    //发送本地推送
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body =alertBody;
        content.userInfo = userInfo;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = alertBody;
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        notification.userInfo = userInfo;
        
        //发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
