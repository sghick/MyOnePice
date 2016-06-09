//
//  UIView+WCTransition.m
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import "UIView+WCTransition.h"
#import "WCAnimatedTransitioning.h"

@implementation UIView (WCTransition)

+ (void)wc_transitionFromView:(UIView *)fromView
                       toView:(UIView *)toView
            transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
        animatedTransitioning:(WCAnimatedTransitioning *)animatedTransitioning
                      options:(WCViewAnimationOptions)options
                   completion:(void (^)(BOOL))completion {
    switch (options) {
        case WCViewAnimationOptionsPointBlowup: {
            [self wc_transitionWithOptionsPointBlowupFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:animatedTransitioning completion:completion];
        }
            break;
        case WCViewAnimationOptionsPointLetting: {
            [self wc_transitionWithOptionsPointLettingFromView:fromView toView:toView transitionContext:transitionContext animatedTransitioning:animatedTransitioning completion:completion];
        }
            break;
        default: {
            if (completion) {
                completion(YES);
            }
        }
            break;
    }
}

+ (void)wc_transitionWithOptionsPointBlowupFromView:(UIView *)fromView
                                             toView:(UIView *)toView
                                  transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
                              animatedTransitioning:(WCAnimatedTransitioning *)animatedTransitioning
                                         completion:(void (^)(BOOL))completion {
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    //画两个圆路径
    UIBezierPath *startCycle =  [UIBezierPath bezierPathWithOvalInRect:fromView.frame];
    CGFloat x = MAX(fromView.frame.origin.x, containerView.frame.size.width - fromView.frame.origin.x);
    CGFloat y = MAX(fromView.frame.origin.y, containerView.frame.size.height - fromView.frame.origin.y);
    CGFloat radius = sqrtf(pow(x, 2) + pow(y, 2));
    UIBezierPath *endCycle = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    //创建CAShapeLayer进行遮盖
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = endCycle.CGPath;
    //将maskLayer作为toVC.View的遮盖
    toView.layer.mask = maskLayer;
    //创建路径动画
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    //动画是加到layer上的，所以必须为CGPath，再将CGPath桥接为OC对象
    maskLayerAnimation.fromValue = (__bridge id)(startCycle.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((endCycle.CGPath));
    maskLayerAnimation.duration = animatedTransitioning.duration;
    maskLayerAnimation.delegate = animatedTransitioning;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
    [animatedTransitioning setAnimationDidStopDelegateBlock:^(WCAnimatedTransitioning *transitioning, CAAnimation *anim, BOOL finished) {
        [transitionContext completeTransition:YES];
        if (completion) {
            completion(finished);
        }
    }];
}

+ (void)wc_transitionWithOptionsPointLettingFromView:(UIView *)fromView
                                              toView:(UIView *)toView
                                   transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
                               animatedTransitioning:(WCAnimatedTransitioning *)animatedTransitioning
                                          completion:(void (^)(BOOL))completion {
    UIView *containerView = [transitionContext containerView];
    
    //画两个圆路径
    CGFloat radius = sqrtf(containerView.frame.size.height * containerView.frame.size.height + containerView.frame.size.width * containerView.frame.size.width) / 2;
    UIBezierPath *startCycle = [UIBezierPath bezierPathWithArcCenter:containerView.center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    UIBezierPath *endCycle =  [UIBezierPath bezierPathWithOvalInRect:toView.frame];
    //创建CAShapeLayer进行遮盖
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = [UIColor greenColor].CGColor;
    maskLayer.path = endCycle.CGPath;
    fromView.layer.mask = maskLayer;
    //创建路径动画
    CABasicAnimation *maskLayerAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    maskLayerAnimation.fromValue = (__bridge id)(startCycle.CGPath);
    maskLayerAnimation.toValue = (__bridge id)((endCycle.CGPath));
    maskLayerAnimation.duration = animatedTransitioning.duration;
    maskLayerAnimation.delegate = animatedTransitioning;
    maskLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [maskLayerAnimation setValue:transitionContext forKey:@"transitionContext"];
    [maskLayer addAnimation:maskLayerAnimation forKey:@"path"];
    
    [animatedTransitioning setAnimationDidStopDelegateBlock:^(WCAnimatedTransitioning *transitioning, CAAnimation *anim, BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
        }
        if (completion) {
            completion(finished);
        }
    }];
}

@end
