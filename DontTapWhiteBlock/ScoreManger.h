//
//  ScoreManger.h
//  DontTapWhiteBlock
//
//  Created by jiachen on 16/4/16.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//  分数管理

#import <Foundation/Foundation.h>

@interface ScoreManger : NSObject

//获取最佳成绩
+ (float)getBestScore;

//更新成绩，若此时成绩高于最佳成绩 则更新
+ (void)updateWithCurrentScore:(float)currentScore;

@end
