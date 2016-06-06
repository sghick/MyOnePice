//
//  SMUrlRequest.m
//  Demo-SMFrameWork
//
//  Created by 丁治文 on 15/8/8.
//  Copyright (c) 2015年 buding. All rights reserved.
//

#import "SMUrlRequest.h"
#import <CommonCrypto/CommonDigest.h>

#define __SMToString(a...) ([NSString stringWithFormat:a])

@implementation SMUrlRequestParamFile

+ (instancetype)paramFileWithData:(NSData *)data paramName:(NSString *)paramName fileName:(NSString *)fileName mimeType:(NSString *)mimeType{
    SMUrlRequestParamFile * file = [[SMUrlRequestParamFile alloc] init];
    file.data = data;
    file.paramName = paramName;
    file.fileName = fileName;
    file.mimeType = mimeType;
    return file;
}

@end

// 作为userInfo的key
#define KEY_ASI_HTTP_REQUEST_KEY @"__KEY_ASI_HTTP_REQUEST_KEY__"
// 缓存文件夹的路径
static NSString *docListStr = @"";

@interface SMUrlRequest ()

@end

@implementation SMUrlRequest

#pragma mark - SMUrlRequest

- (id)init{
    self = [super init];
    if (self) {
        [self initRequestWithUrl:nil];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super initWithURL:URL];
    if (self) {
        [self initRequestWithUrl:URL];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    self = [super initWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    if (self) {
        [self initRequestWithUrl:URL];
    }
    return self;
}

- (void)initRequestWithUrl:(NSURL *)URL {
    // 设置默认请求方法
    _requestMethod = requestMethodGet;
    // 初始化参数
    _paramsFiles = [NSMutableArray array];
    _paramsDict = [NSMutableDictionary dictionary];
    _parserMapper = [NSMutableDictionary dictionary];
    _parserKeysMapper = [NSMutableDictionary dictionary];
    if (URL) {
        _urlString = URL.absoluteString;
    }
}

/**
 *  调用请求完成
 */
- (void)finished{
    if ([_delegate respondsToSelector:_finishedSelector]) {
        [_delegate performSelector:_finishedSelector withObject:self afterDelay:0.0f];
    }
}

/**
 *  调用请求失败
 */
- (void)faild{
    if ([_delegate respondsToSelector:_faildSelector]) {
        [_delegate performSelector:_faildSelector withObject:self afterDelay:0.0f];
    }
}

- (void)clearResponse {
    _responseErrorCode = nil;
    _responseErrorMsg = nil;
    _responseObject = nil;
    _responseData = nil;
    _responseDictionary = nil;
    _responseArray = nil;
}

/**
 *  调试方法
 */
- (NSString *)description{
    return [NSString stringWithFormat:@"key:%@ url:%@", self.key, self.urlString];
}

#pragma mark - getter/setter
- (void)setResponseObject:(id)responseObject {
    _responseObject = responseObject;
    if (self.useCache) {
        NSString *filePath = [self.cachefileDoc stringByAppendingPathComponent:__SMToString(@"%@.dat", self.key)];
        NSFileManager *manager = [[NSFileManager alloc] init];
        BOOL isDoc = YES;
        if (![manager fileExistsAtPath:self.cachefileDoc isDirectory:&isDoc]) {
            [manager createDirectoryAtPath:self.cachefileDoc withIntermediateDirectories:YES attributes:nil error:nil];
            docListStr = [docListStr stringByAppendingFormat:@"%@:", self.cachefileDoc];
        }
        NSData *data = self.responseData;
        NSError *error = nil;
        BOOL success = [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
        NSAssert(success, @"Request自动缓存失败:\n\t%@\n\t%@", filePath, error);
        if (success && (self.cacheTimeOut > 0)) {
            // 增加缓存期限
            NSString *timeOutIndexFilePath = [self.cachefileDoc stringByAppendingPathComponent:@"timeOutIndex.dat"];
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:timeOutIndexFilePath];
            NSMutableDictionary *timeOuthIndexDict = [NSMutableDictionary dictionary];
            [timeOuthIndexDict setDictionary:dict];
            NSTimeInterval timeInterval = self.cacheTimeOut + [NSDate timeIntervalSinceReferenceDate];
            [timeOuthIndexDict setValue:[NSNumber numberWithDouble:timeInterval] forKey:self.key];
            [timeOuthIndexDict writeToFile:timeOutIndexFilePath atomically:YES];
        }
    }
}

- (NSData *)responseData{
    if (_responseData) {
        // 什么也不做
    } else if (_responseDictionary) {
        _responseData = [NSKeyedArchiver archivedDataWithRootObject:_responseDictionary];
    } else if (_responseArray) {
        _responseData = [NSKeyedArchiver archivedDataWithRootObject:_responseArray];
    } else if (_responseObject) {
        if ([_responseObject isKindOfClass:[NSDictionary class]]) {
            _responseData = [NSJSONSerialization dataWithJSONObject:_responseObject options:NSJSONWritingPrettyPrinted error:nil];
        } else if ([_responseObject isKindOfClass:[NSArray class]]) {
            _responseData = [NSJSONSerialization dataWithJSONObject:_responseObject options:NSJSONWritingPrettyPrinted error:nil];
        } else if ([_responseObject isKindOfClass:[NSData class]]){
            _responseData = _responseObject;
        } else {
            NSLog(@"%@:WPUrlRequest:从服务器中接收了不是NSData,NSArray和NSDictionary对象以外的对象", @"error");
            _responseData = nil;
        }
    }
    return _responseData;
}

- (NSDictionary *)responseDictionary{
    if (_responseDictionary) {
        // 什么也不做
    } else {
        _responseDictionary = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    }
    return _responseDictionary;
}

- (NSArray *)responseArray {
    if (_responseArray) {
        // 什么也不做
    } else {
        _responseArray = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:nil];
    }
    return _responseArray;
}

- (NSString *)requestLocalPathExtension {
    if (!_requestLocalPathExtension) {
        _requestLocalPathExtension = @"json";
    }
    return _requestLocalPathExtension;
}

#pragma mark - Utils
+ (NSString *)keyOfRequestUrl:(NSString *)url {
    const char *str = [[@"_SMURL" stringByAppendingString:url] UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}

#pragma mark - cache 缓存
- (NSString *)cachefileDoc {
    if (!_cachefileDoc || !_cachefileDoc.length) {
        _cachefileDoc = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SMRequestCache"];
    }
    return _cachefileDoc;
}

- (NSData *)responseCacheData {
    if (_responseCacheData) {
        return _responseCacheData;
    } else {
        NSDictionary *timeOutIndexDict = nil;
        if (self.cacheTimeOut) {
            // 读取缓存期限
            NSString *timeOutIndexFilePath = [self.cachefileDoc stringByAppendingPathComponent:@"timeOutIndex.dat"];
            timeOutIndexDict = [NSDictionary dictionaryWithContentsOfFile:timeOutIndexFilePath];
        }
        NSTimeInterval timeOut = ((NSNumber *)(timeOutIndexDict[self.key])).doubleValue;
        BOOL isTimeOut = (timeOut < [NSDate timeIntervalSinceReferenceDate]);
        if (!isTimeOut) {
            NSString *filePath = [self.cachefileDoc stringByAppendingPathComponent:__SMToString(@"%@.dat", self.key)];
            NSError *error = nil;
            _responseData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        }
        return _responseData;
    }
}

- (NSDictionary *)responseCacheDictionary {
    if (_responseCacheDictionary) {
        // 什么也不做
    } else {
        _responseCacheDictionary = [NSJSONSerialization JSONObjectWithData:self.responseCacheData options:NSJSONReadingMutableContainers error:nil];
    }
    return _responseCacheDictionary;
}

- (NSArray *)responseCacheArray {
    if (_responseCacheArray) {
        // 什么也不做
    } else {
        _responseCacheArray = [NSJSONSerialization JSONObjectWithData:self.responseCacheData options:NSJSONReadingMutableContainers error:nil];
    }
    return _responseCacheArray;
}

- (void)clearCache {
    NSString *filePath = [self.cachefileDoc stringByAppendingPathComponent:__SMToString(@"%@.dat", self.key)];
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSError *error = nil;
    BOOL success = [manager removeItemAtPath:filePath error:&error];
    if (!success) {
        NSLog(@"删除缓存文件失败:\n\t%@\n\t%@", filePath, error);
    } else if (self.cacheTimeOut > 0) {
        // 删除缓存期限
        NSString *timeOutIndexFilePath = [self.cachefileDoc stringByAppendingPathComponent:@"timeOutIndex.dat"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:timeOutIndexFilePath];
        NSMutableDictionary *timeOuthIndexDict = [NSMutableDictionary dictionary];
        [timeOuthIndexDict setDictionary:dict];
        [timeOuthIndexDict removeObjectForKey:self.key];
        [timeOuthIndexDict writeToFile:timeOutIndexFilePath atomically:YES];
    }
}

+ (void)clearAllCache {
    NSArray *docList = [docListStr componentsSeparatedByString:@":"];
    NSFileManager *manager = [[NSFileManager alloc] init];
    NSError *error = nil;
    int count = 0;
    for (NSString *doc in docList) {
        if (doc.length) {
            BOOL success = [manager removeItemAtPath:doc error:&error];
            count += success;
            if (!success) {
                NSLog(@"删除缓存文件夹失败:\n\t%@\n\t%@", doc, error);
            }
        }
    }
    NSLog(@"成功清除缓存 %d 处", count);
    docListStr = @"";
}

@end
