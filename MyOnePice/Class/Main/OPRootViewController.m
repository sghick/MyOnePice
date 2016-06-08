//
//  OPRootViewController.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/4.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OPRootViewController.h"
#import "OPNavigationController.h"
#import "OPMainViewController.h"
#import "OPMeViewController.h"
#import "OPCarbonViewController.h"

@interface OPRootViewController ()

@end

@implementation OPRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addViewControllers];
}

- (void)addViewControllers {
    OPMainViewController *vc1 = [[OPMainViewController alloc] init];
    OPNavigationController *nav1 = [[OPNavigationController alloc] initWithRootViewController:vc1];
    nav1.tabBarItem.title = @"主页";
    
    OPMeViewController *vc2 = [[OPMeViewController alloc] init];
    OPNavigationController *nav2 = [[OPNavigationController alloc] initWithRootViewController:vc2];
    nav2.tabBarItem.title = @"我的";
    
    OPCarbonViewController *vc3 = [[OPCarbonViewController alloc] init];
    OPNavigationController *nav3 = [[OPNavigationController alloc] initWithRootViewController:vc3];
    nav3.tabBarItem.title = @"副本";
    
    NSArray *vcs = @[nav1, nav2, nav3];
    self.viewControllers = vcs;
}

@end
