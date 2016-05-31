//
//  GLDBManager.m
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/25.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBManager.h"
//#import <sqlite3.h>
//
//#define DEFAULT_DB_NAME @"sqlite"

@interface GLDBManager()

@end

@implementation GLDBManager

+ (instancetype)defaultManager
{
    static GLDBManager *defaultManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[GLDBManager alloc] init];
    });
    
    return defaultManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _type = GLDBManagerTypeFMDB;///<默认使用FMDB
    }
    
    return self;
}

#pragma mark -
#pragma mark setter & getter

#pragma mark -
#pragma mark private












@end
