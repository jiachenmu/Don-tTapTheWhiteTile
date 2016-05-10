//
//  TipView.h
//  RACDemo
//
//  Created by jiachen on 16/3/30.
//  Copyright © 2016年 jiachen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteBlock)();

@interface TipView : UIView

+ (void)showMessage: (NSString *)string;

+ (void)showFailureWithCompleteBlock:(CompleteBlock )completeblock;
@end
