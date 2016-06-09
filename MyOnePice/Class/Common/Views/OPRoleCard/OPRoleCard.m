//
//  OPRoleCard.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/9.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OPRoleCard.h"
#import "PureLayout.h"

const CGFloat _cardWidth = 180;    /**< 卡片的宽/scale */
const CGFloat _cardHeight = 260;   /**< 卡片的高/scale */

@interface OPRoleCard ()

@property (strong, nonatomic) UIButton *backBtn;
@property (assign, nonatomic) BOOL didLoadLayous;

@end

@implementation OPRoleCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backBtn];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (self.didLoadLayous == NO) {
        self.didLoadLayous = YES;
        [self.backBtn autoPinEdgesToSuperviewEdges];
    }
    
    [super updateConstraints];
}

#pragma mark - Actions
- (void)backBtnAction:(UIControl *)sender {
    if ([self.delegate respondsToSelector:@selector(roleCard:didTouchedBtn:)]) {
        [self.delegate roleCard:self didTouchedBtn:sender];
    }
}

#pragma mark - Getters/Setters
- (UIButton *)backBtn {
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = backBtn;
    }
    return _backBtn;
}

+ (CGSize)cardSize {
    CGSize size = CGSizeMake(_cardWidth*SMWidthScale, _cardHeight*SMWidthScale);
    return size;
}

@end
