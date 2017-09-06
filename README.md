# iOS-OC项目 别踩白块(Don't Tap The White Tile)

***

## 写在前面的话

#### ①别踩白块游戏简介：

>《别踩白块儿 Don't Tap The White Tile》，这就是这个游戏唯一的一个规则，我们只需要不断踩着黑色方块前进即可，很简单吧？谁都可以会玩，但并不是谁都能玩得很好噢，你呢？快来挑战看看吧！经典模式，以最快的速度到达终点。街机模式，你有能力得多少分就得多少分，没有任何限制，这也是最具挑战性的一个模式。限时模式，在30秒内看你能走几步。极速模式，没有最高速限制的街机模式, 挑战你的极限接力模式，规定时间内完成50块儿，然后会有更多时间去完成另外的50块儿。【复制于百度百科】

如果你没玩过，没关系 ，上图看看
![别踩白块儿.gif](http://upload-images.jianshu.io/upload_images/1299512-1c86ccf35a745617.gif?imageMogr2/auto-orient/strip)
意思就是：每行有四个按钮，黑色的按钮是正确的需要你点击的按钮，白色块点击后游戏失败，所以这个游戏就叫"别踩白块儿"😂，别问我我为什么这么机智。

#### ②写这个小游戏的目的

##### **最重要 :  __纯属好玩__**

我觉得做一件事情最大的推动力就是 **兴趣** **兴趣** **兴趣**。
看到好多游戏都是拿Unity3D、Cocos2D开发的，我就想 我用系统自带的一些东海也可以实现一些简单的平面2D动画呀，所以我试了试，所以就有了这篇简书。

##### **电商之类的app不美观**

前面仿写过[半糖app](http://www.jianshu.com/p/7b57eb0c4abe)，公司也是电商的app，所以对于电商app无爱了，,,Ծ‸Ծ,,，都是 首页、分类、购物车、个人中心的套路，你懂的。相反我倒是更喜欢一些电商入口的APP，就比如半糖、美丽说、小红书之类的app，UI很美观，这是吸引我的地方。

***

## 项目整体的概括

#### ①开发周期： 

工作闲暇之余累计有10天左右，最近一个半月在忙公司的项目，只好抽时间写啦

#### ②开发工具和语言：

 开发工具为Xcode7.3   语言为Objective-C
因为前面仿写半糖app的时候，好多朋友给我说不太懂swift，那我就写个OC的小项目

#### ③开发要点： 

**游戏成功、失败的逻辑代码基于 `ReactiveCocoa` ,代码有详细的解释。**
音频管理、整体的UI搭建不难，难的是整体游戏逻辑的设计。

***

## 项目详细实现过程

#### ①首页，页面较为简单，主要介绍一下 UIButton与 `ReactiveCocoa`的结合使用

![tmp58f5a0f6.png](http://upload-images.jianshu.io/upload_images/1299512-81e0e7253713d485.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

--主要代码如下
```
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
```

解释：`[_startButton rac_signalForControlEvents:UIControlEventTouchUpInside] `返回一个 `RACSignal`,可以理解为 一个信号，后面 `subscribeNext:^(id x) {}` 意思就是 接受到这个信号所做的操作。从字面意思上可以理解为，前者当你点击按钮，触发`UIControlEventTouchUpInside`事件的时候 ，发出一个信号，后者是接受到这个信号，你要干什么，由你决定。

#### ②游戏页面view，
 ##### 倒计时动画介绍
上图：

![倒计时动画.gif](http://upload-images.jianshu.io/upload_images/1299512-76ac222f93784caa.gif?imageMogr2/auto-orient/strip)
----构成：view背景为黑色，中间添加了一个label，显示当前的数字

```
/**
*  倒计时 anim ......3 2 1 动画
*
*  @param anim          anim 变化的数字初始值
*  @param completeBlock 动画结束后的操作
*/
- (void)showWithAnimNum:(NSInteger)anim CompleteBlock:(CompleteBlock)completeBlock;
```
----实现思路： 要做的从给定的参数 `anim `  递减到 0  之后结束动画，然后执行`completeBlock`
，我是这样写一个类似于递归的动画：
①整体动画可以分为很多个，单个数字，做缩放和透明度改变的动画组
```
//返回一个 动画group
- (CAAnimationGroup *)animationGroup {
    //缩放
    CABasicAnimation *animation1 = [CABasicAnimation animation];
    [animation1 setKeyPath:@"transform.scale"];
    [animation1 setFromValue:@1.0];
    [animation1 setToValue:@4.0];
    [animation1 setDuration:1.0];
    //改变透明度
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    [animation2 setKeyPath:@"alpha"];
    [animation2 setFromValue:@1.0];
    [animation2 setToValue:@0.3];
    [animation2 setDuration:1.0];
    
    
    CAAnimationGroup *animGroup = [[CAAnimationGroup alloc] init];
    animGroup.animations = [NSArray arrayWithObjects:animation1,animation2, nil];
    [animGroup setDuration:1.0];
    [animGroup setDelegate:self];
    return animGroup;
}

```
@用一个参数控制整体的动画的继续和停止，就是`_animIndex`
每一个动画group执行完毕后，在 `- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag` 中进行`_animIndex--`，并且添加下一组动画，看代码：
```
// - MARK: Animation Delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag && _animIndex > 0) {
        _animIndex--;
        _animLabel.text = [NSString stringWithFormat:@"%ld",(long)_animIndex];
        [_animLabel.layer addAnimation:[self animationGroup] forKey:nil];
    }
    //动画执行完毕后 执行的操作
    if (_animIndex == 0) {
        if (_completeBlock != nil) {
            //延迟0.4s之后 再开始游戏 防止游戏开始太快 user接受不了
            self.hidden = true;
            WeakSelf;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _completeBlock();
                [weakSelf.animLabel.layer removeAllAnimations];
                weakSelf.hidden = false;
                [weakSelf removeFromSuperview];
            });
        }
    }
}
```
 ##### 游戏界面如何搭建
①首页整体界面搭建
![B7A2A5EB-B936-4ABD-BF2A-F6135389EC0C.png](http://upload-images.jianshu.io/upload_images/1299512-23020b7609d725bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
界面中每一个被我框起来的都是我封装的 `GameSceneView`,当然我们不能在每一个`GameSceneView`那如何实现''重用'呢'
**实现思路：**
①计算你的屏幕中需要多少个`gameScene`，
```
// - 1: 先计算出 屏幕中需要多少个 scene
    _sceneCount = ceil(SCREEN_HEIGHT / WhiteBlockHeight) + 1;
```
②创建与之等同数量的scene
`_frameArray `存储的是 scene创建时的初始frame,便于点击错误时，直接恢复到初始的frame
`_operateArray `将创建好的scene集中到一起，便于管理
```
[_frameArray addObject:[NSValue valueWithCGRect:scene.frame]];
[_operateArray addObject:scene];
```
屏幕上所有的 `scene`都是向下滚动的，每次滚动判断是否超出屏幕，当用户点击正确、scene漂移到屏幕外的时候，再更新`scene`的`frame`，这个scene将被安排到最后一个`scene`的后面，上代码：
```
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //用 CADisplayLink 进行刷新 频率更快，动画效果不会卡顿
    disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(startScroll)];
    
    //先执行 3 2 1 这样的动画
    [[StartAnimView shareInstance] showWithAnimNum:3 CompleteBlock:^{
        [disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }];
}
```
disPlayLink一直在调用 `- (void)startScroll`这个方法，刷新界面
```
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

```

点击正确之后 计算该 `scene`新的frame
```
//点击正确之后 将超出屏幕的scene 改变frame ，让玩家感觉一直有新scene的出来
- (CGRect)calculateNewFrameWithTag: (NSInteger )tag {
    tag = tag == 0 ? _sceneCount - 1 : tag - 1;
    
    GameSceneView *scene = (GameSceneView *)[_operateArray objectAtIndex:tag];
    CGRect frame = scene.frame;
    frame.origin.y -= WhiteBlockHeight;
    return frame;
}
```
这一部分用图很好解释：

![tmp13f239f2.png](http://upload-images.jianshu.io/upload_images/1299512-4e87160e38bfa764.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
红色框为屏幕范围， 第0个`scene`超出屏幕后，新的位置即在 第4个`scene`的后面

 ##### GameSceneView 的构建
这一部分有一个小遗憾，应该将每行的button数量写成 参数，不应该写成4😀
每个button通过  button.layer的borderColor 和 borderWidth属性设置边框，所以显的有点粗糙。
主要代码：
```
// - MARK: private method
//快速构建button
- (UIButton *)quickCreateButtonWithFrame:(CGRect)frame{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    
    btn.selected = false;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.layer.borderWidth = 0.5;
    btn.backgroundColor = [UIColor whiteColor];

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
              //点击错误之后 将正确的btn 执行动画
              [weakSelf clickButtonFailureWithButton:btn];
              return [UIColor orangeColor];
          }
          return [UIColor whiteColor];
          
    } ]subscribeNext:^(UIColor *color) {
        btn.backgroundColor = color;
    }];
    
    return btn;
}

```
解释一下：
**对于其中`ReactiveCocoa`的解释**
`[btn rac_signalForControlEvents:UIControlEventTouchUpInside]`就是当你点击button的时候 会发出一个信号，` map:^id(id value) { ........}`是接受到该信号之后，你做的一些操作，返回一个value对象 ，`subscribeNext:^(id value) {.......}` 就是 对于接受到的`value`做的一些操作

用一个比喻来说，`[btn rac_signalForControlEvents:UIControlEventTouchUpInside]` 就是水源，` map:^id(id value) { ........}`就是农夫山泉加工厂，`subscribeNext:^(id value) {.......}`就是水送到你手里了，你要干什么，洗脸洗脚喝掉随便你。。

**对于游戏逻辑的解释：**
①`isHasOtherSelected`这个bool类型的变量 ：
true代表已经有一个button被点击  false代表没有button被点击 
②根据点击成功与否,返回完成状态completeType
点击成功：`weakSelf.clickBlock(CompleteTypeVictory);`
点击失败：
```
//点击错误之后  将失败的btn 闪烁下
              [weakSelf clickButtonFailureWithButton:btn];
```
button闪烁动画如下
```
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
```

 ##### 音频处理、
`SoundPlayer`这个类负责播放音频,调用`AVAudioPlayer`来播放音频
有三个方法:
```
//按钮点击时播放的声音
+ (void)playWithMusicName: (NSString *)fileName;

//播放背景音乐
+ (void)playBackgroundMusicWithName: (NSString *)fileName;

//暂停背景音乐
+ (void)pauseBGM;
```
**关于点击音效的处理**
我有两个方案，都在代码里面
①点击按钮时，按点击次数来播放对应的声音：
具体实现：
```
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
    }
```
**关于音频的来源**：我将 *马克西姆* 的**克罗地亚狂想曲**分成了每个部分为1s的片段,大概200多个片段
这一部分有个**疑问**:声音文件一般不是分为左右声道吗，我将其中一个声道抽离出来当做背景音乐，另一个声道文件分成若干分，当按钮点击时播放是不是更好？懂电子音频处理的朋友出来回答下呗。

##项目感想
①其实复杂动画也是 "缩放" "旋转" "改变透明度" "移动"等一些基础动画的组合，下次遇到动画的时候可以试着将动画进行分解，这样就会减小实现的难度，
②尽量将代码写的清晰易懂，不忙的时候多回去review代码，就可以发现当初代码的一些不合理的逻辑，这样才会进步，这些天回去将我的[高仿半糖app](http://www.jianshu.com/p/7b57eb0c4abe) review下，古人老话，**温故而知新 可以为师矣**
③学习之路，**任重而道远，路漫漫其修远兮，吾将上下而求索**
##Github项目下载地址
**温馨提示：**app启动后 会有背景音乐响起，so，你懂的，点击按钮也会播放 **克罗地亚狂想曲**的片段，运行时请请调低音量
![请运行.xcworkspace](http://upload-images.jianshu.io/upload_images/1299512-d22eeea07435f018.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
[点击去我的Github下载](https://github.com/jiachenmu/Don-tTapTheWhiteTile)

##我的简书地址
[点击去我的简书](http://www.jianshu.com/p/fd4c46c31508)

**工作事宜及问题交流请联系QQ: 1691919529**


