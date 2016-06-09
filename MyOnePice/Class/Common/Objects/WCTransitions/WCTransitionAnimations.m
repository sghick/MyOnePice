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
        UINavigationController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UITabBarController *fromNav = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        id<WCAnimationViewControllerDelegate> fromVC = (id<WCAnimationViewControllerDelegate>)((UINavigationController *)fromNav.viewControllers.firstObject).viewControllers.firstObject;

        UIView *fromView = fromVC.animationView;
        UIView *toView = toVC.view;
        
        [UIView wc_transitionFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:transitioning options:WCViewAnimationOptionsPointBlowup completion:nil];
    };
    return block;
}

+ (WCAnimateTransitionBlock)animateBlockForLetting1 {
    WCAnimateTransitionBlock block = ^(id<UIViewControllerContextTransitioning> transitionContext, WCAnimatedTransitioning *transitioning) {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UITabBarController *toNav = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        id<WCAnimationViewControllerDelegate> toVC = (id<WCAnimationViewControllerDelegate>)((UINavigationController *)toNav.viewControllers.firstObject).viewControllers.firstObject;
        
        UIView *fromView = fromVC.view;
        UIView *toView = toVC.animationView;
        
        [UIView wc_transitionFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:transitioning options:WCViewAnimationOptionsPointLetting completion:nil];
    };
    return block;
}

@end
