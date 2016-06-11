//
//  WCTransitionAnimations.h
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCTransitionsDefine.h"

@interface WCTransitionAnimations : NSObject

//系统翻转
+ (WCAnimateTransitionBlock)animateBlockForSingle;

//圆形放大
+ (WCAnimateTransitionBlock)animateBlockForBlowup1;
//圆形缩小
+ (WCAnimateTransitionBlock)animateBlockForLetting1;

//矩形放大
+ (WCAnimateTransitionBlock)animateBlockForBlowup2;
//矩形缩小
+ (WCAnimateTransitionBlock)animateBlockForLetting2;

//神奇移动放大
+ (WCAnimateTransitionBlock)animateBlockForBlowup3;
//神奇移动缩小
+ (WCAnimateTransitionBlock)animateBlockForLetting3;

@end
