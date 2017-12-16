//
//  SunFMDBTool.m
//  HealthManager
//
//  Created by 李金星 on 2017/2/21.
//  Copyright © 2017年 马银伟. All rights reserved.
//  缓存工具类

#import "SunFMDBTool.h"
#import "FMDB.h"
#import "AFNetworking.h"
#import "SunLogin.h"
#import "SunAccountTool.h"
@implementation SunFMDBTool

//根据code查找用户名
+(NSDictionary *)nameWithUserCode:(NSString *)code type:(NSString *)type
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    //1.获取路径caches目录
    NSString *path=kPathCache;
     NSString *filePath = [path stringByAppendingPathComponent:@"UserInfo.sqlite"];
    //2.创建并且打开一个数据库
    FMDatabase *db=[FMDatabase databaseWithPath:filePath];
    BOOL isOpen=db.open;
    if (!isOpen) {
        return dict;
    }
    //创建数据库
    NSString *sqlCreateTable=@"create table if not exists t_UserInfo(usercode text,nick text,head text)";
    BOOL create=[db executeUpdate:sqlCreateTable];
    if (!create) {
        return dict;
    }
    //查询数据
    NSString *sqlSelect=[NSString stringWithFormat:@"select nick,usercode,head from t_UserInfo where usercode='%@'",code];
    FMResultSet *set=[db executeQuery:sqlSelect];
    while ([set next]) {
        dict[@"name"] =  [set stringForColumn:@"nick"];
        dict[@"usercode"] =  [set stringForColumn:@"usercode"];
        dict[@"head"] =  [set stringForColumn:@"head"];
    }
    if (dict.count==0) {
        //请求网络
        dict=[self requestNickNameWithCode:code type:type];
        
        if(dict.count==0)
        {
            return dict;
        }
        //缓存起来
        [db executeUpdate:@"insert into t_UserInfo(usercode,nick,head) values (?,?,?)",dict[@"code"],dict[@"nick"],dict[@"head"]];
    }
    return dict;
}


+(NSDictionary *)requestNickNameWithCode:(NSString *)code type:(NSString *)type
{
    SunLogin *login=[SunAccountTool getAccount];
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:MyURL];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str = [NSString stringWithFormat:@"access_token=%@&parma=GetNickName*%@*%@",login.access_token,code,type];//设置参数
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *result = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    NSDictionary *dict=[self dictionaryWithJsonString:result];
    return dict;
}

/*!
 
 * @brief 把格式化的JSON格式的字符串转换成字典
 
 * @param jsonString JSON格式的字符串
 
 * @return 返回字典
 
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        return nil;
        
    }
    
    return dic;
    
}
@end
