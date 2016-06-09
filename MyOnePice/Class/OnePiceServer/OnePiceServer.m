//
//  OnePiceServer.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OnePiceServer.h"
#import "SMServerModel.h"
#import "ServerDal.h"

static OnePiceServer *shareInstance = nil;
static dispatch_once_t onceToken;

@interface OnePiceServer ()

@end

@implementation OnePiceServer

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
    });
    return shareInstance;
}

+ (instancetype)shareInstance {
    if (shareInstance == nil) {
        shareInstance = [[super alloc] init];
    }
    return shareInstance;
}

- (id)requestDataWithUrl:(NSURL *)url params:(NSDictionary *)params {
    SEL selector = NSSelectorFromString([self bussinessUrlKeys][url.absoluteString]);
    if ([self respondsToSelector:@selector(selector)]) {
        return [self performSelector:selector withObject:params withObject:nil];
    }
    return nil;
}

#pragma mark - Bussiness
- (NSDictionary *)bs_account:(NSDictionary *)params {
    NSString *userName = params[@"user_name"];
    SMServerAccount *account = [ServerDal accountWithUserName:userName];
    if (account) {
        return account.dictionary;
    } else {
        return nil;  
    }
}

#pragma mark - private
- (NSDictionary *)bussinessUrlKeys {
    NSDictionary *dict = @{
                           @"/doc/account":@"bs_account:"
                           };
    return dict;
}

@end
