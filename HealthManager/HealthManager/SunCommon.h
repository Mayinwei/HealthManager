//
//  SunCommon.h
//  HealthManager
//
//  Created by Mr_yinwei on 16/12/6.
//  Copyright © 2016年 马银伟. All rights reserved.
//

//自定义Log
//#ifdef DEBUG
//#define MrLog(...)
//#else
//#define MrLog(...)
//#endif

////ios10 真机日志打印
//#ifdef DEBUG
//#define MaLog(format, ...) printf("[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
//#else
//#define MaLog(format, ...)
//#endif




/**
 *  获得RGB颜色
 */
#define MrColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0];
#define MainColor [UIColor colorWithRed:39/255.0 green:228/255.0 blue:246/255.0 alpha:1.0];
/**
 *  请求服务器IP
 */
//#define MyURL @("http://192.168.88.1:8090/Entrance.aspx")
#define MyURL @("http://182.92.73.203:8088/Entrance.aspx")
/**
 *  头像请求地址
*/
#define MyHeaderUrl @("http://www.zgyk365.com/")
//环信登录注册的密码
#define HuanPwd @("123");
