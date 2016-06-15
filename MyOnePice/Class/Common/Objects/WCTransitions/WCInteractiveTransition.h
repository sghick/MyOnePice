//
//  WCInteractiveTransition.h
//  TransitionDemo
//
//  Created by 丁治文 on 16/6/12.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCTransitionsDefine.h"

@interface WCInteractiveTransition : UIPercentDrivenInteractiveTransition
/**记录是否开始手势，判断pop操作是手势触发还是返回键触发*/
@property (nonatomic, assign) BOOL interation;
/**促发手势present的时候的config，config中初始化并present需要弹出的控制器*/
@property (nonatomic, copy) GestureConifg presentConifg;
@property (nonatomic, copy) GestureConifg dismissConifg;
/**促发手势push的时候的config，config中初始化并push需要弹出的控制器*/
@property (nonatomic, copy) GestureConifg pushConifg;
@property (nonatomic, copy) GestureConifg popConifg;

//初始化方法

+ (instancetype)interactiveTransitionWithTransitionType:(WCInteractiveTransitionType)type GestureDirection:(WCInteractiveTransitionGestureDirection)direction;
- (instancetype)initWithTransitionType:(WCInteractiveTransitionType)type GestureDirection:(WCInteractiveTransitionGestureDirection)direction;

/** 给传入的控制器添加手势*/
- (void)addPanGestureForViewController:(UIViewController *)viewController;

@end
