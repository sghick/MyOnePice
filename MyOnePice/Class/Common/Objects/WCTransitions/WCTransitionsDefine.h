//
//  WCTransitionsDefine.h
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//


#import <Foundation/Foundation.h>

@class WCAnimatedTransitioning;

/**
 *  收到delegate时的处理 -presente
 */
typedef void (^WCHandleDelegatePresentedBlock)(WCAnimatedTransitioning *transitioning,
                                               UIViewController *presented,
                                               UIViewController *presenting,
                                               UIViewController *source);

/**
 *  收到delegate时的处理 -dismissed
 */
typedef void (^WCHandleDelegateDismissedBlock)(WCAnimatedTransitioning *transitioning,
                                               UIViewController *dismissed);

/**
 *  收到delegate时的处理 -tabBarController
 */
typedef void (^WCHandleDelegateTabBarControllerBlock)(WCAnimatedTransitioning *transitioning,
                                                      UIViewController *tabBarController,
                                                      UIViewController *fromVC,
                                                      UIViewController *toVC);

/**
 *  收到delegate时的处理 -navigationController
 */
typedef void (^WCHandleDelegateNavBarControllerBlock)(WCAnimatedTransitioning *transitioning,
                                                      UIViewController *navigationController,
                                                      UINavigationControllerOperation operation,
                                                      UIViewController *fromVC,
                                                      UIViewController *toVC);

/**
 *  动画block
 *
 *  @param transitionContext 转场
 *  @param transitioning     转场对象
 */
typedef void (^WCAnimateTransitionBlock)(id<UIViewControllerContextTransitioning> transitionContext,
                                         WCAnimatedTransitioning *transitioning);



/**
 *  CAAnimation 代理
 */
typedef void (^WCAnimationDidStartDelegateBlock)(WCAnimatedTransitioning *transitioning,
                                                 CAAnimation *anim);
typedef void (^WCAnimationDidStopDelegateBlock)(WCAnimatedTransitioning *transitioning,
                                                CAAnimation *anim,
                                                BOOL finished);

typedef NS_ENUM(NSInteger, WCTransitioningDelegateType) {
    WCTransitioningDelegateFTTrans, // 推出和收起各用一个动画
    WCTransitioningDelegateSingle,  // 推出和收起只用一个动画
};

typedef NS_ENUM(NSInteger, WCViewAnimationOptions) {
    WCViewAnimationOptionsNone,             // 无
    WCViewAnimationOptionsPointBlowup,      // 圆点扩散
    WCViewAnimationOptionsPointLetting,     // 圆点聚拢
};

/**
 *  为实现特殊转场规定的协议
 */
@protocol WCAnimationViewControllerDelegate <NSObject>

@optional
- (UIView *)animationView;

@end
