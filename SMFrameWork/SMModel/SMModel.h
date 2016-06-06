//
//  SMModel.h
//  Demo-SMFrameWork
//
//  Created by 丁治文 on 15/8/8.
//  Copyright (c) 2015年 buding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSUserDefaults+SMModel.h"

//! Project version number for SMModel.
FOUNDATION_EXPORT double SMModelVersionNumber;

//! Project version string for SMModel.
FOUNDATION_EXPORT const unsigned char SMModelVersionString[];

@interface SMModel : NSObject <
    NSCoding
>

@property (strong, nonatomic) NSArray *allKeys;

- (NSDictionary *)dictionary;
+ (NSDictionary *)dictionaryFormateToString:(NSDictionary *)dict;

+ (instancetype)instanceWithObject:(NSObject *)object;
+ (instancetype)instanceWithArray:(NSArray *)array;
+ (instancetype)instanceWithDictionary:(NSDictionary *)dict;
+ (instancetype)instanceWithDictionary:(NSDictionary *)dict key:(NSString *)key;

+ (NSArray *)arrayWithObject:(NSObject *)object;
+ (NSArray *)arrayWithArray:(NSArray *)array;
+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict;
+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict key:(NSString *)key;

// override for sub class
+ (NSDictionary *)classNameMapper;

#pragma mark - 归档
- (NSData *)data;
+ (NSData *)dataFromModel:(SMModel *)model;
+ (instancetype)modelFromData:(NSData *)data;

@end
