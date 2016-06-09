//
//  WCAnimatedTransitioning.h
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCTransitionsDefine.h"

@interface WCAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

/**
 *  动画执行时间, 默认:0
 */
@property (assign, nonatomic) NSTimeInterval duration;

/**
 *  动画执行效果
 */
@property (assign, nonatomic) UIViewAnimationOptions options;

/**
 *  自定义动画执行效果
 */
@property (assign, nonatomic) WCViewAnimationOptions wc_options;

/**
 *  动画执行自定义
 */
@property (copy  , nonatomic) WCAnimateTransitionBlock transitionBlock;

/**
 *  收到delegate时的处理 -presente
 */
@property (copy  , nonatomic) WCHandleDelegatePresentedBlock handleDelegatePresentedBlock;

/**
 *  收到delegate时的处理 -dismissed
 */
@property (copy  , nonatomic) WCHandleDelegateDismissedBlock handleDelegateDismissedBlock;

/**
 *  收到delegate时的处理 -tabBarController
 */
@property (copy  , nonatomic) WCHandleDelegateTabBarControllerBlock handleDelegateTabBarControllerBlock;

/**
 *  收到delegate时的处理 -navigationController
 */
@property (copy  , nonatomic) WCHandleDelegateNavBarControllerBlock handleDelegateNavBarControllerBlock;

#pragma mark - DelegateBlock
/**
 *  动画执行代理
 */
@property (copy  , nonatomic) WCAnimationDidStartDelegateBlock animationDidStartDelegateBlock;
@property (copy  , nonatomic) WCAnimationDidStopDelegateBlock animationDidStopDelegateBlock;

#pragma mark - Init
/**
 *  初始化方法
 */
- (instancetype)initWithTransitionBlock:(WCAnimateTransitionBlock)transitionBlock;

// for custom
- (void)setHandleDelegatePresentedBlock:(WCHandleDelegatePresentedBlock)handleDelegatePresentedBlock;
- (void)setHandleDelegateDismissedBlock:(WCHandleDelegateDismissedBlock)handleDelegateDismissedBlock;
- (void)setHandleDelegateTabBarControllerBlock:(WCHandleDelegateTabBarControllerBlock)handleDelegateTabBarControllerBlock;
- (void)setHandleDelegateNavBarControllerBlock:(WCHandleDelegateNavBarControllerBlock)handleDelegateNavBarControllerBlock;

#pragma mark - Delegate
- (void)setAnimationDidStartDelegateBlock:(WCAnimationDidStartDelegateBlock)animationDidStartDelegateBlock;
- (void)setAnimationDidStopDelegateBlock:(WCAnimationDidStopDelegateBlock)animationDidStopDelegateBlock;
- (void)animationDidStart:(CAAnimation *)anim;
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;

@end
