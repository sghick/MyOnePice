//
//  ServerDal.h
//  MyOnePice
//
//  Created by 丁治文 on 16/6/8.
//  Copyright © 2016年 sumrise.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMServerModel.h"

@interface ServerDal : NSObject

+ (SMServerAccount *)accountWithUserName:(NSString *)userName;

@end
