//
//  GameFailureView.m
//  DontTapWhiteBlock
//
//  Created by jiachen on 16/4/16.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import "GameFailureView.h"

@interface GameFailureView()




@end

@implementation GameFailureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static GameFailureView *instance;

+ (instancetype)shareInstance{
    @synchronized(self) {
        if (!instance) {
            NSArray *nibView = [[NSBundle mainBundle] loadNibNamed:@"GameFailureView" owner:nil options:nil];
            instance = [nibView lastObject];
            instance.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

        }
        return instance;
    }
}

- (void)awakeFromNib{
    
}

- (void)show{
//    instance.tipLabel.backgroundColor
}

//结束游戏
- (IBAction)close:(id)sender {
    if (_closeBlock != nil) {
        _closeBlock();
    }
}

//再来
- (IBAction)gameContine:(id)sender {
    if (_continueBlock != nil) {
        _continueBlock();
    }
}

//// - MARK: 页面显示 -》 更新数据
//- (void)setHidden:(BOOL)hidden{
//    self.hidden = hidden;
//    
//    
//}
@end
