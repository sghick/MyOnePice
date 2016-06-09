//
//  OPRoleCard.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/9.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPRoleCard;
@protocol OPRoleCardDelegate <NSObject>

- (void)roleCard:(OPRoleCard *)roleCard didTouchedBtn:(UIControl *)sender;

@end

@interface OPRoleCard : UIView

@property (nonatomic, weak  ) id<OPRoleCardDelegate> delegate;

+ (CGSize)cardSize;

@end
