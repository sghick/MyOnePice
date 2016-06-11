//
//  WCTransitionManager.h
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

/// 若是给nav或者tabBar的transDelegate增加动画,这个动画是全局的
#import <Foundation/Foundation.h>

@class WCTransitioningDelegate;
@interface WCTransitionManager : NSObject

/**
 *  系统转场动画
 */
+ (WCTransitioningDelegate *)transitionForTransDelegate1;

/**
 *  圆形放大缩小
 */
+ (WCTransitioningDelegate *)transitionForTransDelegate2;

/**
 *  矩形放大缩小
 */
+ (WCTransitioningDelegate *)transitionForTransDelegate3;

/**
 *  神奇移动
 */
+ (WCTransitioningDelegate *)transitionForTransDelegate4;

@end
