//
//  GameFailureView.h
//  DontTapWhiteBlock
//
//  Created by jiachen on 16/4/16.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ContinueBlock)();
typedef void(^CloseBlock)();

@interface GameFailureView : UIView

+ (instancetype)shareInstance;



// - MARK:property


//上方提示文字
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
//当前分数
@property (weak, nonatomic) IBOutlet UILabel *currentScoreLabel;
//历史最佳战绩
@property (weak, nonatomic) IBOutlet UILabel *historyBestLabel;

@property (nonatomic,copy) ContinueBlock continueBlock;
@property (nonatomic,copy) CloseBlock closeBlock;



@end
