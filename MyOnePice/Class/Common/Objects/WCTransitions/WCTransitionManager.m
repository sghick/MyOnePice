//
//  WCTransitionManager.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "WCTransitionManager.h"
#import "WCTransitionsDefine.h"
#import "WCTransitioningDelegate.h"
#import "WCAnimatedTransitioning.h"
#import "WCTransitionAnimations.h"

@implementation WCTransitionManager

+ (WCTransitioningDelegate *)transitionForTransDelegate1 {
    WCAnimatedTransitioning *single = [[WCAnimatedTransitioning alloc] initWithTransitionBlock:[WCTransitionAnimations animateBlockForSingle]];
    [single setHandleDelegateNavBarControllerBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *navigationController, UINavigationControllerOperation operation, UIViewController *fromVC, UIViewController *toVC) {
        transitioning.options = (operation == UINavigationControllerOperationPush
                                 ? UIViewAnimationOptionTransitionFlipFromRight
                                 : UIViewAnimationOptionTransitionFlipFromLeft);
    }];
    [single setHandleDelegateTabBarControllerBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *tabBarController, UIViewController *fromVC, UIViewController *toVC) {
        transitioning.options = UIViewAnimationOptionTransitionCrossDissolve;
    }];
    [single setHandleDelegatePresentedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *presented, UIViewController *presenting, UIViewController *source) {
        transitioning.options = UIViewAnimationOptionTransitionCurlUp;
    }];
    [single setHandleDelegateDismissedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *dismissed) {
        transitioning.options = UIViewAnimationOptionTransitionCurlDown;
    }];
    
    WCTransitioningDelegate *del = [[WCTransitioningDelegate alloc] initWithSingleAnimatedTransitioning:single];
    return del;
}

+ (WCTransitioningDelegate *)transitionForTransDelegate2 {
    WCAnimatedTransitioning *single = [[WCAnimatedTransitioning alloc] init];
    [single setHandleDelegatePresentedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *presented, UIViewController *presenting, UIViewController *source) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointBlowup;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForBlowup1];
    }];
    [single setHandleDelegateDismissedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *dismissed) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointLetting;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForLetting1];
    }];
    WCTransitioningDelegate *del = [[WCTransitioningDelegate alloc] initWithSingleAnimatedTransitioning:single];
    return del;
}

+ (WCTransitioningDelegate *)transitionForTransDelegate3 {
    WCAnimatedTransitioning *single = [[WCAnimatedTransitioning alloc] init];
    [single setHandleDelegatePresentedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *presented, UIViewController *presenting, UIViewController *source) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointBlowup;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForBlowup2];
    }];
    [single setHandleDelegateDismissedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *dismissed) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointLetting;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForLetting2];
    }];
    WCTransitioningDelegate *del = [[WCTransitioningDelegate alloc] initWithSingleAnimatedTransitioning:single];
    return del;
}

+ (WCTransitioningDelegate *)transitionForTransDelegate4 {
    WCAnimatedTransitioning *single = [[WCAnimatedTransitioning alloc] init];
    [single setHandleDelegatePresentedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *presented, UIViewController *presenting, UIViewController *source) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointBlowup;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForBlowup3];
    }];
    [single setHandleDelegateDismissedBlock:^(WCAnimatedTransitioning *transitioning, UIViewController *dismissed) {
        transitioning.duration = 0.2;
        transitioning.wc_options = WCViewAnimationOptionsPointLetting;
        transitioning.transitionBlock = [WCTransitionAnimations animateBlockForLetting3];
    }];
    WCTransitioningDelegate *del = [[WCTransitioningDelegate alloc] initWithSingleAnimatedTransitioning:single];
    return del;
}

@end
