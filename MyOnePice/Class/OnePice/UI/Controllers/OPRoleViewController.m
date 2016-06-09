//
//  OPRoleViewController.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/9.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OPRoleViewController.h"

@interface OPRoleViewController ()

@property (strong, nonatomic) UIButton *backBtn;

@end

@implementation OPRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)createSubviews {
    [super createSubviews];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.backBtn];
}

#pragma mark - Notifications
- (void)initNotifications {
    [super initNotifications];
}

#pragma mark - Actions
- (void)backBtnAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

#pragma mark - Getters/Setters
- (UIButton *)backBtn {
    if (_backBtn == nil) {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.backgroundColor = [UIColor greenColor];
        backBtn.frame = CGRectMake(SMScreenWidth - 65*SMWidthScale, 80*SMWidthScale, 50*SMWidthScale, 50*SMWidthScale);
        [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        backBtn.layer.cornerRadius = 25*SMWidthScale;
        _backBtn = backBtn;
    }
    return _backBtn;
}

@end
