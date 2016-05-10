//
//  SettingViewController.m
//  RACDemo
//
//  Created by jiachen on 16/3/31.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import "SettingViewController.h"



@interface SettingViewController ()
@property (strong, nonatomic) IBOutlet UIView *SettingView;

@property (weak, nonatomic) IBOutlet UIButton *openMyJianshu;

@property (weak, nonatomic) IBOutlet UIButton *adjustSoundEffect;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UIButton *openMygithubBtn;


@property (nonatomic,strong) NSString *keySound;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //读取按键音效
    _keySound = [[NSUserDefaults standardUserDefaults] objectForKey:KeyEffectSetting];
    
    
}



- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSUserDefaults standardUserDefaults ]setObject:_keySound forKey:KeyEffectSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// - MARK: 打开我的简书
- (IBAction)openMyJIanShu:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:JianShuURL]];
}

//打开我的Github
- (IBAction)openMygithub:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GithubURL]];
}
// - MARK: 返回
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:false completion:nil];
}

//调节按键音效：  目前只有两个特效😂
- (IBAction)adJustKeySound:(id)sender {
    if ([_keySound  isEqual: BoxingEffext]) {
        _keySound = KnifeEffect;
        [sender setTitle:@"按键：刀叉碰撞🔪" forState:UIControlStateNormal ];
    }else{
        _keySound = BoxingEffext;
        [sender setTitle:@"按键：拳击音效👊" forState:UIControlStateNormal];
    }
}

//调整游戏速度
- (IBAction)adjustGameSpeed:(id)sender {
    //先读取游戏速度
    NSNumber *speed = [[NSUserDefaults standardUserDefaults] objectForKey:GameSpeed];
    if (speed == nil) {
        speed = [NSNumber numberWithFloat:2.0];
    }
}


@end
