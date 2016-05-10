//
//  ScoreManger.m
//  DontTapWhiteBlock
//
//  Created by jiachen on 16/4/16.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//  分数管理

#import "ScoreManger.h"

@implementation ScoreManger



+ (float)getBestScore{
    
    NSNumber *bestScore = [[NSUserDefaults standardUserDefaults] objectForKey:BestScoreKey];
    if (bestScore == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:0.0] forKey:BestScoreKey];
        bestScore = [NSNumber numberWithFloat:0.0];
    }
    
    return bestScore.floatValue;
}

+ (void)updateWithCurrentScore:(float)currentScore{
    float bestScore = [ScoreManger getBestScore];
    bestScore = bestScore < currentScore ? currentScore : bestScore;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:bestScore] forKey:BestScoreKey];
}
@end
