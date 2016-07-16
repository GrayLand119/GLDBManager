//
//  AKFMDBDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKFMDBDatabase.h"
#import "FMDB.h"
#import "AKSQLGenerator.h"

@interface AKFMDBDatabase()
{
    FMDatabaseQueue *_queue;
    
    BOOL _opened;
}
@end

@implementation AKFMDBDatabase

#pragma mark -
#pragma Private


#pragma mark -
#pragma Overwrite

- (BOOL)opened
{
    return _queue != nil;
}

#pragma mark -
#pragma 打开数据库
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(AKDatabaseOpenCompletion)completion
{
    dispatch_block_t block = ^{
        
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        if(completion){
            dispatch_async(_completionQueue, ^{
                completion(self, path, YES);
            });
        }
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
        block();
    }
}
#pragma mark -
#pragma 关闭数据库
- (void)closeDatabaseWithCompletion:(AKDatabaseCloseCompletion)completion
{
    dispatch_block_t block = ^{
        
        [_queue close];
        
        if(completion){
            dispatch_async(_completionQueue, ^{
                completion(self, YES);
            });
        }
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
        block();
    }
}
#pragma mark -
#pragma 创建或更新表
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes
{
    [_queue inDatabase:^(FMDatabase *db) {
        
        [classes enumerateObjectsUsingBlock:^(Class clazz, NSUInteger idx, BOOL *stop) {
            
            if([clazz conformsToProtocol:@protocol(AKDBPersistProtocol)]){
                
                NSString *sql = [clazz creationSql];
                BOOL bSuccess = [db executeUpdate:sql];
                
                NSLog(@"创建表[%@]%@",[NSString stringWithUTF8String:object_getClassName(clazz)], bSuccess ? @"成功" : @"失败");
                
                if([clazz upgradeSqls]){
                    
                    NSArray *upgradeSqls = [clazz upgradeSqls];
                    
                    [upgradeSqls enumerateObjectsUsingBlock:^(NSString *upgradeSql, NSUInteger idx, BOOL *stop) {
                        [db executeUpdate:upgradeSql];
                    }];
                }
            }
        }];
    }];
}
#pragma mark -
#pragma 保存
- (void)save:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSArray *columns = [model toDatabaseDictionary].allKeys;
        
        NSString *sql = [[AKSQLGenerator shareInstance] insertSqlWithModel:model columns:columns];
        NSArray *arguments = [[AKSQLGenerator shareInstance] insertArgumentsWithModel:model columns:columns];
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sql withArgumentsInArray:arguments];
            
            if(completion){
                dispatch_async(_completionQueue, ^{
                    completion(self, model, sql, successfully);
                });
            }
        }];
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
        block();
    }
}
#pragma mark -
#pragma 更新
- (void)update:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSString *sql = [[AKSQLGenerator shareInstance] updateSqlWithModel:model];
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sql withParameterDictionary:[model toDatabaseDictionary]];
            
            if(completion){
                dispatch_async(_completionQueue, ^{
                    completion(self, model, sql, successfully);
                });
            }
        }];
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
        block();
    }
}

@end
