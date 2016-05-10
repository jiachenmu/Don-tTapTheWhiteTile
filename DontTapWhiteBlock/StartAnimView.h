//
//  StartAnimView.h
//  DontTapWhiteBlock
//
//  Created by jiachen on 16/5/9.
//  Copyright © 2016年 jiachenmu. All rights reserved.
//  倒计时 3 2 1 动画view

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock)();

@interface StartAnimView : UIView

//封装为单例
+ (instancetype)shareInstance;

/**
*  倒计时 anim ......3 2 1 动画
*
*  @param anim          anim 变化的数字初始值
*  @param completeBlock 动画结束后的操作
*/
- (void)showWithAnimNum:(NSInteger)anim CompleteBlock:(CompleteBlock)completeBlock;

@end
