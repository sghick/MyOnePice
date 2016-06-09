//
//  WPSwipeView.m
//  WisdomPark
//
//  Created by 丁治文 on 15/4/8.
//  Copyright (c) 2015年 com.wp. All rights reserved.
//

#import "WPSwipeView.h"

WPSwipeViewDirection WPDirectionVectorToSwipeViewDirection(CGVector directionVector) {
    WPSwipeViewDirection direction = WPSwipeViewDirectionNone;
    if (ABS(directionVector.dx) > ABS(directionVector.dy)) {
        if (directionVector.dx > 0) {
            direction = WPSwipeViewDirectionRight;
        } else if (directionVector.dx < 0) {
            direction = WPSwipeViewDirectionLeft;
        }
    } else {
        if (directionVector.dy > 0) {
            direction = WPSwipeViewDirectionDown;
        } else if (directionVector.dy < 0){
            direction = WPSwipeViewDirectionUp;
        }
    }
    return direction;
}

@interface WPSwipeView () <
    UICollisionBehaviorDelegate,
    UIDynamicAnimatorDelegate,
    UIGestureRecognizerDelegate >

// UIDynamicAnimators
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UISnapBehavior *swipeViewSnapBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *swipeViewAttachmentBehavior;
@property (strong, nonatomic) UIAttachmentBehavior *anchorViewAttachmentBehavior;
// AnchorView
@property (strong, nonatomic) UIView *anchorContainerView;
@property (strong, nonatomic) UIView *anchorView;
@property (nonatomic) BOOL isAnchorViewVisible;
// ContainerView
@property (strong, nonatomic) UIView *reuseCoverContainerView;
@property (strong, nonatomic) UIView *containerView;

// 加载的view个数，默认为-1，表未无限制
@property (assign, nonatomic) NSInteger numberOfView;
// 加载的index
@property (assign, nonatomic) NSInteger loadIndex;
// 反向加载的index
@property (assign, nonatomic) NSInteger lastLoadIndex;
// 最近划出的view的方向
@property (assign, nonatomic) CGVector lastDirectionVector;
// 最初移动view时location
@property (assign, nonatomic) CGPoint beginLocation;
// 是否是用户显示取消
@property (assign, nonatomic) BOOL isCustomCancel;
@property (strong, nonatomic) UIView *customCancelView;
// 是否第一次加载 (不作从小变大的动画)
@property (assign, nonatomic) BOOL isReloadData;

@property (assign, nonatomic) BOOL isFirstRecivePan;

@end

@implementation WPSwipeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // 默认4个
    self.numberOfViewsPrefetched = 4;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.animator.delegate = self;
    self.anchorContainerView =
    [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self addSubview:self.anchorContainerView];
    self.isAnchorViewVisible = NO;
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.containerView];
    self.reuseCoverContainerView = [[UIView alloc] initWithFrame:self.bounds];
    self.reuseCoverContainerView.userInteractionEnabled = false;
    [self addSubview:self.reuseCoverContainerView];
    
    // Default properties
    self.isAllowPanGesture = YES;
    self.isAllowTapGesture = YES;
    self.isRotationEnabled = YES;
    self.isAllowOffsetInPan = YES;
    self.rotationDegree = 1;
    self.rotationRelativeYOffsetFromCenter = 0.3;
    self.translucenceState = WPTranslucenceStateSame;
    self.translucenceUnit = 0.1;
    self.translucenceAlphaRange = CGPointMake(0, 1);
    
    self.direction = WPSwipeViewDirectionAll;
    self.pushVelocityMagnitude = 1000;
    self.escapeVelocityThreshold = 750;
    self.relativeDisplacementThreshold = 0.25;
    
    self.programaticSwipeRotationRelativeYOffsetFromCenter = -0.2;
    self.swipeViewsCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.swipeViewsCenterInitial = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.collisionRect = [self defaultCollisionRect];
    
    self.ladderOffset = 10.0f;
    self.ladderMargin = 10.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.anchorContainerView.frame = CGRectMake(0, 0, 1, 1);
    self.containerView.frame = self.bounds;
    self.reuseCoverContainerView.frame = self.bounds;
    self.swipeViewsCenterInitial = CGPointMake(
                                                   self.bounds.size.width/2 + self.swipeViewsCenterInitial.x -
                                                   self.swipeViewsCenter.x,
                                                   self.bounds.size.height/2 + self.swipeViewsCenterInitial.y -
                                                   self.swipeViewsCenter.y
                                               );
    self.swipeViewsCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.collisionRect = [self defaultCollisionRect];
}

- (void)setSwipeViewsCenter:(CGPoint)swipeViewsCenter {
    _swipeViewsCenter = swipeViewsCenter;
    [self animateSwipeViewsIfNeededWithCompletionBlock:nil];
}

#pragma mark - DataSource
- (void)reloadData{
    [self reloadDataAtIndex:0];
}

- (void)reloadDataAtIndex:(NSUInteger)index {
    _isReloadData = YES;
    [self discardAllSwipeViews];
    _numberOfView = -1;
    _loadIndex = index;
    _lastLoadIndex = index - 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSwipeView:)]) {
        _numberOfView = [self.dataSource numberOfSwipeView:self];
    }
    if (_numberOfView > 0) {
        [self loadNextSwipeViewsIfNeeded:NO];
        
        // 回调当前显示的view
        if ([self.delegate respondsToSelector:@selector(swipeView:didShowSwipingView:atIndex:)]) {
            [self.delegate swipeView:self didShowSwipingView:[self topSwipeView] atIndex:self.showIndex];
        }
    }
    _isReloadData = NO;
}

- (void)refreshView {
    if ([self.dataSource respondsToSelector:@selector(swipeView:refreshView:nextViewOfIndex:)]) {
        for (int i = 0; i < self.containerView.subviews.count; i++) {
            [self.dataSource swipeView:self refreshView:self.containerView.subviews[i] nextViewOfIndex:(i+1)];
        }
    }
}

- (void)discardAllSwipeViews {
    [self.animator removeBehavior:self.anchorViewAttachmentBehavior];
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)loadNextSwipeViewsIfNeeded:(BOOL)animated {
    NSInteger numViews = self.containerView.subviews.count;
    NSMutableSet *newViews = [NSMutableSet set];
    for (NSInteger i = numViews; i < self.numberOfViewsPrefetched; i++) {
        UIView *nextView = [self nextSwipeView];
        if (!_isReloadData) {
            nextView.alpha = 0;
            nextView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        }
        if (nextView) {
            [self.containerView addSubview:nextView];
            [self.containerView sendSubviewToBack:nextView];
            nextView.center = self.swipeViewsCenterInitial;
            [newViews addObject:nextView];
        }
    }
    
    if (animated) {
        NSTimeInterval maxDelay = 0.3;
        NSTimeInterval delayStep = maxDelay/self.numberOfViewsPrefetched;
        NSTimeInterval aggregatedDelay = maxDelay;
        NSTimeInterval animationDuration = 0.25;
        for (__weak UIView *view in newViews) {
            view.center = CGPointMake(view.center.x, -view.frame.size.height);
            if (_swipeOutAnimationBlock) {
                _swipeOutAnimationBlock(animationDuration, aggregatedDelay, ^{
                    view.center = self.swipeViewsCenter;
                }, ^(BOOL finished) {
                });
            } else {
                [UIView animateWithDuration:animationDuration delay:aggregatedDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
                    view.center = self.swipeViewsCenter;
                } completion:^(BOOL finished) {
                }];
            }
            aggregatedDelay -= delayStep;
        }
        [self performSelector:@selector(animateSwipeViewsIfNeededWithCompletionBlock:) withObject:nil afterDelay:animationDuration];
    }
    else {
        [self animateSwipeViewsIfNeededWithCompletionBlock:nil];
    }
}

- (void)loadLastSwipeViewsIfNeeded:(BOOL)animated inDirection:(CGVector)directionVector {
    NSMutableSet *newViews = [NSMutableSet set];
    UIView *nextView = [self lastSwipeView];
    if (nextView) {
        [self.containerView addSubview:nextView];
        nextView.center = self.swipeViewsCenterInitial;
        [newViews addObject:nextView];
    }
    NSInteger needRemoveCount = self.containerView.subviews.count - self.numberOfViewsPrefetched;
    for (int i = 0; i < needRemoveCount; i++) {
        [self.containerView.subviews.firstObject removeFromSuperview];
    }
    if (animated) {
        NSTimeInterval maxDelay = 0.0;
        NSTimeInterval delayStep = maxDelay/self.numberOfViewsPrefetched;
        NSTimeInterval aggregatedDelay = maxDelay;
        NSTimeInterval animationDuration = 1.0;
        [self performSelector:@selector(animateSwipeViewsIfNeededWithCompletionBlock:) withObject:nil afterDelay:aggregatedDelay];
        for (__weak UIView *view in newViews) {
            CGVector realVector = [self realVectorFromDirectionVector:directionVector viewSize:view.bounds.size];
            animationDuration = [self animationDurationFromRealDirectionVector:realVector];
            view.center = [self animateCenterFromRealDirectionVector:realVector];
            if (_swipeInAnimationBlock) {
                _swipeInAnimationBlock(animationDuration, aggregatedDelay, ^{
                    view.center = self.swipeViewsCenter;
                }, ^(BOOL finished) {
                });
            } else {
                [UIView animateWithDuration:animationDuration delay:aggregatedDelay options:UIViewAnimationOptionCurveEaseIn animations:^{
                    view.center = self.swipeViewsCenter;
                } completion:^(BOOL finished) {
                }];
            }
            aggregatedDelay -= delayStep;
        }
    }
    else {
        [self animateSwipeViewsIfNeededWithCompletionBlock:nil];
    }
}

// 只有方向
- (CGVector)baseVectorFromDirectionVector:(CGVector)directionVector {
    CGVector baseVector = CGVectorMake(directionVector.dx?(directionVector.dx/fabs(directionVector.dx)):0,
                                       directionVector.dy?(directionVector.dy/fabs(directionVector.dy)):0);
    return baseVector;
}

// 方向+距离
- (CGVector)realVectorFromDirectionVector:(CGVector)directionVector viewSize:(CGSize)viewSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGVector baseVector = [self baseVectorFromDirectionVector:directionVector];
    CGVector realVector = CGVectorMake(baseVector.dx*(fabs(directionVector.dx) + screenSize.width/2.0 + viewSize.width/2.0),
                                       baseVector.dy*(fabs(directionVector.dy) + screenSize.height/2.0 + viewSize.height/2.0));
    return realVector;
}

- (CGPoint)animateCenterFromRealDirectionVector:(CGVector)realDirectionVector {
    CGPoint rtnCenter = CGPointMake(self.swipeViewsCenter.x + realDirectionVector.dx,
                                    self.swipeViewsCenter.y + realDirectionVector.dy);
    return rtnCenter;
}

- (NSTimeInterval)animationDurationFromRealDirectionVector:(CGVector)realDirectionVector {
    NSTimeInterval rtnDuration = sqrtf((realDirectionVector.dx*realDirectionVector.dx + realDirectionVector.dy*realDirectionVector.dy))/self.escapeVelocityThreshold;
    return rtnDuration;
}

- (void)animateSwipeViewsIfNeededWithCompletionBlock:(SwipeViewAnimationCompletionBlock)completionBlock {
    UIView *topSwipeView = [self topSwipeView];
    if (!topSwipeView) {
        return;
    }
    
    for (UIView *cover in self.containerView.subviews) {
        cover.userInteractionEnabled = NO;
    }
    topSwipeView.userInteractionEnabled = YES;
    
    for (UIGestureRecognizer *recognizer in topSwipeView.gestureRecognizers) {
        if (recognizer.state != UIGestureRecognizerStatePossible) {
            return;
        }
    }
    
    if (self.isRotationEnabled) {
        // rotation
        NSUInteger numSwipeViews = self.containerView.subviews.count;
        // 副views的透明度数组
        NSArray *translucences = [self translucencesWithState:_translucenceState unit:_translucenceUnit range:_translucenceAlphaRange numberOfViewsPrefetched:numSwipeViews];
        for (int i = 1; i <= self.numberOfViewsPrefetched; i++) {
            // 刷新动画行为
            [self.animator removeBehavior:self.swipeViewSnapBehavior];
            UIView * topView = self.containerView.subviews[numSwipeViews - 1];
//            self.swipeViewSnapBehavior = [self snapBehaviorThatSnapView:topView toPoint:self.swipeViewsCenter];
            self.swipeViewSnapBehavior = [self snapBehaviorThatSnapView:topView toPoint:topView.center];
            [self.animator addBehavior:self.swipeViewSnapBehavior];
            // 设置view偏移量
            if (numSwipeViews >= i) {
                UIView * view = self.containerView.subviews[numSwipeViews - i];
                CGFloat alpha = 1;
                // 设置透明度
                if ((numSwipeViews - i) < translucences.count) {
                    alpha = ((NSNumber *)translucences[numSwipeViews - i]).floatValue;
                }
                // 效果
                switch (self.swipeViewAnimate) {
                        // 无效果
                    case WPSwipeViewAnimateNone: {
                        CGPoint scalePoint = CGPointMake(1, 1);
                        CGPoint offset = CGPointMake(0, 0);
                        [self ladderView:view atScale:scalePoint atOffsetFromCenter:offset alpha:alpha animated:YES index:i allCount:numSwipeViews completionBlock:completionBlock];
                    }break;
                        // 散布效果
                    case WPSwipeViewAnimatePoker: {
                        CGPoint rotationCenterOffset = {0, CGRectGetHeight(topSwipeView.frame)*self.rotationRelativeYOffsetFromCenter};
                        [self rotateView:view forDegree:self.rotationDegree atOffsetFromCenter:rotationCenterOffset alpha:alpha animated:YES index:i allCount:numSwipeViews completionBlock:completionBlock];
                    }break;
                        // 天梯效果
                    case WPSwipeViewAnimateLadder: {
                        CGFloat scale = 1 - self.ladderMargin/self.frame.size.height*2*(i-1);
                        CGPoint scalePoint = CGPointMake(scale, scale);
                        CGPoint offset = CGPointMake(0, -(self.ladderOffset + self.ladderMargin)*2*(i-1));
                        [self ladderView:view atScale:scalePoint atOffsetFromCenter:offset alpha:alpha animated:YES index:i allCount:numSwipeViews completionBlock:completionBlock];
                    }break;
                        // 天梯效果2
                    case WPSwipeViewAnimateLadder2: {
                        CGFloat scale = 1 - self.ladderMargin/self.frame.size.height*2*(i-1);
                        CGPoint scalePoint = CGPointMake(scale, scale);
                        CGPoint offset = CGPointMake((self.ladderOffset + self.ladderMargin)*2*(i-1), 0);
                        [self ladderView:view atScale:scalePoint atOffsetFromCenter:offset alpha:alpha animated:YES index:i allCount:numSwipeViews completionBlock:completionBlock];
                    }break;
                        // 平铺效果
                    case WPSwipeViewAnimateEvenShop: {
                        CGPoint scalePoint = CGPointMake(1, 1);
                        CGPoint offset = CGPointMake(0, self.evenShopOffset*(i-1));
                        [self ladderView:view atScale:scalePoint atOffsetFromCenter:offset alpha:alpha animated:YES index:i allCount:numSwipeViews completionBlock:completionBlock];
                    }break;
                    default:
                        break;
                }
            }
        }
    }
}

// 获取透明度的数组
- (NSArray *)translucencesWithState:(WPTranslucenceState)state unit:(CGFloat)unit range:(CGPoint)range numberOfViewsPrefetched:(NSInteger)numberOfViewsPrefetched {
    NSMutableArray *rtns = [NSMutableArray array];
    switch (state) {
        case WPTranslucenceStateSame: {
            return rtns;
        }
            break;
        case WPTranslucenceStateAscending: {
            CGFloat alpha = 0;
            CGFloat minAlpha = range.x;
            CGFloat maxAlpha = range.y;
            NSNumber *alphaNumber = nil;
            for (int i = (int)numberOfViewsPrefetched; i > 0; i--) {
                alpha = minAlpha + unit*i;
                if (alpha <= maxAlpha) {
                    alphaNumber = [NSNumber numberWithFloat:alpha];
                } else {
                    alphaNumber = [NSNumber numberWithFloat:maxAlpha];
                }
                [rtns addObject:alphaNumber];
            }
            return rtns;
        }
            break;
        case WPTranslucenceStateDescending: {
            CGFloat alpha = 0;
            CGFloat minAlpha = range.x;
            CGFloat maxAlpha = range.y;
            NSNumber *alphaNumber = nil;
            for (int i = (int)numberOfViewsPrefetched; i > 0; i--) {
                alpha = maxAlpha - unit*(i - 1);
                if (alpha >= minAlpha) {
                    alphaNumber = [NSNumber numberWithFloat:alpha];
                } else {
                    alphaNumber = [NSNumber numberWithFloat:minAlpha];
                }
                [rtns addObject:alphaNumber];
            }
            return rtns;
        }
            break;
            
        default:
            break;
    }
    return rtns;
}

- (CGPoint)realLocationFromLocation:(CGPoint)location direction:(WPSwipeViewDirection)direction inCenter:(CGPoint)inCenter beginLocation:(CGPoint)beginLocation {
    CGPoint realLocation = location;
    switch (direction) {
        case WPSwipeViewDirectionLeft:
        case WPSwipeViewDirectionRight:
        case WPSwipeViewDirectionHorizontal: {
            realLocation = CGPointMake(location.x, inCenter.y);
        }
            break;
        case WPSwipeViewDirectionUp:
        case WPSwipeViewDirectionDown:
        case WPSwipeViewDirectionVertical: {
            realLocation = CGPointMake(inCenter.x, location.y);
        }
            break;
        default:
            break;
    }
    return realLocation;
}

- (CGVector)realDirectionVectorFromDirectionVector:(CGVector)directionVector direction:(WPSwipeViewDirection)direction {
    CGVector realVector = directionVector;
    switch (direction) {
        case WPSwipeViewDirectionLeft:
        case WPSwipeViewDirectionRight:
        case WPSwipeViewDirectionHorizontal: {
            realVector = CGVectorMake(directionVector.dx, 0);
        }
            break;
        case WPSwipeViewDirectionUp:
        case WPSwipeViewDirectionDown:
        case WPSwipeViewDirectionVertical: {
            realVector = CGVectorMake(0, directionVector.dy);
        }
            break;
        default:
            break;
    }
    return realVector;
}

#pragma mark - Action
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self];
    CGPoint location = [recognizer locationInView:self];
    CGPoint realLocation = location;
    UIView *swipeView = recognizer.view;
    if (_isAllowOffsetInPan == NO) {
        realLocation = [self realLocationFromLocation:location direction:_direction inCenter:_swipeViewsCenter beginLocation:_beginLocation];
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _beginLocation = location;
        [self createAnchorViewForCover:swipeView atLocation:realLocation shouldAttachAnchorViewToPoint:YES];
        if ([self.delegate respondsToSelector:@selector(swipeView:didStartSwipingView:atLocation:)]) {
            [self.delegate swipeView:self didStartSwipingView:swipeView atLocation:realLocation];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        self.anchorViewAttachmentBehavior.anchorPoint = realLocation;
        if ([self.delegate respondsToSelector:@selector(swipeView:swipingView:atLocation:translation:)]) {
            [self.delegate swipeView:self swipingView:swipeView atLocation:realLocation translation:translation];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];
        CGFloat velocityMagnitude = sqrtf(powf(velocity.x, 2) + powf(velocity.y, 2));
        CGPoint normalizedVelocity = CGPointMake(velocity.x / velocityMagnitude, velocity.y / velocityMagnitude);
        CGFloat scale = velocityMagnitude > self.escapeVelocityThreshold ? velocityMagnitude : self.pushVelocityMagnitude;
        CGFloat translationMagnitude = sqrtf(translation.x * translation.x + translation.y * translation.y);
        CGVector directionVector = CGVectorMake(
                                                translation.x / translationMagnitude * scale,
                                                translation.y / translationMagnitude * scale
                                                );
        
        if ((WPDirectionVectorToSwipeViewDirection(directionVector) & self.direction) > 0 &&
            (ABS(translation.x) > self.relativeDisplacementThreshold * self.bounds.size.width || // displacement
             velocityMagnitude > self.escapeVelocityThreshold) && // velocity
            (signum(translation.x) == signum(normalizedVelocity.x)) && // sign X
            (signum(translation.y) == signum(normalizedVelocity.y)) // sign Y
            ) {
            CGVector realDirectionVector = directionVector;
            if (_isAllowOffsetInPan == NO) {
                realDirectionVector = [self realDirectionVectorFromDirectionVector:directionVector direction:_direction];
            }
            [self pushAnchorViewForCover:swipeView inDirection:realDirectionVector andCollideInRect:self.collisionRect];
        } else {
            [self.animator removeBehavior:self.swipeViewAttachmentBehavior];
            [self.animator removeBehavior:self.anchorViewAttachmentBehavior];
            [self.anchorView removeFromSuperview];
            
            // 恢复手势
            if (_isCustomCancel && _customCancelView) {
                [self gesEnable];
            } else {
                if (_swipeCancelAnimationBlock) {
                    _swipeCancelAnimationBlock(0.35, 0, ^{
                        swipeView.center = self.swipeViewsCenter;
                    }, ^(BOOL finished) {
                        if (finished && [self.delegate respondsToSelector:@selector(swipeView:didEndAnimatedCancelSwipe:atLocation:translation:)]) {
                            [self.delegate swipeView:self didEndAnimatedCancelSwipe:swipeView atLocation:realLocation translation:translation];
                        }
                    });
                } else {
                    self.swipeViewSnapBehavior = [self snapBehaviorThatSnapView:swipeView toPoint:self.swipeViewsCenter];
                    [self.animator addBehavior:self.swipeViewSnapBehavior];
                }
                
                if ([self.delegate respondsToSelector:@selector(swipeView:didCancelSwipe:atLocation:translation:)]) {
                    [self.delegate swipeView:self didCancelSwipe:swipeView atLocation:realLocation translation:translation];
                }
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(swipeView:didEndSwipingView:atLocation:translation:)]) {
            [self.delegate swipeView:self didEndSwipingView:swipeView atLocation:realLocation translation:translation];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(swipeView:didSelectedSwipingView:atIndex:)]) {
        [self.delegate swipeView:self didSelectedSwipingView:[self topSwipeView] atIndex:self.showIndex];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (_isFirstRecivePan == YES) {
        _isFirstRecivePan = NO;
        if (_isAllowOffsetInPan == NO) {
            CGPoint absLocation = CGPointMake(_beginLocation.x - location.x, _beginLocation.y - location.y);
            WPSwipeViewDirection direction = WPDirectionVectorToSwipeViewDirection(CGVectorMake(absLocation.x, absLocation.y));
            BOOL shouldBegin = YES;
            if ([self.delegate respondsToSelector:@selector(swipeView:shouldBeginPanGesWhenDirection:)]) {
                shouldBegin = [self.delegate swipeView:self shouldBeginPanGesWhenDirection:direction];
            }
            return shouldBegin;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint location = [touch locationInView:gestureRecognizer.view];
    _beginLocation = location;
    _isFirstRecivePan = YES;
    return YES;
}

#pragma mark - swipe out
- (void)swipeOutViewToLeft {
    [self swipeOutViewToLeft:YES];
}

- (void)swipeOutViewToRight {
    [self swipeOutViewToLeft:NO];
}

- (void)swipeOutViewToUp {
    [self swipeOutViewToUp:YES];
}

- (void)swipeOutViewToDown {
    [self swipeOutViewToUp:NO];
}

#pragma mark - swipe in
- (void)swipeInView {
    [self swipeInViewFromLastDirection];
}

- (void)swipeInViewFromLeft {
    [self swipeInViewFromLeft:YES];
}

- (void)swipeInViewFromRight {
    [self swipeInViewFromLeft:NO];
}

- (void)swipeInViewFromUp {
    [self swipeInViewFromUp:YES];
}

- (void)swipeInViewFromDown {
    [self swipeInViewFromUp:NO];
}

#pragma mark - swipe
- (void)swipeOutViewToLeft:(BOOL)left {
    UIView *topSwipeView = [self topSwipeView];
    if (!topSwipeView) {
        return;
    }
    
    CGPoint location = CGPointMake(
                                   topSwipeView.center.x,
                                   topSwipeView.center.y*(1 + self.programaticSwipeRotationRelativeYOffsetFromCenter)
                                   );
    [self createAnchorViewForCover:topSwipeView atLocation:location shouldAttachAnchorViewToPoint:YES];
    CGVector direction = CGVectorMake((left ? -1 : 1) * self.escapeVelocityThreshold, 0);
    [self pushAnchorViewForCover:topSwipeView inDirection:direction andCollideInRect:self.collisionRect];
}

- (void)swipeOutViewToUp:(BOOL)up {
    UIView *topSwipeView = [self topSwipeView];
    if (!topSwipeView) {
        return;
    }
    
    CGPoint location = CGPointMake(
                                   topSwipeView.center.x,
                                   topSwipeView.center.y*(1 + self.programaticSwipeRotationRelativeYOffsetFromCenter)
                                   );
    [self createAnchorViewForCover:topSwipeView atLocation:location shouldAttachAnchorViewToPoint:YES];
    CGVector direction = CGVectorMake(0, (up ? -1 : 1) * self.escapeVelocityThreshold);
    [self pushAnchorViewForCover:topSwipeView inDirection:direction andCollideInRect:self.collisionRect];
}

- (void)swipeInViewFromLastDirection {
    CGVector direction = CGVectorMake(0, 0);
    [self popAnchorViewInDirection:direction];
}

- (void)swipeInViewFromLeft:(BOOL)left {
    CGVector direction = CGVectorMake((left ? -1 : 1), 0);
    [self popAnchorViewInDirection:direction];
}

- (void)swipeInViewFromUp:(BOOL)up {
    CGVector direction = CGVectorMake(0, (up ? -1 : 1));
    [self popAnchorViewInDirection:direction];
}

- (void)swipeCancel {
    UIView *topView = [self topSwipeView];
    NSArray *gess = topView.gestureRecognizers;
    for (UIGestureRecognizer *ges in gess) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = NO;
            _isCustomCancel = YES;
            _customCancelView = topView;
            break;
        }
    }
}

- (void)gesEnable {
    NSArray *gess = _customCancelView.gestureRecognizers;
    for (UIGestureRecognizer *ges in gess) {
        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
            ges.enabled = YES;
            _isCustomCancel = NO;
            break;
        }
    }
}

- (void)makeSwipeViewAnimate:(WPSwipeViewAnimate)swipeViewAnimate completionBlock:(SwipeViewAnimationCompletionBlock)completionBlock {
    _swipeViewAnimate = swipeViewAnimate;
    [self animateSwipeViewsIfNeededWithCompletionBlock:completionBlock];
}

#pragma mark - UIDynamicAnimationHelpers

- (UICollisionBehavior *)collisionBehaviorThatBoundsView:(UIView *)view inRect:(CGRect)rect {
    if (!view) {
        return nil;
    }
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[view]];
    UIBezierPath *collisionBound = [UIBezierPath bezierPathWithRect:rect];
    [collisionBehavior addBoundaryWithIdentifier:@"coll" forPath:collisionBound];
    [collisionBehavior setCollisionMode:UICollisionBehaviorModeBoundaries];
    return collisionBehavior;
}

- (UIPushBehavior *)pushBehaviorThatPushView:(UIView *)view toDirection:(CGVector)direction {
    if (!view) {
        return nil;
    }
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[view] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.pushDirection = direction;
    return pushBehavior;
}

- (UISnapBehavior *)snapBehaviorThatSnapView:(UIView *)view toPoint:(CGPoint)point {
    if (!view) {
        return nil;
    }
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:view snapToPoint:point];
    snapBehavior.damping = 0.75f;
    return snapBehavior;
}

- (UIAttachmentBehavior *)attachmentBehaviorThatAnchorsView:(UIView *)aView toView:(UIView *)anchorView {
    if (!aView) {
        return nil;
    }
    CGPoint anchorPoint = anchorView.center;
    CGPoint p = [self convertPoint:aView.center toView:self];
    UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc]
                                        initWithItem:aView
                                        offsetFromCenter:UIOffsetMake(-(p.x - anchorPoint.x), -(p.y - anchorPoint.y))
                                        attachedToItem:anchorView
                                        offsetFromCenter:UIOffsetMake(0, 0)
                                        ];
    attachment.length = 0;
    return attachment;
}

- (UIAttachmentBehavior *)attachmentBehaviorThatAnchorsView:(UIView *)aView toPoint:(CGPoint)aPoint {
    if (!aView) {
        return nil;
    }
    
    CGPoint p = aView.center;
    UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc]
                                                initWithItem:aView
                                                offsetFromCenter:UIOffsetMake(-(p.x - aPoint.x), -(p.y - aPoint.y))
                                                attachedToAnchor:aPoint
                                                ];
    attachmentBehavior.damping = 100;
    attachmentBehavior.length = 0;
    return attachmentBehavior;
}

- (void)createAnchorViewForCover:(UIView *)swipeView atLocation:(CGPoint)location shouldAttachAnchorViewToPoint:(BOOL)shouldAttachToPoint {
    [self.animator removeBehavior:self.swipeViewSnapBehavior];
    self.swipeViewSnapBehavior = nil;
    
    self.anchorView =
    [[UIView alloc] initWithFrame:CGRectMake(location.x - 500, location.y - 500, 1000, 1000)];
    [self.anchorView setBackgroundColor:[UIColor blueColor]];
    [self.anchorView setHidden:!self.isAnchorViewVisible];
    [self.anchorContainerView addSubview:self.anchorView];
    UIAttachmentBehavior *attachToView = [self attachmentBehaviorThatAnchorsView:swipeView toView:self.anchorView];
    [self.animator addBehavior:attachToView];
    self.swipeViewAttachmentBehavior = attachToView;
    
    if (shouldAttachToPoint) {
        UIAttachmentBehavior *attachToPoint = [self attachmentBehaviorThatAnchorsView:self.anchorView toPoint:location];
        [self.animator addBehavior:attachToPoint];
        self.anchorViewAttachmentBehavior = attachToPoint;
    }
}

- (void)pushAnchorViewForCover:(UIView *)swipeView inDirection:(CGVector)directionVector andCollideInRect:(CGRect)collisionRect {
    WPSwipeViewDirection direction = WPDirectionVectorToSwipeViewDirection(directionVector);
    _lastDirectionVector = directionVector;
    if ([self.delegate respondsToSelector:@selector(swipeView:didSwipeView:inDirection:)]) {
        [self.delegate swipeView:self didSwipeView:swipeView inDirection:direction];
    }
    
    [self.animator removeBehavior:self.anchorViewAttachmentBehavior];
    
    UICollisionBehavior *collisionBehavior = [self collisionBehaviorThatBoundsView:self.anchorView inRect:collisionRect];
    collisionBehavior.collisionDelegate = self;
    [self.animator addBehavior:collisionBehavior];
    
    UIPushBehavior *pushBehavior = [self pushBehaviorThatPushView:self.anchorView toDirection:directionVector];
    [self.animator addBehavior:pushBehavior];
    
    [self.reuseCoverContainerView addSubview:self.anchorView];
    [self.reuseCoverContainerView addSubview:swipeView];
    [self.reuseCoverContainerView sendSubviewToBack:swipeView];
    
    self.anchorView = nil;
    [self loadNextSwipeViewsIfNeeded:NO];
    // 回调即将不显示的view
    if ([self.delegate respondsToSelector:@selector(swipeView:didDismissSwipingView:atIndex:)]) {
        [self.delegate swipeView:self didDismissSwipingView:[self topSwipeView] atIndex:self.showReloadIndex];
    }
    // 同步索引
    _lastLoadIndex = _loadIndex - self.containerView.subviews.count - 1;
    // 回调当前显示的view
    if ([self.delegate respondsToSelector:@selector(swipeView:didShowSwipingView:atIndex:)]) {
        [self.delegate swipeView:self didShowSwipingView:[self topSwipeView] atIndex:self.showIndex];
    }
}

- (void)popAnchorViewInDirection:(CGVector)directionVector {
    // 如果directionVector没有方向，刚取上一次方向
    WPSwipeViewDirection lastDirection = WPDirectionVectorToSwipeViewDirection(directionVector);
    CGVector lastDirectionVector = [self baseVectorFromDirectionVector:directionVector];
    if (lastDirection == WPSwipeViewDirectionNone) {
        lastDirectionVector = [self baseVectorFromDirectionVector:_lastDirectionVector];
    }
    
    [self loadLastSwipeViewsIfNeeded:YES inDirection:lastDirectionVector];
    // 回调即将不显示的view
    if ([self.delegate respondsToSelector:@selector(swipeView:didDismissSwipingView:atIndex:)]) {
        [self.delegate swipeView:self didDismissSwipingView:[self topSwipeView] atIndex:self.showIndex];
    }
    // 同步索引
    _loadIndex = _lastLoadIndex + self.containerView.subviews.count + 1;
    // 回调当前显示的view
    if ([self.delegate respondsToSelector:@selector(swipeView:didShowSwipingView:atIndex:)]) {
        [self.delegate swipeView:self didShowSwipingView:[self topSwipeView] atIndex:self.showIndex];
    }
}

#pragma mark - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier {
    NSMutableSet *viewsToRemove = [[NSMutableSet alloc] init];
    
    for (id aBehavior in self.animator.behaviors) {
        if ([aBehavior isKindOfClass:[UIAttachmentBehavior class]]) {
            NSArray *items = ((UIAttachmentBehavior *) aBehavior).items;
            if ([items containsObject:item]) {
                [self.animator removeBehavior:aBehavior];
                [viewsToRemove addObjectsFromArray:items];
            }
        }
        if ([aBehavior isKindOfClass:[UIPushBehavior class]]) {
            NSArray *items = ((UIPushBehavior *) aBehavior).items;
            if ([((UIPushBehavior *) aBehavior).items containsObject:item]) {
                if ([items containsObject:item]) {
                    [self.animator removeBehavior:aBehavior];
                    [viewsToRemove addObjectsFromArray:items];
                }
            }
        }
        if ([aBehavior isKindOfClass:[UICollisionBehavior class]]) {
            NSArray *items = ((UICollisionBehavior *) aBehavior).items;
            if ([((UICollisionBehavior *) aBehavior).items containsObject:item]) {
                if ([items containsObject:item]) {
                    [self.animator removeBehavior:aBehavior];
                    [viewsToRemove addObjectsFromArray:items];
                }
            }
        }
    }
    
    for (UIView *view in viewsToRemove) {
        for (UIGestureRecognizer *aGestureRecognizer in view.gestureRecognizers) {
            if ([aGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                [view removeGestureRecognizer:aGestureRecognizer];
            }
        }
        [view removeFromSuperview];
    }
}

#pragma mark - 复用
- (nullable UIView *)dequeueReusableViewWithIdentifier:(nullable NSString *)identifier {
    return nil;
}

#pragma mark - 效果自定义
// 扑克散布效果
- (void)rotateView:(UIView *)view
         forDegree:(float)degree
atOffsetFromCenter:(CGPoint)offset
             alpha:(CGFloat)alpha
          animated:(BOOL)animated
             index:(NSInteger)index
          allCount:(NSInteger)allCount
   completionBlock:(SwipeViewAnimationCompletionBlock)completionBlock {
    float duration = animated ? 0.4 : 0;
    float rotationRadian = [self degreesToRadians:degree];
    
    if (self.swipeShowAnimationBlock) {
        self.swipeShowAnimationBlock(duration, 0, ^{
            view.center = self.swipeViewsCenter;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
            transform = CGAffineTransformRotate(transform, rotationRadian);
            transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y);
            view.transform = transform;
            view.alpha = alpha;
        }, ^(BOOL finished) {
            if (completionBlock) {
                completionBlock(index, allCount, finished);
            }
        });
    } else {
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            view.center = self.swipeViewsCenter;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
            transform = CGAffineTransformRotate(transform, rotationRadian);
            transform = CGAffineTransformTranslate(transform, -offset.x, -offset.y);
            view.transform = transform;
            view.alpha = alpha;
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock(index, allCount, finished);
            }
        }];
    }
}

// 梯形效果
- (void)ladderView:(UIView *)view
           atScale:(CGPoint)scale
atOffsetFromCenter:(CGPoint)offset
             alpha:(CGFloat)alpha
          animated:(BOOL)animated
             index:(NSInteger)index
          allCount:(NSInteger)allCount
   completionBlock:(SwipeViewAnimationCompletionBlock)completionBlock {
    float duration = animated ? 0.4 : 0;
    
    if (self.swipeShowAnimationBlock) {
        self.swipeShowAnimationBlock(duration, 0, ^{
            view.center = self.swipeViewsCenter;
            CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
            transform = CGAffineTransformTranslate(transform, offset.x, offset.y);
            transform = CGAffineTransformScale(transform, scale.x, scale.y);
            view.transform = transform;
            view.alpha = alpha;
        }, ^(BOOL finished) {
            if (completionBlock) {
                completionBlock(index, allCount, finished);
            }
        });
    } else {
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
            transform = CGAffineTransformTranslate(transform, offset.x, offset.y);
            transform = CGAffineTransformScale(transform, scale.x, scale.y);
            view.transform = transform;
            view.alpha = alpha;
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock(index, allCount, finished);
            }
        }];
    }
}

- (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * M_PI/180.0f;
}

- (CGFloat)radiansToDegrees:(CGFloat)radians {
    return radians * 180.0f/M_PI;
}

int signum(CGFloat n) {
    return (n < 0) ? -1 : (n > 0) ? +1 : 0;
}

- (CGRect)defaultCollisionRect {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    CGFloat collisionSizeScale = 6;
    CGSize collisionSize = CGSizeMake(viewSize.width*collisionSizeScale, viewSize.height* collisionSizeScale);
    CGRect collisionRect = CGRectMake(-collisionSize.width/2 + viewSize.width/2, -collisionSize.height/2 + viewSize.height/2, collisionSize.width, collisionSize.height);
    return collisionRect;
}

- (UIView *)nextSwipeView {
    UIView *nextView = nil;
    // 循环展示
    if (_isRecycle) {
        _loadIndex = _loadIndex%_numberOfView;
    }
    // 加载
    if ((_numberOfView == -1) || (_numberOfView > _loadIndex)) {
        // 加载swipingView
        if ([self.dataSource respondsToSelector:@selector(swipeView:nextViewOfIndex:)]) {
            nextView = [self.dataSource swipeView:self nextViewOfIndex:_loadIndex];
        }
        // 添加手势
        if (nextView) {
            // 添加滑动手势
            if (self.isAllowPanGesture) {
                UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
                ges.delegate = self;
                [nextView addGestureRecognizer:ges];
            }
            // 添加轻击手势
            if (self.isAllowTapGesture) {
                [nextView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
            }
            // 加载swipingView成功
            if ([self.delegate respondsToSelector:@selector(swipeView:didLoadSwipingView:atIndex:)]) {
                [self.delegate swipeView:self didLoadSwipingView:nextView atIndex:_loadIndex];
            }
            // 增加索引
            _loadIndex++;
        }
    }
    return nextView;
}

- (UIView *)lastSwipeView {
    UIView *lastView = nil;
    // 循环展示
    if (_isRecycle) {
        _lastLoadIndex = (_numberOfView + _lastLoadIndex)%_numberOfView;
    }
    // 加载
    if ((_numberOfView == -1) || (_lastLoadIndex >= 0)) {
        // 加载swipingView
        if ([self.dataSource respondsToSelector:@selector(swipeView:nextViewOfIndex:)]) {
            lastView = [self.dataSource swipeView:self nextViewOfIndex:_lastLoadIndex];
        }
        // 添加手势
        if (lastView) {
            // 添加滑动手势
            if (self.isAllowPanGesture) {
                UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
                ges.delegate = self;
                [lastView addGestureRecognizer:ges];
            }
            // 添加轻击手势
            if (self.isAllowTapGesture) {
                [lastView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)]];
            }
            // 加载swipingView成功
            if ([self.delegate respondsToSelector:@selector(swipeView:didLoadSwipingView:atIndex:)]) {
                [self.delegate swipeView:self didLoadSwipingView:lastView atIndex:_lastLoadIndex];
            }
            // 增加索引
            _lastLoadIndex--;
        }
    }
    return lastView;
}

- (UIView *)topSwipeView {
    return self.containerView.subviews.lastObject;
}

#pragma mark - getters/setters
- (NSInteger)showIndex{
    NSUInteger numSwipeViews = self.containerView.subviews.count;
    numSwipeViews = (numSwipeViews <=_loadIndex) ? numSwipeViews : (numSwipeViews - _numberOfView);
    NSInteger index =  (_loadIndex - numSwipeViews);
    return index;
}

- (NSInteger)showReloadIndex {
    NSUInteger numSwipeViews = self.containerView.subviews.count;
    NSInteger index = _loadIndex;
    if (index >= 0) {
        return index;
    } else {
        return numSwipeViews - index;
    }
}

- (void)setDataSource:(id <WPSwipeViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (void)setSwipeViewAnimate:(WPSwipeViewAnimate)swipeViewAnimate {
    _swipeViewAnimate = swipeViewAnimate;
    [self animateSwipeViewsIfNeededWithCompletionBlock:nil];
}

@end

