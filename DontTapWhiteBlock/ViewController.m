//
//  ViewController.m
//  RACDemo
//
//  Created by jiachen on 16/3/7.
//  Copyright © 2016年 jiachen. All rights reserved.
//



#import "ViewController.h"
#import "SoundPlayer.h"
#import "GameSceneViewController.h"
#import "SettingViewController.h"

@interface ViewController ()

//开始游戏
@property (nonatomic,strong) UIButton *startButton;

//关于作者
@property (nonatomic,strong) UIButton *aboutMeButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self selectLevel];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [SoundPlayer playBackgroundMusicWithName:BackGroundMusic];
    [self buttonShowAnimation];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SoundPlayer pauseBGM];
}
//按钮创建
- (void)selectLevel {
    
    //开始游戏按钮
    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT)];
    _startButton.backgroundColor = [UIColor blackColor];
    [_startButton setTitle:@"开始游戏" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    WeakSelf;
    [[_startButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakSelf buttonHideAnimation];
        [weakSelf  presentViewController:[[GameSceneViewController alloc] init] animated:false completion:^{
            //弹出游戏窗体后 暂停BGM
            [SoundPlayer pauseBGM];
        }];
        NSLog(@" start game :)");
    }];
    [self.view addSubview:_startButton];
    
    //关于作者、设置
    _aboutMeButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, SCREEN_HEIGHT)];
    _aboutMeButton.backgroundColor = [UIColor whiteColor];
    [_aboutMeButton setTitle:@"设置" forState:UIControlStateNormal];
    [_aboutMeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [[_aboutMeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [weakSelf buttonHideAnimation];
        [weakSelf  presentViewController:[[SettingViewController alloc] init] animated:false completion:^{
            //弹出游戏窗体后 暂停BGM
            [SoundPlayer pauseBGM];
        }];
        
    }];
    [self.view addSubview:_aboutMeButton];
}


// - MARK: button close / show animation
- (void)buttonHideAnimation{
    WeakSelf;
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.startButton.center = CGPointMake(- SCREEN_WIDTH/4, weakSelf.startButton.center.y);
        weakSelf.aboutMeButton.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }];
}

- (void)buttonShowAnimation{
    WeakSelf;
    [UIView animateWithDuration:0.4 animations:^{
        weakSelf.startButton.center = CGPointMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/2);
        weakSelf.aboutMeButton.center = CGPointMake(SCREEN_WIDTH/4 * 3, SCREEN_HEIGHT/2);
    }];
}

@end