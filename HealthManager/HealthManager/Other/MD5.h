//
//  MD5.h
//  HealthManager
//
//  Created by 李金星 on 2016/12/9.
//  Copyright © 2016年 马银伟. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#define FileHashDefaultChunkSizeForReadingData 1024*8 // 8K
@interface MD5 : NSObject

//计算NSData 的MD5值
+(NSString*)getMD5WithData:(NSData*)data;

//计算字符串的MD5值，
+(NSString*)getmd5WithString:(NSString*)string;

//计算大文件的MD5值
+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
