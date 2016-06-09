//
//  WPSwipeViewDefine.h
//  AstonMartin
//
//  Created by 丁治文 on 16/6/1.
//  Copyright © 2016年 Buding WeiChe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WPSwipeViewAnimate) {
    WPSwipeViewAnimateNone,     // 无效果
    WPSwipeViewAnimatePoker,    // 扑克效果
    WPSwipeViewAnimateLadder,   // 天梯效果 (向上)
    WPSwipeViewAnimateLadder2,  // 天梯效果2（向右）
    WPSwipeViewAnimateEvenShop, // 平铺效果 (向下)
};

typedef NS_ENUM(NSUInteger, WPSwipeViewDirection) {
    WPSwipeViewDirectionNone = 0,
    WPSwipeViewDirectionLeft = (1 << 0),
    WPSwipeViewDirectionRight = (1 << 1),
    WPSwipeViewDirectionHorizontal = WPSwipeViewDirectionLeft|WPSwipeViewDirectionRight,
    WPSwipeViewDirectionUp = (1 << 2),
    WPSwipeViewDirectionDown = (1 << 3),
    WPSwipeViewDirectionVertical = WPSwipeViewDirectionUp|WPSwipeViewDirectionDown,
    WPSwipeViewDirectionAll = WPSwipeViewDirectionLeft|WPSwipeViewDirectionRight|WPSwipeViewDirectionUp|WPSwipeViewDirectionDown,
};

typedef NS_ENUM(NSInteger, WPTranslucenceState) {
    WPTranslucenceStateAscending = -1L,
    WPTranslucenceStateSame,
    WPTranslucenceStateDescending
};

typedef void(^SwipeViewAnimationCompletionBlock)(NSInteger swipeViewIndex, NSInteger allCount, BOOL completion);
typedef void(^AnimationsBlock)(void);
typedef void(^CompletionBlock)(BOOL completion);
typedef void (^SwipeAnimationBlock)(NSTimeInterval duration, NSTimeInterval delay, AnimationsBlock animations, CompletionBlock completion);
