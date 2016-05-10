//
//  MusicPlayer.m
//  RACDemo
//
//  Created by jiachen on 16/3/28.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import "SoundPlayer.h"

@interface SoundPlayer() <AVAudioPlayerDelegate>

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic,strong) AVAudioPlayer *bgPlayer;

@property (nonatomic,strong) NSString *fileName;

@property (nonatomic,strong) AVURLAsset *asset;
@end

static SoundPlayer *soundPlayer;
@implementation SoundPlayer : NSObject

- (void)playWithIsLoops: (BOOL )isLoop{
    //获取声音
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(dispatchQueue, ^{
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"wav"];
    
        _asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
                //准备缓冲池  减少播放的延迟事件
        if (_audioPlayer != nil) {
            _audioPlayer.delegate = self;
            [_audioPlayer prepareToPlay];
            [_audioPlayer setVolume:10];
            //默认只播放一次
            _audioPlayer.numberOfLoops = isLoop ? -1 : 0;
            [_audioPlayer play];
        }else{
            NSLog(@"初始化失败");
        }
    });
}


// 播放背景音乐
- (void)playBackGroundMusic{
    //重新开启一条线程
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(dispatchQueue, ^{
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"wav"];
        
        if (!_bgPlayer) {
            _asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
            _bgPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        }
        if (_bgPlayer != nil) {
            _bgPlayer.delegate = self;
            [_bgPlayer prepareToPlay];
            [_bgPlayer setVolume:15];
            _bgPlayer.numberOfLoops = -1;
            [_bgPlayer play];
        }else{
            NSLog(@"初始化失败");
        }
    });
}
//暂停BGM
- (void)pauseBGMusic{
    [_bgPlayer pause];
}

+ (SoundPlayer *)player{
    @synchronized(self) {
        if (!soundPlayer) {
            soundPlayer = [[SoundPlayer alloc] init];
        }
        return soundPlayer;
    }
}


// - MARK: 外界调用方法
//播放
+ (void)playWithMusicName: (NSString *)fileName{
    SoundPlayer *player = [SoundPlayer player];
    player.fileName = fileName;
    [player playWithIsLoops:false];
}

//后台播放背景音乐播放
+ (void)playBackgroundMusicWithName: (NSString *)fileName {
    SoundPlayer *player = [SoundPlayer player];
    player.fileName = fileName;
    [player playBackGroundMusic];
}

//暂停背景音乐
+ (void)pauseBGM{
    [[SoundPlayer player] pauseBGMusic];
}
@end
