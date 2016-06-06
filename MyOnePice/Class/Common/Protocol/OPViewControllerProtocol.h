//
//  OPViewControllerProtocol.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/5.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OPViewControllerProtocol <NSObject>

@required
- (void)createSubviews;

@optional
- (void)initNotifications;

@end
