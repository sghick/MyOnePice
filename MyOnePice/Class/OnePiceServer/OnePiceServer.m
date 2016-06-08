//
//  OnePiceServer.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "OnePiceServer.h"


static OnePiceServer *shareInstance = nil;
static dispatch_once_t onceToken;

@interface OnePiceServer ()

@property (strong, nonatomic) NSString *dbPath;

@end

@implementation OnePiceServer

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
        shareInstance.dbPath = [self dbPath];
    });
    return shareInstance;
}

+ (instancetype)shareInstance {
    if (shareInstance == nil) {
        shareInstance = [[super alloc] init];
    }
    return shareInstance;
}

+ (NSString *)dbPath {
    NSString *dbPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath = [paths.firstObject stringByAppendingPathComponent:@"OnePiceServer.sqlite"];
    return dbPath;
}

- (id)requestDataWithUrl:(NSURL *)url params:(NSDictionary *)params {
    SEL selector = NSSelectorFromString([self bussinessUrlKeys][url.absoluteString]);
    if ([self respondsToSelector:@selector(selector)]) {
        return [self performSelector:selector withObject:params withObject:nil];
    }
    return nil;
}

#pragma mark - Bussiness



#pragma mark - private
- (NSDictionary *)bussinessUrlKeys {
    NSDictionary *dict = @{
                           
                           };
    return dict;
}

@end
