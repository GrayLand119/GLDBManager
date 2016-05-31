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
        _type = GLDBManagerTypeFMDB;
    }
    
    return self;
}

#pragma Getter | Setter
//- (NSError *)lastestError
//{
//    if (!_lastestError) {
//        _lastestError = [[NSError alloc] init];
//    }
//    return _lastestError;
//}

#pragma mark -
#pragma mark public API

#pragma Open DataBase
//- (BOOL)openDB
//{
//    return [self openDBWithName:DEFAULT_DB_NAME];
//}
//
//- (BOOL)openDBWithName:(NSString *)name
//{
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *fullPath = [path stringByAppendingString:[NSString stringWithFormat:@"%@.sqlite", name]];
//    
//    return [self openDBWithFullPath:fullPath];
//}
//
//- (BOOL)openDBWithFullPath:(NSString *)fullPath
//{
//    NSLog(@"OpenDBPath:%@", fullPath);
//    
//    int result = sqlite3_open([fullPath UTF8String], &_currentDB);
//    if (result == SQLITE_OK) {
//        return YES;
//    }else{
//        //TODO: 错误处理
//        return NO;
//    }
//}
//
//#pragma Actione
///**
// *  创建表
// */
//- (void)createTableWithName:(NSString *)name
//{
//    NSString *sql = [NSString stringWithFormat:@"create table if exists %@ (id  integer primary autoincrement, name text, age integer);", name];
//    
//    [self createTableWithSQL:sql];
//}
//
//- (void)createTableWithSQL:(NSString *)sql
//{
//    if (!sql) {
//        sql = @"";
//    }
//    
//    char *error;
//    
//    int result = sqlite3_exec(_currentDB, [sql UTF8String], nil, nil, &error);
//    if (result == SQLITE_OK) {
//        
//    }else{
////        NSLog(@"Create table [%@] failed.", name);
//        //TODO: 错误处理
//    }
//}
//
///**
// *  插入数据
// */
//- (void)insertData
//{
//    NSString *sql = @"insert ";
//    // 存储内容
//    sqlite3_stmt *stmt;
//    
//    
//}










@end
