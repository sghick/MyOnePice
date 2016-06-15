//
//  WCInteractiveTransition.m
//  TransitionDemo
//
//  Created by 丁治文 on 16/6/12.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "WCInteractiveTransition.h"

@interface WCInteractiveTransition ()

@property (nonatomic, weak) UIViewController *vc;
/**手势方向*/
@property (nonatomic, assign) WCInteractiveTransitionGestureDirection direction;
/**手势类型*/
@property (nonatomic, assign) WCInteractiveTransitionType type;

@end

@implementation WCInteractiveTransition

+ (instancetype)interactiveTransitionWithTransitionType:(WCInteractiveTransitionType)type GestureDirection:(WCInteractiveTransitionGestureDirection)direction{
    return [[self alloc] initWithTransitionType:type GestureDirection:direction];
}

- (instancetype)initWithTransitionType:(WCInteractiveTransitionType)type GestureDirection:(WCInteractiveTransitionGestureDirection)direction{
    self = [super init];
    if (self) {
        _direction = direction;
        _type = type;
    }
    return self;
}

- (void)addPanGestureForViewController:(UIViewController *)viewController{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.vc = viewController;
    [viewController.view addGestureRecognizer:pan];
}

/**
 *  手势过渡的过程
 */
- (void)handleGesture:(UIPanGestureRecognizer *)panGesture{
    //手势百分比
    CGFloat persent = 0;
    switch (_direction) {
        case WCInteractiveTransitionGestureDirectionLeft:{
            CGFloat transitionX = -[panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case WCInteractiveTransitionGestureDirectionRight:{
            CGFloat transitionX = [panGesture translationInView:panGesture.view].x;
            persent = transitionX / panGesture.view.frame.size.width;
        }
            break;
        case WCInteractiveTransitionGestureDirectionUp:{
            CGFloat transitionY = -[panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
        case WCInteractiveTransitionGestureDirectionDown:{
            CGFloat transitionY = [panGesture translationInView:panGesture.view].y;
            persent = transitionY / panGesture.view.frame.size.width;
        }
            break;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            //手势开始的时候标记手势状态，并开始相应的事件
            self.interation = YES;
            [self startGesture];
            break;
        case UIGestureRecognizerStateChanged:{
            //手势过程中，通过updateInteractiveTransition设置pop过程进行的百分比
            [self updateInteractiveTransition:persent];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            //手势完成后结束标记并且判断移动距离是否过半，过则finishInteractiveTransition完成转场操作，否者取消转场操作
            self.interation = NO;
            if (persent > 0.5) {
                [self finishInteractiveTransition];
            }else{
                [self cancelInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}

- (void)startGesture{
    switch (_type) {
        case WCInteractiveTransitionTypePresent:{
            if (_presentConifg) {
                _presentConifg();
            }
        }
            break;
            
        case WCInteractiveTransitionTypeDismiss:
            if (_dismissConifg) {
                _dismissConifg();
            } else {
                [_vc dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        case WCInteractiveTransitionTypePush:{
            if (_pushConifg) {
                _pushConifg();
            }
        }
            break;
        case WCInteractiveTransitionTypePop:
            if (_popConifg) {
                _popConifg();
            } else {
                [_vc.navigationController popViewControllerAnimated:YES];
            }
            break;
    }
}

@end
