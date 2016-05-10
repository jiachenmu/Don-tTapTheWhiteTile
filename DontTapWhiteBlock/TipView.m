//
//  TipView.m
//  RACDemo
//
//  Created by jiachen on 16/3/30.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import "TipView.h"

@interface TipView ()

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UILabel *messageLabel;

@property (nonatomic,strong) NSString *message;
@end

@implementation TipView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)buildUI{
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 60)];
    _messageLabel.numberOfLines = 0;
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor blueColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.font = DefaultFont(30);
    [self addSubview:_messageLabel];
}

- (void)setMessage:(NSString *)message{
    _message = message;
    _messageLabel.text = _message;
    [_messageLabel sizeToFit];
//    _messageLabel.center = CGPointMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    self.frame = CGRectMake(0, 0, _messageLabel.frame.size.width + 40 , _messageLabel.frame.size.height + 20);
    self.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _messageLabel.frame = CGRectMake(20, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height);
}

+ (void)showMessage:(NSString *)string{
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    
    TipView *view = [[TipView alloc] init];
    [view buildUI];
    view.message = string;
    
    [mainWindow addSubview:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            [view removeFromSuperview];
        }];
    });
}

+ (void)showFailureWithCompleteBlock:(CompleteBlock )completeblock{
    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    
    TipView *view = [[TipView alloc] init];
    [view buildUI];
    view.message = @"手快不太好哦😅";
    [mainWindow addSubview:view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [view removeFromSuperview];
        completeblock();
    });
}
@end
