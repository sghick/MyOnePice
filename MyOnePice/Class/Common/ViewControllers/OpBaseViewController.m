//
//  OpBaseViewController.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/4.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OpBaseViewController.h"
#import "SMLog.h"

@interface OpBaseViewController ()

@end

@implementation OpBaseViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(initNotifications)]) {
            [self initNotifications];
        }
    }
    return self;
}

- (void)initNotifications {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SMLog1(SMLogTypeCmd|SMLogTypeFile, @"控制器:%@ 释放成功", [self class]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSubviews];
}

- (void)createSubviews {
    
}

@end
