//
//  WCTransitionAnimations.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "WCTransitionAnimations.h"
#import "UIView+WCTransition.h"
#import "WCAnimatedTransitioning.h"

@implementation WCTransitionAnimations

+ (WCAnimateTransitionBlock)animateBlockForSingle {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        [toViewController.view layoutIfNeeded];
        
        UIView *fromView = fromViewController.view;
        UIView *toView = toViewController.view;
        
        BOOL optionsContainShowHideTransitionViews = (transitioning.options & UIViewAnimationOptionShowHideTransitionViews) != 0;
        if (!optionsContainShowHideTransitionViews) {
            [[transitionContext containerView] addSubview:toView];
        }
        
        [UIView transitionFromView:fromView
                            toView:toView
                          duration:transitioning.duration
                           options:transitioning.options
                        completion:^(BOOL finished) {
                            if (!optionsContainShowHideTransitionViews) {
                                [fromView removeFromSuperview];
                            }
                            [transitionContext completeTransition:YES];
                        }];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForBlowup1 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *fromView = ((UIViewController<WCAnimationViewControllerDelegate> *)transitioning.fromVC).animationView;
        UIView *toView = transitioning.toVC.view;
        
        [UIView wc_transitionFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:transitioning options:WCViewAnimationOptionsPointBlowup completion:nil];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForLetting1 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *fromView = transitioning.fromVC.view;
        UIView *toView = ((UIViewController<WCAnimationViewControllerDelegate> *)transitioning.toVC).animationView;
        
        [UIView wc_transitionFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:transitioning options:WCViewAnimationOptionsPointLetting completion:nil];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForBlowup2 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *toView = transitioning.toVC.view;
        UIView *containerView = [transitionContext containerView];
        CGRect frame = containerView.bounds;
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, 0, 0, 0));
        toView.frame = frame;
        [containerView addSubview:toView];
        toView.alpha = 0.0;
        toView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        [UIView animateWithDuration:transitioning.duration / 2.0 animations:^{
            toView.alpha = 1.0;
        }];
        CGFloat damping = 0.55;
        [UIView animateWithDuration:transitioning.duration delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForLetting2 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *fromView = transitioning.fromVC.view;
        [UIView animateWithDuration:3.0 * transitioning.duration / 4.0
                              delay:transitioning.duration / 4.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [fromView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        
        [UIView animateWithDuration:2.0 * transitioning.duration
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:-15.0
                            options:0
                         animations:^{
                             fromView.transform = CGAffineTransformMakeScale(0.3, 0.3);
                         }
                         completion:nil];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForBlowup3 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *fromView = ((UIViewController<WCAnimationViewControllerDelegate> *)transitioning.fromVC).animationView;
        UIView *toView = transitioning.toVC.view;
        UIView *containerView = [transitionContext containerView];
        [containerView addSubview:toView];
        
        toView.alpha = 0.0;
        toView.frame = fromView.frame;
        [UIView animateWithDuration:transitioning.duration / 2.0 animations:^{
            toView.alpha = 1.0;
            toView.frame = containerView.bounds;
        }];
        CGFloat damping = 0.55;
        [UIView animateWithDuration:transitioning.duration delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForLetting3 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIView *fromView = transitioning.fromVC.view;
        UIView *toView = ((UIViewController<WCAnimationViewControllerDelegate> *)transitioning.toVC).animationView;
        
        [UIView animateWithDuration:3.0 * transitioning.duration / 4.0
                              delay:transitioning.duration / 4.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [fromView removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        
        [UIView animateWithDuration:2.0 * transitioning.duration
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:-15.0
                            options:0
                         animations:^{
                             fromView.frame = toView.frame;
                         }
                         completion:nil];
    };
    return block;
}

@end
