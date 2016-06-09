//
//  WPSwipeView.h
//  WisdomPark
//
//  Created by 丁治文 on 15/4/8.
//  Copyright (c) 2015年 com.wp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WPSwipeViewDefine.h"

@class WPSwipeView;

/// Delegate
@protocol WPSwipeViewDelegate <NSObject>
@optional
- (void)swipeView:(WPSwipeView *)swipeView didSwipeView:(UIView *)view inDirection:(WPSwipeViewDirection)direction;

- (void)swipeView:(WPSwipeView *)swipeView didCancelSwipe:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation;
/** 自定义动画才会调用此方法 */
- (void)swipeView:(WPSwipeView *)swipeView didEndAnimatedCancelSwipe:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation;

- (void)swipeView:(WPSwipeView *)swipeView didStartSwipingView:(UIView *)view atLocation:(CGPoint)location;

- (void)swipeView:(WPSwipeView *)swipeView swipingView:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation;

- (void)swipeView:(WPSwipeView *)swipeView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation;

- (void)swipeView:(WPSwipeView *)swipeView didShowSwipingView:(UIView *)view atIndex:(NSInteger)index;

- (void)swipeView:(WPSwipeView *)swipeView didDismissSwipingView:(UIView *)view atIndex:(NSInteger)index;

- (void)swipeView:(WPSwipeView *)swipeView didLoadSwipingView:(UIView *)view atIndex:(NSInteger)index;

- (void)swipeView:(WPSwipeView *)swipeView didSelectedSwipingView:(UIView *)view atIndex:(NSInteger)index;
/** 是否响应pan手势 */
- (BOOL)swipeView:(WPSwipeView *)swipeView shouldBeginPanGesWhenDirection:(WPSwipeViewDirection)direction;
@end

// DataSource
@protocol WPSwipeViewDataSource <NSObject>

@optional
- (NSInteger)numberOfSwipeView:(WPSwipeView *)swipeView;

/**
 *  刷新view属性用
 *
 *  @param swipeView   本对象
 *  @param refreshView 待刷新的view
 *  @param index       view的index
 */
- (void)swipeView:(WPSwipeView *)swipeView refreshView:(UIView *)refreshView nextViewOfIndex:(NSInteger)index;

@required
- (UIView *)swipeView:(WPSwipeView *)swipeView nextViewOfIndex:(NSInteger)index;

@end

@interface WPSwipeView : UIView

@property (assign, nonatomic) id<WPSwipeViewDataSource> dataSource;

@property (assign, nonatomic) id<WPSwipeViewDelegate> delegate;

// 划出动画
@property (copy, nonatomic) SwipeAnimationBlock swipeOutAnimationBlock;
// 划入动画
@property (copy, nonatomic) SwipeAnimationBlock swipeInAnimationBlock;
// 取消滑动归位动画
@property (copy, nonatomic) SwipeAnimationBlock swipeCancelAnimationBlock;
// 展示动画
@property (copy, nonatomic) SwipeAnimationBlock swipeShowAnimationBlock;

// 允许view跟随手势，默认YES
@property (assign, nonatomic) BOOL isAllowPanGesture;
// 允许view点击手势，默认YES
@property (assign, nonatomic) BOOL isAllowTapGesture;
// 是否允许后面的view旋转，默认YES
@property (assign, nonatomic) BOOL isRotationEnabled;
// view划出的方向，默认支持所有方向
@property (assign, nonatomic) WPSwipeViewDirection direction;
// 是否允许view跟着手势滑动，默认YES  仅支持4个基本方向，并且是单一的方向
@property (assign, nonatomic) BOOL isAllowOffsetInPan;
// 每秒偏移的量
@property (assign, nonatomic) CGFloat escapeVelocityThreshold;
// 相对距离
@property (assign, nonatomic) CGFloat relativeDisplacementThreshold;
// 划出的相对速度
@property (assign, nonatomic) CGFloat pushVelocityMagnitude;
// 初始时加载view的位置
@property (assign, nonatomic) CGPoint swipeViewsCenter;
// 显示时加载view的位置
@property (assign, nonatomic) CGPoint swipeViewsCenterInitial;
// 滑动的view到这个rect中会被销毁
@property (assign, nonatomic) CGRect collisionRect;
// 划出的view的y轴偏移量
@property (assign, nonatomic) CGFloat programaticSwipeRotationRelativeYOffsetFromCenter;
// 一屏最多展示view个数 默认4个
@property (assign, nonatomic) NSInteger numberOfViewsPrefetched;
// 是否循环展示
@property (assign, nonatomic) BOOL isRecycle;

// 动画展示效果
@property (assign, nonatomic) WPSwipeViewAnimate swipeViewAnimate;

/** 动画展示效果 WPSwipeViewAnimatePoker */
// 副view旋转的角度大小
@property (assign, nonatomic) float rotationDegree;
// 副view旋转的偏移量 默认0.3f
@property (assign, nonatomic) float rotationRelativeYOffsetFromCenter;

/** 动画展示效果 WPSwipeViewAnimateLadder/WPSwipeViewAnimateLadder2 */
// 偏移量（天梯效果，默认10）
@property (assign, nonatomic) CGFloat ladderOffset;
// 偏移边距（天梯效果，默认10）
@property (assign, nonatomic) CGFloat ladderMargin;
// 副view的透明度递减/递增/不变
@property (assign, nonatomic) WPTranslucenceState translucenceState;
// 副view的透明度递减/递增的单位，默认0.1
@property (assign, nonatomic) CGFloat translucenceUnit;
// 副view的透明度范围，默认(0, 1)
@property (assign, nonatomic) CGPoint translucenceAlphaRange;

/** 动画展示效果 WPSwipeViewAnimateEvenShop */
// 偏移量 (平铺效果,默认:0)
@property (assign, nonatomic) CGFloat evenShopOffset;

// 划入动画
- (void)setSwipeInAnimationBlock:(SwipeAnimationBlock)swipeInAnimationBlock;
// 划出动画
- (void)setSwipeOutAnimationBlock:(SwipeAnimationBlock)swipeOutAnimationBlock;
// 取消动画
- (void)setSwipeCancelAnimationBlock:(SwipeAnimationBlock)swipeCancelAnimationBlock;
// 展示动画
- (void)setSwipeShowAnimationBlock:(SwipeAnimationBlock)swipeShowAnimationBlock;

// 重新加载view
- (void)reloadData;
// 重新加载view到index
- (void)reloadDataAtIndex:(NSUInteger)index;
// 重新设置view属性
- (void)refreshView;

// 销毁所有view
- (void)discardAllSwipeViews;

// 向左划出
- (void)swipeOutViewToLeft;
// 向右划出
- (void)swipeOutViewToRight;
// 向上划出
- (void)swipeOutViewToUp;
// 向下划出
- (void)swipeOutViewToDown;

// 从上次划出方向划入
- (void)swipeInView;
// 从左划入
- (void)swipeInViewFromLeft;
// 从右划入
- (void)swipeInViewFromRight;
// 从上划入
- (void)swipeInViewFromUp;
// 从下划入
- (void)swipeInViewFromDown;

// 取消当前view滑动, 并返回原处
- (void)swipeCancel;

// 执行动画并回调block
- (void)makeSwipeViewAnimate:(WPSwipeViewAnimate)swipeViewAnimate completionBlock:(SwipeViewAnimationCompletionBlock)completionBlock;

// 从复用队列中取出view，暂时未实现
- (nullable __kindof UIView *)dequeueReusableViewWithIdentifier:(nullable NSString *)identifier;

@end
