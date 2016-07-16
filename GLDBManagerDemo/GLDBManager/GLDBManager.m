//
//  GLDBManager.m
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/25.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBManager.h"
#import "GLFMDataBase.h"
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
        _databaseDictionary = [NSMutableDictionary dictionary];
        
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _path = [cacheDir stringByAppendingPathComponent:@"default.sqlite"];
        
        switch (_type) {
            case GLDBManagerTypeFMDB:
            _dataBase = [[GLFMDataBase alloc] init];
            break;
            
            default:
            _dataBase = nil;
            break;
        }
    }
    
    return self;
}

#pragma mark -
#pragma mark public 

/**
 *  打开数据库
 *
 *  @param path
 *  @param completion
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDataBaseOpenCompletion)completion
{
    if(!path){
        //TODO: 设置默认路径
    }
    
    if(completion)
    {
        [_dataBase openDatabaseWithFileAtPath:path completion:^(GLDataBase *database, NSString *path, BOOL successfully) {
            
            if(successfully && database)
            {
                _databaseDictionary[path] = database;
            }
            
            completion(database, path, successfully);
        }];
    }
    else
    {
        [_dataBase openDatabaseWithFileAtPath:path completion:nil];
        
        _databaseDictionary[path] = _dataBase;
    }
}

/**
 *  关闭数据库
 *
 *  @param completion
 */
- (void)closeDatabaseWithCompletion:(GLDataBaseCloseCompletion)completion
{
    [_dataBase closeDatabaseWithCompletion:completion];
    
    NSArray *keys = [_databaseDictionary allKeysForObject:_dataBase];
    
    [_databaseDictionary removeObjectsForKeys:keys];
}

- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes
{
    [_dataBase createOrUpgradeTablesWithClasses:classes];
}
#pragma mark -
#pragma mark setter & getter

#pragma mark -
#pragma mark private













@end
