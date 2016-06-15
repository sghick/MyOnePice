//
//  WCTransitioningDelegate.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "WCTransitioningDelegate.h"
#import "WCInteractiveTransition.h"
#import "WCAnimatedTransitioning.h"

@interface WCTransitioningDelegate()

@property (strong, nonatomic) WCInteractiveTransition *presentInterTrans;
@property (strong, nonatomic) WCInteractiveTransition *dismissInterTrans;
@property (strong, nonatomic) WCInteractiveTransition *pushInterTrans;
@property (strong, nonatomic) WCInteractiveTransition *popInterTrans;

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
            trans.transVCType = WCTransitioningDelegateVCFrom;
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
            trans.transVCType = WCTransitioningDelegateVCTo;
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
            if (operation == UINavigationControllerOperationPush) {
                trans.transVCType = WCTransitioningDelegateVCFrom;
            } else if (operation == UINavigationControllerOperationPop) {
                trans.transVCType = WCTransitioningDelegateVCTo;
            } else {
                // none
            }
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

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    if ([animationController isKindOfClass:[WCAnimatedTransitioning class]]) {
        WCAnimatedTransitioning *trans = (WCAnimatedTransitioning *)animationController;
        if (trans.transVCType == WCTransitioningDelegateVCTo) {
            return self.popInterTrans.interation ? self.popInterTrans : nil;
        } else {
            return self.pushInterTrans.interation ? self.pushInterTrans : nil;
        }
    } else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.presentInterTrans.interation ? self.presentInterTrans : nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator{
    return self.dismissInterTrans.interation ? self.dismissInterTrans : nil;
}

- (void)setFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if (self.fromTrans) {
        [self.fromTrans setFromViewController:fromVC toViewController:toVC];
    }
    if (self.toTrans) {
        [self.toTrans setFromViewController:toVC toViewController:fromVC];
    }
    if (self.single) {
        [self.single setFromViewController:fromVC toViewController:toVC];
    }
}

- (void)setPanGestureWithInteractiveType:(WCInteractiveTransitionType)type
                               direction:(WCInteractiveTransitionGestureDirection)direction
                           gestureConifg:(GestureConifg)gestureConifg {
    switch (type) {
        case WCInteractiveTransitionTypePresent: {
            WCAnimatedTransitioning *trans = nil;
            if (self.single) {
                trans = self.single;
            } else if (self.fromTrans) {
                trans = self.fromTrans;
            }
            if (trans) {
                self.presentInterTrans = [WCInteractiveTransition interactiveTransitionWithTransitionType:type GestureDirection:direction];
                self.presentInterTrans.presentConifg = gestureConifg;
                [self.presentInterTrans addPanGestureForViewController:trans.iniFromVC];
            }
        }
            break;
        case WCInteractiveTransitionTypeDismiss: {
            WCAnimatedTransitioning *trans = nil;
            if (self.single) {
                trans = self.single;
            } else if (self.toTrans) {
                trans = self.toTrans;
            }
            if (trans) {
                self.dismissInterTrans = [WCInteractiveTransition interactiveTransitionWithTransitionType:type GestureDirection:direction];
                self.dismissInterTrans.dismissConifg = gestureConifg;
                [self.dismissInterTrans addPanGestureForViewController:trans.iniToVC];
            }
        }
            break;
        case WCInteractiveTransitionTypePush: {
            WCAnimatedTransitioning *trans = nil;
            if (self.single) {
                trans = self.single;
            } else if (self.fromTrans) {
                trans = self.fromTrans;
            }
            if (trans) {
                self.pushInterTrans = [WCInteractiveTransition interactiveTransitionWithTransitionType:type GestureDirection:direction];
                self.pushInterTrans.pushConifg = gestureConifg;
                [self.pushInterTrans addPanGestureForViewController:trans.iniFromVC];
            }
        }
            break;
        case WCInteractiveTransitionTypePop: {
            WCAnimatedTransitioning *trans = nil;
            if (self.single) {
                trans = self.single;
            } else if (self.toTrans) {
                trans = self.toTrans;
            }
            if (trans) {
                self.popInterTrans = [WCInteractiveTransition interactiveTransitionWithTransitionType:type GestureDirection:direction];
                self.popInterTrans.popConifg = gestureConifg;
                [self.popInterTrans addPanGestureForViewController:trans.iniToVC];
            }
        }
            break;
        default:
            break;
    }
}

@end
