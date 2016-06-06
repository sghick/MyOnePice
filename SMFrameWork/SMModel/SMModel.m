//
//  SMModel.m
//  Demo-SMFrameWork
//
//  Created by 丁治文 on 15/8/8.
//  Copyright (c) 2015年 buding. All rights reserved.
//

#import "SMModel.h"
#import <objc/runtime.h>

#define __SMToString(a...) ([NSString stringWithFormat:a])


static NSString * parserReturnTypeMainModelOfKey = @"__parserReturnTypeMainModelOfKey__";
static NSString * parserReturnTypeMainArrayOfKey = @"__parserReturnTypeMainArrayOfKey__";

@implementation SMModel

- (NSString *)description{
    return __SMToString(@"%@", self.dictionary);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%s:%@", __func__, key);
}

- (NSDictionary *)dictionary {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    for (NSString *key in self.allKeys) {
        [dict setValue:[self valueForKey:key] forKey:key];
    }
    return dict;
}

- (NSArray *)allKeys {
    if (!_allKeys) {
        NSMutableArray * keys = [NSMutableArray array];
        id classM = objc_getClass([NSStringFromClass([self class]) UTF8String]);
        // i 计数 、  outCount 放我们的属性个数
        unsigned int outCount, i;
        // 反射得到属性的个数
        objc_property_t * properties = class_copyPropertyList(classM, &outCount);
        // 循环 得到属性名称
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            // 获得属性名称
            NSString * attributeName = [NSString stringWithUTF8String:property_getName(property)];
            [keys addObject:attributeName];
        }
        free(properties);
        _allKeys = keys;
    }
    return _allKeys;
}

+ (NSDictionary *)dictionaryFormateToString:(NSDictionary *)dict{
    NSMutableDictionary * rtn = [NSMutableDictionary dictionaryWithDictionary:dict];
    NSArray * keys = [dict allKeys];
    for (NSString * key in keys) {
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
            // 什么也不做
        }
        else{
            [rtn setValue:__SMToString(@"%@", value) forKey:key];
        }
    }
    return rtn;
}

#pragma mark - Dev
+ (instancetype)instanceWithObject:(NSObject *)object {
    if ([object isKindOfClass:[NSArray class]]) {
        return [self instanceWithArray:(NSArray *)object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [self instanceWithDictionary:(NSDictionary *)object];
    } else {
        NSLog(@"错误：数据源是字典和数组以外的类型！");
        return nil;
    }
}

+ (instancetype)instanceWithArray:(NSArray *)array {
    NSDictionary *mapper = [self instanceClassNameMapper];
    SMModel *instance = [[self alloc] init];
    [instance setValuesWithObject:array classNamesMapper:mapper];
    return instance;
}

+ (instancetype)instanceWithDictionary:(NSDictionary *)dict {
    return [self instanceWithDictionary:dict key:nil];
}

+ (instancetype)instanceWithDictionary:(NSDictionary *)dict key:(NSString *)key {
    NSDictionary *mapper = [self instanceClassNameMapper];
    NSDictionary *realDict = key?dict[key]:dict;
    SMModel *instance = [[self alloc] init];
    [instance setValuesWithObject:realDict classNamesMapper:mapper];
    return instance;
}

+ (NSArray *)arrayWithObject:(NSObject *)object {
    if ([object isKindOfClass:[NSArray class]]) {
        return [self arrayWithArray:(NSArray *)object];
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        return [self instanceWithDictionary:(NSDictionary *)object];
    } else {
        NSLog(@"错误：数据源是字典和数组以外的类型！");
        return nil;
    }
}


+ (NSArray *)arrayWithArray:(NSArray *)array {
    NSDictionary *mapper = [self arrayClassNameMapper];
    return [self arrayWithArray:array classNamesMapper:mapper];
}

+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict {
    NSString *realKey = nil;
    if ([dict isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in dict.allKeys) {
            if ([dict[key] isKindOfClass:[NSArray class]]) {
                realKey = key;
                break;
            }
        }
    }
    return [self arrayWithDictionary:dict key:realKey];
}

+ (NSArray *)arrayWithDictionary:(NSDictionary *)dict key:(NSString *)key {
    NSDictionary *mapper = [self arrayClassNameMapper];
    NSArray *array = key?dict[key]:dict;
    return [self arrayWithArray:array classNamesMapper:mapper];
}

#pragma mark - Private

// (private)
- (void)setValuesWithObject:(NSObject *)object classNamesMapper:(NSDictionary *)mapper {
    NSDictionary *dict = (NSDictionary *)object;
    NSDictionary * newDict = [SMModel dictionaryFormateToString:dict];
    [self setValuesForKeysWithDictionary:newDict];
    if (!mapper) {
        return;
    }
    NSMutableArray * keys = [NSMutableArray arrayWithArray:mapper.allKeys];
    [keys removeObject:parserReturnTypeMainArrayOfKey];
    [keys removeObject:parserReturnTypeMainModelOfKey];
    for (NSString * key in keys) {
        NSString * mClass = [mapper objectForKey:key];
        id obj = [dict objectForKey:key];
        if (!obj) {
            continue;
        }
        NSMutableDictionary * curDict = [NSMutableDictionary dictionaryWithDictionary:mapper];
        [curDict removeObjectForKey:key];
        if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray * subModel = [NSMutableArray array];
            for (NSDictionary * subDict in obj) {
                Class modelClass = NSClassFromString(mClass);
                SMModel * model = [[modelClass alloc] init];
                [model setValuesWithObject:subDict classNamesMapper:[modelClass classNameMapper]];
                [subModel addObject:model];
            }
            [self setValue:subModel forKey:key];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            Class modelClass = NSClassFromString(mClass);
            SMModel * model = [[modelClass alloc] init];
            [model setValuesWithObject:obj classNamesMapper:[modelClass classNameMapper]];
            [self setValue:model forKey:key];
        } else {
            NSLog(@"错误：数据源是字典和数组以外的类型！");
        }
    }
}

// (private)
+ (NSArray *)arrayWithArray:(NSArray *)array classNamesMapper:(NSDictionary *)mapper {
    NSMutableArray * rtnArr = [NSMutableArray array];
    Class mainClass = NSClassFromString([mapper objectForKey:parserReturnTypeMainArrayOfKey]);
    if (!mainClass) {
        NSLog(@"错误:未设置key:parserReturnTypeMainArrayOfKey的类名映射！");
        return rtnArr;
    }
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSDictionary *subDict in array) {
            SMModel * model = [[mainClass alloc] init];
            [model setValuesWithObject:subDict classNamesMapper:mapper];
            [rtnArr addObject:model];
        }
    } else {
        NSLog(@"错误：数据源是数组以外的类型！");
    }
    return rtnArr;
}

// (private)
+ (NSMutableDictionary *)instanceClassNameMapper {
    NSMutableDictionary *classMapper = [NSMutableDictionary dictionaryWithDictionary:[self classNameMapper]];
    [classMapper setObject:NSStringFromClass([self class]) forKey:parserReturnTypeMainModelOfKey];
    return classMapper;
}

// (private)
+ (NSMutableDictionary *)arrayClassNameMapper {
    NSMutableDictionary *classMapper = [NSMutableDictionary dictionaryWithDictionary:[self classNameMapper]];
    [classMapper setObject:NSStringFromClass([self class]) forKey:parserReturnTypeMainArrayOfKey];
    return classMapper;
}

+ (NSDictionary *)classNameMapper {
    NSMutableDictionary *mapper = [NSMutableDictionary dictionary];
    NSString *className = NSStringFromClass([self class]);
    // 设置字段/主键
    id classM = objc_getClass([className UTF8String]);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(classM, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *attributeName = [NSString stringWithUTF8String:property_getName(property)];
        NSString *attributeString = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray *attributes = [attributeString componentsSeparatedByString:@","];
        NSString *attributeType = [attributes firstObject];
        NSString *classString = [self smClassStringWithAttributeType:attributeType];
        if (classString) {
            Class cClass = NSClassFromString(classString);
            if ([cClass isSubclassOfClass:[NSArray class]]) {
                
            } else if ([cClass isSubclassOfClass:[SMModel class]]) {
                [mapper setObject:classString forKey:attributeName];
            }
        }
    }
    return mapper;
}

+ (NSString *)smClassStringWithAttributeType:(NSString *)attributeType {
    NSString *reg = @"T@\"";
    NSRange range = [attributeType rangeOfString:reg];
    if (range.location != NSNotFound) {
        NSString *firstMatch = [attributeType substringFromIndex:(range.location + range.length)];
        NSRange range2 = [firstMatch rangeOfString:@"\""];
        NSString *result = [firstMatch substringToIndex:range2.location];
        return result;
    }
    return nil;
}

#pragma mark - 归档
- (NSData *)data {
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return data;
}

+ (NSData *)dataFromModel:(SMModel *)model {
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:model];
    return data;
}

+ (instancetype)modelFromData:(NSData *)data {
    SMModel * model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return model;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSDictionary *dict = self.dictionary;
    for (NSString *key in dict.allKeys) {
        [aCoder encodeObject:dict[key] forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder{;
    for (NSString *key in self.allKeys) {
        id value = [aDecoder decodeObjectForKey:key];
        [self setValue:value forKey:key];
    }
    return self;
}

@end
