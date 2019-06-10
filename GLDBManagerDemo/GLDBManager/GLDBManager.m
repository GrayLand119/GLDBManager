//
//  GLDBManager.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBManager.h"
#import "GLDatabase.h"

@interface GLDBManager()

//@property (nonatomic, strong) GLDatabase          *database;///<当前数据库

@property (nonatomic, strong) NSMutableDictionary *databaseDictionary;///<储存多个数据库 key = path

@end

@implementation GLDBManager

+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static GLDBManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[GLDBManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _databaseDictionary = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)defaultDBDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSString *)defaultDBName {
    return @"gldb_default.sqlite";
}

//- (NSString *)defaultDBPath {
//    return [[self defaultDBDirectory] stringByAppendingPathComponent:[self defaultDBName]];
//}

#pragma mark -
#pragma mark Getter & Setter


#pragma mark -
#pragma mark 打开数据库

- (GLDatabase *)openDefaultDatabaseWithUserId:(NSString *)userId {
    if (!_defaultDB || !_defaultDB.isOpened) {
        NSString *path = [self defaultDBDirectory];
        if (userId.length) {
            path = [path stringByAppendingPathComponent:userId];
        }
        path = [path stringByAppendingPathComponent:[self defaultDBName]];
        _defaultDB = [[GLDatabase alloc] init];
        [_defaultDB openDatabaseWithPath:path];
        _databaseDictionary[path] = _defaultDB;
    }
    return _defaultDB;
}

- (GLDatabase *)openedDatabaseWithPath:(NSString *)path {

    if(!path.length) return nil;

    // 如果已打开,直接返回
    if([_databaseDictionary.allKeys containsObject:path]){
        GLDatabase *database = _databaseDictionary[path];
        if (database.isOpened) {
            return database;
        }
    }
    
    // 打开新的数据库
    GLDatabase *database = [[GLDatabase alloc] init];
    [database openDatabaseWithPath:path];
    
    _databaseDictionary[path] = database;

    return database;
}


/**
 * @brief 关闭数据库
 */
- (void)closeDatabase:(GLDatabase *)database {
    __weak __typeof(self) ws = self;
    [database closeDatabaseWithCompletion:^(GLDatabase *database, BOOL isScuccessful) {
        ws.databaseDictionary[database.path] = nil;
    }];
}

@end
