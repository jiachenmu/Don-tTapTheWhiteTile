//
//  GameSceneView.m
//  RACDemo
//
//  Created by jiachen on 16/3/29.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import "GameSceneView.h"
#import "SoundPlayer.h"

@interface GameSceneView ()

@property (nonatomic,strong) UIButton *button_1;
@property (nonatomic,strong) UIButton *button_2;
@property (nonatomic,strong) UIButton *button_3;
@property (nonatomic,strong) UIButton *button_4;

//是否已经有按钮选中
@property (nonatomic,assign) BOOL isHasOtherSelected;


//点击是否目标button
@property (nonatomic,assign) BOOL isComplete;
@end

@implementation GameSceneView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildButton];
        [self setupButtonSelected];
    }
    return self;
}

//构建四个button
- (void)buildButton{
    CGFloat width = SCREEN_WIDTH / 4;
    CGFloat height = WhiteBlockHeight;
    
    _button_1 = [self quickCreateButtonWithFrame:CGRectMake(0, 0, width, height)];
    _button_1.tag = 1;
    [self addSubview:_button_1];
    
    _button_2 = [self quickCreateButtonWithFrame:CGRectMake(width, 0, width, height)];
    _button_2.tag = 2;
    [self addSubview:_button_2];
    
    _button_3 = [self quickCreateButtonWithFrame:CGRectMake(width * 2, 0, width, height)];
    _button_3.tag = 3;
    [self addSubview:_button_3];
    
    _button_4 = [self quickCreateButtonWithFrame:CGRectMake(width * 3, 0, width, height)];
    _button_4.tag = 4;
    [self addSubview:_button_4];
}

//概率 决定哪个button 是目标button
- (void)setupButtonSelected{
    //scene 默认状态为 未点击状态
    _completeType = CompleteTypeNotClick;
    
    UIButton *sender;
    int a = arc4random() % 100;
    if (a <= 25) {
        _goalIndex = 1;
        sender = _button_1;
    }else if ( a > 25 && a <= 50)
    {
        _goalIndex = 2;
        sender = _button_2;
    }else if ( a > 50 && a <= 75){
        _goalIndex = 3;
        sender = _button_3;
    }else{
        _goalIndex = 4;
        sender = _button_4;
    }
    
    sender.backgroundColor = [UIColor blackColor];
//    sender.selected = true;
}

//游戏失败 或者 继续游戏 进入重置状态
- (void)reSet{

    _isHasOtherSelected = false;
    
//    [_button_1 setSelected:false];
//    [_button_2 setSelected:false];
//    [_button_3 setSelected:false];
//    [_button_4 setSelected:false];

    _button_1.backgroundColor = [UIColor whiteColor];

    _button_2.backgroundColor = [UIColor whiteColor];

    _button_3.backgroundColor = [UIColor whiteColor];

    _button_4.backgroundColor = [UIColor whiteColor];
    _goalIndex = 0;
    [self setupButtonSelected];
}


// - MARK: private method
//快速构建button
- (UIButton *)quickCreateButtonWithFrame:(CGRect)frame{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    btn.selected = false;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 0.5;
    btn.backgroundColor = [UIColor whiteColor];
    // Tips: 底下的  rac_signalForControlEvents类似于 染色池  map 类似于刀闸。控制流出来是什么东西   而subcribeNext即为得到东西你要执行的操作
    WeakSelf;
    [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside]
      map:^id(id value) {
          if(!weakSelf.isHasOtherSelected && weakSelf.goalIndex == btn.tag){
              // 没人点击 and 点击按钮为目标按钮 -> click正确
              btn.selected = false;
              weakSelf.isHasOtherSelected = true;
              weakSelf.completeType = CompleteTypeVictory;
//              [SoundPlayer playWithMusicName:_effect];
              weakSelf.clickBlock(CompleteTypeVictory);
              return [UIColor whiteColor];
          }else if(!weakSelf.isHasOtherSelected && weakSelf.goalIndex != btn.tag) {
              //点击btn 不是 目标 -> click错误
              weakSelf.completeType = CompleteTypeFailure;
              weakSelf.isHasOtherSelected = true;
//              [SoundPlayer playWithMusicName:ErrorEffect];
              //点击错误之后 将失败的btn 闪烁下
              [weakSelf clickButtonFailureWithButton:btn];
              return [UIColor orangeColor];
          }
          return [UIColor whiteColor];
          
    } ]subscribeNext:^(UIColor *color) {
        btn.backgroundColor = color;
    }];
    
    return btn;
}

//点击button的音效
//- (void)setEffect:(NSString *)effect{
//    _effect = effect;
//    if (_effect == nil) {
//    }
//}

//点击错误 让点错的button 闪烁
- (void)clickButtonFailureWithButton:(UIButton *)sender{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];//必须写opacity才行。
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = 0.2;
    animation.repeatCount = 4;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];///渐进动画
    [animation setDelegate:self];
    [sender.layer addAnimation:animation forKey:nil];
}

//闪烁完毕后 返回失败状态
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        self.clickBlock(CompleteTypeFailure);
    }
}

@end
