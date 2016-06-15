//
//  OPMeViewController.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/5.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OPMeViewController.h"
#import "WPSwipeView.h"
#import "OPRoleCard.h"
#import "OPModel.h"
#import "WCTransitions.h"
#import "OPRoleViewController.h"

static NSString *swipeViewIdentifier = @"vehicleViewIdentifier";

@interface OPMeViewController () <
    OPRoleCardDelegate,
    WPSwipeViewDataSource,
    WPSwipeViewDelegate >

@property (strong, nonatomic) WPSwipeView *swipeView;
@property (strong, nonatomic) NSArray<OPPlayerRole *> *roles;
@property (strong, nonatomic) WCTransitioningDelegate *transDelegate;

@end

@implementation OPMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createSubviews {
    [super createSubviews];
    self.view.backgroundColor = [UIColor brownColor];
    
    [self.view addSubview:self.swipeView];
    
#warning by dingzhiwen test
    self.roles = @[@"a",@"b",@"c",@"d"];
    [self.swipeView reloadData];
}

#pragma mark - Notifications
- (void)initNotifications {
    [super initNotifications];
}

#pragma mark - OPRoleCardDelegate
- (void)roleCard:(OPRoleCard *)roleCard didTouchedBtn:(UIButton *)sender {
    OPRoleViewController *vc = [[OPRoleViewController alloc] init];
    [self.transDelegate setFromViewController:self toViewController:vc];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self.transDelegate;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - WPSwipeViewDataSource, WPSwipeViewDelegate
- (NSInteger)numberOfSwipeView:(WPSwipeView *)swipeView {
    return self.roles.count;
}

- (UIView *)swipeView:(WPSwipeView *)swipeView nextViewOfIndex:(NSInteger)index {
    OPRoleCard *view = [swipeView dequeueReusableViewWithIdentifier:swipeViewIdentifier];
    if (view == nil) {
        view = [[OPRoleCard alloc] initWithFrame:swipeView.bounds];
    }
    view.delegate = self;
    return view;
}

- (void)swipeView:(WPSwipeView *)swipeView didShowSwipingView:(UIView *)view atIndex:(NSInteger)index {
    // 设置卡片总数和当前数 (index + 1):self.roles.count
}

#pragma mark - WCAnimationViewControllerDelegate
- (UIView *)animationView {
    return self.swipeView;
}

#pragma mark - Actions

#pragma mark - Utils

#pragma mark - Getters/Setters
- (WPSwipeView *)swipeView {
    if (_swipeView == nil) {
        WPSwipeView *swipeView = [[WPSwipeView alloc] initWithFrame:CGRectMake((SMScreenWidth - [OPRoleCard cardSize].width)/2,
                                                                               120*SMWidthScale,
                                                                               [OPRoleCard cardSize].width,
                                                                               [OPRoleCard cardSize].height)];
        swipeView.programaticSwipeRotationRelativeYOffsetFromCenter = 0;
        swipeView.translucenceState = WPTranslucenceStateDescending;
        swipeView.translucenceUnit = 0.2;
        swipeView.swipeViewAnimate = WPSwipeViewAnimateLadder;
        swipeView.direction = WPSwipeViewDirectionAll;
        swipeView.numberOfViewsPrefetched = 5;
        swipeView.ladderOffset = 2*SMWidthScale;
        swipeView.ladderMargin = 4*SMWidthScale;
        swipeView.evenShopOffset = [OPRoleCard cardSize].height + 20*SMWidthScale;
        swipeView.isRecycle = YES;
        swipeView.dataSource = self;
        swipeView.delegate = self;
        
        _swipeView = swipeView;
    }
    return _swipeView;
}

- (WCTransitioningDelegate *)transDelegate {
    if (_transDelegate == nil) {
        _transDelegate = [WCTransitionManager transitionForTransDelegate2];
    }
    return _transDelegate;
}

@end
