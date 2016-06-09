//
//  WCTransitioningDelegate.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "WCTransitioningDelegate.h"
#import "WCAnimatedTransitioning.h"

@interface WCTransitioningDelegate()

@property (strong, nonatomic) WCAnimatedTransitioning *fromTrans;
@property (strong, nonatomic) WCAnimatedTransitioning *toTrans;

@property (strong, nonatomic) WCAnimatedTransitioning *single;

@property (assign, nonatomic) WCTransitioningDelegateType transitioningDelegateType;

@end

@implementation WCTransitioningDelegate

- (instancetype)initWithPresentAnimatedTransitioning:(WCAnimatedTransitioning *)fromTrans dismissAnimatedTransitioning:(WCAnimatedTransitioning *)toTrans {
    self = [super init];
    if (self) {
        _fromTrans = fromTrans;
        _toTrans = toTrans;
        _transitioningDelegateType = WCTransitioningDelegateFTTrans;
    }
    return self;
}

- (instancetype)initWithSingleAnimatedTransitioning:(id<UIViewControllerAnimatedTransitioning>)single {
    self = [super init];
    if (self) {
        _single = single;
        _transitioningDelegateType = WCTransitioningDelegateSingle;
    }
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    WCAnimatedTransitioning *trans = self.fromTrans;
    switch (self.transitioningDelegateType) {
        case WCTransitioningDelegateFTTrans: {
            trans = self.fromTrans;
        }
            break;
        case WCTransitioningDelegateSingle: {
            trans = self.single;
        }
            break;
        default:
            break;
    }
    
    if (trans.handleDelegatePresentedBlock) {
        trans.handleDelegatePresentedBlock(trans, presented, presenting, source);
    }
    return trans;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    WCAnimatedTransitioning *trans = self.toTrans;
    switch (self.transitioningDelegateType) {
        case WCTransitioningDelegateFTTrans: {
            trans = self.toTrans;
        }
            break;
        case WCTransitioningDelegateSingle: {
            trans = self.single;
        }
            break;
        default:
            break;
    }
    
    if (trans.handleDelegateDismissedBlock) {
        trans.handleDelegateDismissedBlock(trans, dismissed);
    }
    return trans;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
           animationControllerForTransitionFromViewController:(UIViewController *)fromVC
                                             toViewController:(UIViewController *)toVC {
    WCAnimatedTransitioning *trans = self.single;
    if (trans.handleDelegateTabBarControllerBlock) {
        trans.handleDelegateTabBarControllerBlock(trans, tabBarController, fromVC, toVC);
    }
    return trans;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    WCAnimatedTransitioning *trans = self.toTrans;
    switch (self.transitioningDelegateType) {
        case WCTransitioningDelegateFTTrans: {
            if (operation == UINavigationControllerOperationPush) {
                trans = self.fromTrans;
            } else if (operation == UINavigationControllerOperationPop) {
                trans = self.toTrans;
            } else {
                // none
            }
        }
            break;
        case WCTransitioningDelegateSingle: {
            trans = self.single;
        }
            break;
        default:
            break;
    }
    if (trans.handleDelegateNavBarControllerBlock) {
        trans.handleDelegateNavBarControllerBlock(trans, navigationController, operation, fromVC, toVC);
    }
    return trans;
}

@end
