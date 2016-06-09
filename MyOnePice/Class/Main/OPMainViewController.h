//
//  OPMainViewController.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/5.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OpBaseViewController.h"
#import "WCTransitionsDefine.h"

@interface OPMainViewController : OpBaseViewController<WCAnimationViewControllerDelegate>

- (UIView *)animationView;

@end
