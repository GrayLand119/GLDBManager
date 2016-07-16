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

- (BOOL)opened
{
    return _queue != nil;
}

#pragma mark -
#pragma mark 打开数据库
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
#pragma mark 关闭数据库
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
#pragma mark 创建或更新表
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
#pragma mark 保存
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
#pragma mark 更新
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
#pragma mark -
#pragma mark 保存 | 更新
- (void)saveOrUpdate:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    AKSQLGenerator *generator = [AKSQLGenerator shareInstance];
    
    dispatch_block_t block = ^{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            Class clazz = [generator getClassForModel:model];
            
            NSString *sql = [generator querySqlWithParameters:@{@"modelId" : [model modelId]} forClass:clazz];
            
            FMResultSet *resultSet = [db executeQuery:sql];
            BOOL exists = resultSet.next;
            [resultSet close];
            
            BOOL successfully = NO;
            if(exists)
            {
                sql = [generator updateSqlWithModel:model];
                
                successfully = [db executeUpdate:sql withParameterDictionary:[model toDatabaseDictionary]];
            }
            else
            {
                NSArray *columns = [model toDatabaseDictionary].allKeys;
                
                sql = [generator insertSqlWithModel:model columns:columns];
                NSArray *arguments = [generator insertArgumentsWithModel:model columns:columns];
                
                successfully = [db executeUpdate:sql withArgumentsInArray:arguments];
            }
            
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
        block();
    }
}

- (void)executeUpdate:(NSString *)sqlString completion:(AKDatabaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sqlString];
            
            if(completion){
                dispatch_async(_completionQueue, ^{
                    completion(self, nil, sqlString, successfully);
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
#pragma mark 删除
- (BOOL)removeModel:(id<AKDBPersistProtocol>)model
{
    __block BOOL successfully = NO;
    
    NSString *sql = [[AKSQLGenerator shareInstance] deleteSqlWithModel:model];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        successfully = [db executeUpdate:sql];
    }];
    
    return successfully;
}

- (void)removeModel:(id<AKDBPersistProtocol>)model completion:(AKDatabaseRemoveCompletion)completion
{
    dispatch_block_t block = ^{
        
        BOOL successfully = [self removeModel:model];
        
        if(completion){
            dispatch_async(_completionQueue, ^{
                completion(self, @[model], successfully);
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

- (void)removeModelWithClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                        byId:(NSString *)objectId
                  completion:(AKDatabaseRemoveCompletion)completion
{
    id<AKDBPersistProtocol> model = [self findModelForClass:clazz byId:objectId];
    
    [self removeModel:model completion:completion];
}
#pragma mark -
#pragma mark 查询
/**
 *  查询
 *
 *  @param sqlString
 *  @param clazz
 *
 *  @return result
 */
- (NSArray *)executeQuery:(NSString *)sqlString
                 forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
{
    NSMutableArray<id<AKDBPersistProtocol>> *results = [NSMutableArray<id<AKDBPersistProtocol>> array];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sqlString];
        
        while (resultSet.next)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
            
            id<AKDBPersistProtocol> model = [clazz modelWithDatabaseDictionary:dic];
            
            [results addObject:model];
        }
        
        [resultSet close];
    }];
    
    return results;
}

- (void)executeQuery:(NSString *)sqlString
            forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
      withCompletion:(AKDatabaseQueryCompletion)completion
{
    [self findModelsForClass:clazz withSqlString:sqlString completion:completion];
}

/**
 *  查询 - 通过ModelId
 *
 *  @param clazz
 *  @param objectId
 *
 *  @return
 */
- (id<AKDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                                        byId:(NSString *)objectId
{
    if(!objectId)   return nil;
    
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithParameters:@{@"modelId" : objectId} forClass:clazz];
    
    __block NSDictionary *dic = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if(resultSet.next){
            dic = resultSet.resultDictionary;
        }
        
        [resultSet close];
    }];
    
    if(dic.count == 0)  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    return [clazz modelWithDatabaseDictionary:dictionary];

}

/**
 *  查询 - 通过SQL语句
 *
 *  @param clazz
 *  @param sql
 *  @param completion 有回调则异步查询,无回调则同步查询
 */
- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withSqlString:(NSString *)sql
                completion:(AKDatabaseQueryCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSArray *results = [self executeQuery:sql forClass:clazz];
        
        if(completion){
            dispatch_async(_completionQueue, ^{
                completion(self, results, sql);
            });
        }
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_readQueue, block);
    }else{
        block();
    }
}

/**
 *  查询 - 通过Dictionary (同步执行)
 *
 *  @param clazz
 *  @param parameters @{name:value}
 *
 *  @return result
 */
- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                 withParameters:(NSDictionary *)parameters
{
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithParameters:parameters forClass:clazz];
    
    return [self executeQuery:sql forClass:clazz];
}

/**
 *  查询 - 通过Dictionary (异步回调)
 *
 *  @param clazz
 *  @param parameters @{name:value}
 *  @param completion 执行完毕回调
 */
- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
            withParameters:(NSDictionary *)parameters
                completion:(AKDatabaseQueryCompletion)completion
{
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithParameters:parameters forClass:clazz];
    
    [self findModelsForClass:clazz withSqlString:sql completion:completion];
}

/**
 *  查询 - 条件查询 (同步执行)
 *
 *  @param clazz
 *  @param conditions 查询条件,例如 conditions = @"age > 18"
 *
 *  @return result
 */
- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                 withConditions:(NSString *)conditions
{
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
    
    return [self executeQuery:sql forClass:clazz];
}

/**
 *  查询 - 条件查询 (异步回调)
 *
 *  @param clazz
 *  @param conditions 查询条件,例如 conditions = @"age > 18"
 *  @param completion 执行完毕回调
 */
- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
            withConditions:(NSString *)conditions
                completion:(AKDatabaseQueryCompletion)completion
{
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
    
    [self findModelsForClass:clazz withSqlString:sql completion:completion];
}

#pragma mark -
#pragma mark 升级数据库
- (void)upgradeBySql:(NSString *)sqlString completion:(AKDatabaseUpgradeCompletion)completion
{
    dispatch_block_t block = ^{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sqlString];
            
            if(completion){
                dispatch_async(_completionQueue, ^{
                    completion(self, sqlString, successfully);
                });
            }
        }];
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        block();
    }
}

#pragma mark -
#pragma mark 计数
- (NSUInteger)countOfModelsForClass:(Class<AKDBPersistProtocol>)clazz withConditions:(NSString *)conditions
{
    NSString *sql = [[AKSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
    
    __block NSUInteger count = 0;
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while (resultSet.next) {
            ++count;
        }
        
        [resultSet close];
    }];
    
    return count;
}


@end
