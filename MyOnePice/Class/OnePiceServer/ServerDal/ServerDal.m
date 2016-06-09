//
//  ServerDal.m
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import "ServerDal.h"
#import "SMDBManager.h"
#import "SMDBHelper.h"

@implementation ServerDal

+ (NSString *)dbPath {
    NSString *dbPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath = [paths.firstObject stringByAppendingPathComponent:@"OnePiceServer.sqlite"];
    return dbPath;
}

+ (SMDBHelper *)dbHelper {
    return [SMDBManager dbHelperWithDBPath:[self dbPath]];
}

+ (SMServerAccount *)accountWithUserName:(NSString *)userName {
    NSArray *results = [[self dbHelper] searchTable:NSStringFromClass([SMServerAccount class]) modelClass:[SMServerAccount class]];
    return results.firstObject;
}

@end
