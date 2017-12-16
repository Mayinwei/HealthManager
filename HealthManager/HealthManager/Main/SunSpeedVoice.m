//
//  SunSpeedVoice.m
//  HealthManager
//
//  Created by Mr_yinwei on 17/1/3.
//  Copyright © 2017年 马银伟. All rights reserved.
//  播放声音

#import "SunSpeedVoice.h"
#import <AVFoundation/AVFoundation.h>
@implementation SunSpeedVoice
//播放语音
+(void)speedVoice:(NSString *)str
{
    AVSpeechSynthesizer *speech=[[AVSpeechSynthesizer alloc]init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:str];//需要转换的文字
    utterance.rate=0.4;
    utterance.pitchMultiplier= 1.1;  //设置语调
    AVSpeechSynthesisVoice *voice=[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice=voice;
    [speech speakUtterance:utterance];
}
@end
