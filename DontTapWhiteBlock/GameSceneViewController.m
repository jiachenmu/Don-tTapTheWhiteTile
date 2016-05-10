 //
//  GameSceneViewController.m
//  RACDemo
//
//  Created by jiachen on 16/3/29.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import "GameSceneViewController.h"
#import "GameSceneView.h"
#import "GameFailureView.h"
#import "SoundPlayer.h"
#import "ScoreManger.h"

#import "StartAnimView.h"

@interface GameSceneViewController ()

//失败页面
@property (nonatomic,strong) GameFailureView *failureView;

@property (nonatomic,strong) NSMutableArray *operateArray;

@property (nonatomic,strong) NSString *keyEffect;

//可重用数组
@property (nonatomic,strong) NSMutableArray *reuseArray;

//初始每个scene的frame
@property (nonatomic,strong) NSMutableArray *frameArray;

//当前页面需要的scene数量
@property (nonatomic,assign) NSUInteger sceneCount;

//当前正确点击的次数 目的：用来播放对应index的音效
@property (nonatomic,assign) NSInteger clickIndex;
//当前分数
@property (nonatomic,assign) float currentScore;

@end

@implementation GameSceneViewController
{
    CADisplayLink *disPlayLink;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
 
    _currentScore = 0.0;
    NSNumber *num = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:GameSpeed];
    
    _gameSpeed = num == nil ? 2.0 : num.floatValue;

    //读取音效设置
    _keyEffect = [[NSUserDefaults standardUserDefaults] objectForKey:KeyEffectSetting];
    if (_keyEffect == nil) {
        _keyEffect = KnifeEffect;
        [[NSUserDefaults standardUserDefaults] setObject:_keyEffect forKey:KeyEffectSetting];
    }
    
    [self buildMainView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //用 CADisplayLink 进行刷新 频率更快，动画效果不会卡顿
    disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startScroll)];
    
    //先执行 3 2 1 这样的动画
    [[StartAnimView shareInstance] showWithAnimNum:3 CompleteBlock:^{
        
        [disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }];
}

//开始滚动
- (void)startScroll {
    WeakSelf;
    
    [_operateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            GameSceneView *scene = (GameSceneView *)obj;
            CGRect frame = scene.frame;
            frame.origin.y += _gameSpeed * 2.0;
            if (!*stop) {
                scene.frame = frame;
            }

            //  用户点击超时没有点击
            if ( scene.frame.origin.y >= SCREEN_HEIGHT && scene.completeType == CompleteTypeNotClick)
            {
                //停止刷新
                [disPlayLink invalidate];
                *stop = false;
                
                //弹出失败页面
                [weakSelf resetGame];
        
            }else if( scene.frame.origin.y > SCREEN_HEIGHT && scene.completeType == CompleteTypeVictory){
                // 用户点击成功  计算新的frame
                scene.frame = [weakSelf calculateNewFrameWithTag:scene.tag];
                [scene reSet];
            }

        });
    }];
    
}

//点击正确之后 将超出屏幕的scene 改变frame ，让玩家感觉一直有新scene的出来
- (CGRect)calculateNewFrameWithTag: (NSInteger )tag {
    tag = tag == 0 ? _sceneCount - 1 : tag - 1;
    
    GameSceneView *scene = (GameSceneView *)[_operateArray objectAtIndex:tag];
    CGRect frame = scene.frame;
    frame.origin.y -= WhiteBlockHeight;
    return frame;
}
// - MARK:create main view
- (void)buildMainView {
   
    // - 1: 先计算出 屏幕中需要多少个 scene
    _sceneCount = ceil(SCREEN_HEIGHT / WhiteBlockHeight) + 1;
    _operateArray = [[NSMutableArray alloc] initWithCapacity:_sceneCount];
    
    //frame 记录初始化每个scene的frame 点击错误之后可以回复scene的frame
    _frameArray = [[NSMutableArray alloc] initWithCapacity:_sceneCount];
    WeakSelf;
    for (int i = 0; i < _sceneCount; i++) {
        GameSceneView *scene = [[GameSceneView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - WhiteBlockHeight * (i + 1), SCREEN_WIDTH, WhiteBlockHeight)];
        scene.completeType = CompleteTypeNotClick;
        scene.clickBlock = ^(CompleteType type){
            //根据点击结果 播放对应的音效
            [weakSelf playMusicWithType:type];
            
        };
        //这里
        scene.effect = _keyEffect;
        scene.tag = i;
        [_frameArray addObject:[NSValue valueWithCGRect:scene.frame]];
        [_operateArray addObject:scene];
        
        [self.view addSubview:scene];
    }
    
}

// - MARK: 根据点击的状态播放相应的音乐,执行相应的操作
- (void)playMusicWithType:(CompleteType )type {
    _clickIndex++;
    if (type == CompleteTypeVictory) {
        //点击成功  播放相应的 music
        if (_clickIndex > 213) {
            _clickIndex = (NSInteger)_clickIndex % 213;
        }
        NSString *fileName = [NSString stringWithFormat:@"C-%ld",_clickIndex];
        if (_clickIndex <= 9) {
            fileName = [NSString stringWithFormat:@"C-0%ld",_clickIndex];
        }

        [SoundPlayer playWithMusicName:fileName];
        // 更新当前分数
        _currentScore += 1.0;
        // 根据当前分数 计算白块移动速度
        [self updateGameSpeed];
    }else{
        //点击失败
        [disPlayLink invalidate];
        [SoundPlayer playWithMusicName:ErrorEffect];
        //延迟0.5s 先让失败的button 闪一闪  再弹出  failureView
        WeakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf resetGame];
            
        });
    }
}

//根据当前得分 改变游戏速度，让用户感觉越来越快
//游戏速度最高为5.0

/*
    1 .分数 < 200 时  速度匀速变化
 
 */

- (void)updateGameSpeed {
    if (_currentScore < 200) {
        _gameSpeed = 2.5 * (1 + _currentScore / 200 );
    }else {
        _gameSpeed = 5.0;
    }
}


//重新开始游戏
- (void)resetGame {
    //更新失败view 的显示数据
    [self updateFailureView];
    
    //更新最佳分数
    [ScoreManger updateWithCurrentScore:_currentScore];
    
    //将当前分数重置为0
    _currentScore = 0.0;
}

//重新开始游戏  将每个 gameSceneView的frame  变回初始frame
- (void)playAgain {
    WeakSelf;
    [_operateArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GameSceneView *scene = (GameSceneView *)obj;
        scene.frame = ( (NSValue *)[weakSelf.frameArray objectAtIndex:idx] ).CGRectValue;
        [scene reSet];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startScroll)];
        [disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    });
}

//更新失败页面
- (void)updateFailureView {
    WeakSelf;
    //显示失败View
    if (!_failureView) {
        //初始化失败View
        _failureView = [GameFailureView shareInstance];
        _failureView.hidden = true;
        _failureView.closeBlock = ^(){
            NSLog(@"返回首页~");
            [weakSelf dismissViewControllerAnimated:false completion:nil];
        };
        __weak GameFailureView *failure = _failureView;
        _failureView.continueBlock = ^(){
            NSLog(@"点击再来~");
            failure.hidden = true;
            [weakSelf playAgain];
        };
        
        [self.view addSubview:_failureView];
    }
    _failureView.hidden = false;
    NSLog(@"历史最佳： %.1f",[ScoreManger getBestScore]);
    NSLog(@"当前分数： %.1f",_currentScore);
    // 当前分数显示
    _failureView.currentScoreLabel.text = [NSString stringWithFormat:@"%.1f",_currentScore];
    // 历史最佳显示
    _failureView.historyBestLabel.text = [NSString stringWithFormat:@"历史最佳： %.0f",[ScoreManger getBestScore]];
    // 上方提示文字
    _failureView.tipLabel.text = _currentScore == [ScoreManger getBestScore] ? @"单身二十年的手速哦~" : @"再接再厉咯😄";

}
@end
