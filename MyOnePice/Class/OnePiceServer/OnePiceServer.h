//
//  OnePiceServer.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnePiceServer : NSObject

+ (instancetype)shareInstance;

- (id)requestDataWithUrl:(NSURL *)url params:(NSDictionary *)params;

@end
