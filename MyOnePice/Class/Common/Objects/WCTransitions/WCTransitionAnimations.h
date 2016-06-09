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

//圆形放大(仅限首页展示所有车辆时使用)
+ (WCAnimateTransitionBlock)animateBlockForBlowup1;
//圆形缩小(仅限首页展示所有车辆时使用)
+ (WCAnimateTransitionBlock)animateBlockForLetting1;

@end
