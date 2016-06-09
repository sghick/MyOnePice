//
//  UIView+WCTransition.h
//  CustomTransitions
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 Two Toasters, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCTransitionsDefine.h"

@class WCAnimatedTransitioning;
@interface UIView (WCTransition)

+ (void)wc_transitionFromView:(UIView *)fromView
                       toView:(UIView *)toView
            transitionContext:(id<UIViewControllerContextTransitioning>)transitionContext
        animatedTransitioning:(WCAnimatedTransitioning *)animatedTransitioning
                      options:(WCViewAnimationOptions)options
                   completion:(void (^)(BOOL finished))completion;

@end
