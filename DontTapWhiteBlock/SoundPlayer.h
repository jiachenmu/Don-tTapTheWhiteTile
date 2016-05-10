//
//  MusicPlayer.h
//  RACDemo
//
//  Created by jiachen on 16/3/28.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundPlayer : NSObject 

//按钮点击时播放的声音
+ (void)playWithMusicName: (NSString *)fileName;

//播放背景音乐
+ (void)playBackgroundMusicWithName: (NSString *)fileName;

//暂停背景音乐
+ (void)pauseBGM;
@end
