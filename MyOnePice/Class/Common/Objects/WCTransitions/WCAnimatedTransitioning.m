//
//  WCAnimatedTransitioning.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/7.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "WCAnimatedTransitioning.h"

@interface WCAnimatedTransitioning ()

@end

@implementation WCAnimatedTransitioning

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 0.4;
        _options = 0;
    }
    return self;
}

- (instancetype)initWithTransitionBlock:(WCAnimateTransitionBlock)transitionBlock {
    self = [self init];
    if (self) {
        _transitionBlock = transitionBlock;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (_transitionBlock) {
        _transitionBlock(transitionContext, self);
    }
}

- (void)animationDidStart:(CAAnimation *)anim {
    if (self.animationDidStartDelegateBlock) {
        self.animationDidStartDelegateBlock(self, anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.animationDidStopDelegateBlock) {
        self.animationDidStopDelegateBlock(self, anim, flag);
    }
}

- (void)setFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    _fromVC = fromVC;
    _toVC = toVC;
    _iniFromVC = fromVC;
    _iniToVC = toVC;
}

- (void)setTransVCType:(WCTransitioningDelegateVCType)transVCType {
    _transVCType = transVCType;
    switch (transVCType) {
        case WCTransitioningDelegateVCFrom: {
            _fromVC = _iniFromVC;
            _toVC = _iniToVC;
        }
            break;
        case WCTransitioningDelegateVCTo: {
            _fromVC = _iniToVC;
            _toVC = _iniFromVC;
        }
            break;
            
        default:
            break;
    }
}

@end
