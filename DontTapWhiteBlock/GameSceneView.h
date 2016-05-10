//
//  GameSceneView.h
//  RACDemo
//
//  Created by jiachen on 16/3/29.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CompleteType){
    CompleteTypeVictory = 1,
    CompleteTypeFailure,
    CompleteTypeNotClick
};


typedef void(^ClickBlock)(CompleteType completeType);

@interface GameSceneView : UIView
//音效设置
@property (nonatomic,strong) NSString *effect;

@property (nonatomic,assign) CompleteType completeType;
//返回点击之后的状态： 成功 / 失败
@property (nonatomic,copy) ClickBlock clickBlock;

@property (nonatomic,assign) int  goalIndex;
//恢复到初始状态
- (void)reSet;
@end
