//
//  GLFMDataBase.m
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLFMDataBase.h"
#import "FMDB.h"
#import "GLSQLGenerator.h"


@interface GLFMDataBase()

@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation GLFMDataBase

- (BOOL)isOpened
{
    return _queue != nil;
}

/**
 *  打开数据库文件
 *
 *  @param path         path description
 *  @param completion   操作完成处理方法
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDataBaseOpenCompletion)completion
{
    dispatch_block_t block = ^{
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        if(completion){
            dispatch_async(_completionQueue, ^{
                
                completion(self, path, YES);
            });
        }
    };
    
    // 有回调，则后台队列执行操作，并回到回调队列里执行回调
    if(completion){
        dispatch_async(_writeQueue, block);
    }else{
        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
        block();
    }
}

/**
 *  建表，建过表后会记录起来，如果下次再企图建表，将跳过此条要求，
 *  如改表，请使用@see -upgradeBySql:completion:
 *
 *  @param classes classes description
 */
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes
{
    [_queue inDatabase:^(FMDatabase *db) {
        
        [classes enumerateObjectsUsingBlock:^(Class clazz, NSUInteger idx, BOOL *stop) {
            
            if([clazz conformsToProtocol:@protocol(GLDBModelProtocol)])
            {
                NSString *sql = [clazz sqlForCreate];
                
                [db executeUpdate:sql];
                
                if([clazz sqlForUpdate])
                {
                    NSArray *upgradeSqls = [clazz sqlForUpdate];
                    
                    [upgradeSqls enumerateObjectsUsingBlock:^(NSString *upgradeSql, NSUInteger idx, BOOL *stop) {
                        
                        [db executeUpdate:upgradeSql];
                    }];
                }
            }
        }];
    }];
}

/**
 *  关闭数据库
 *
 *  @param completion   操作完成处理方法
 */
- (void)closeDatabaseWithCompletion:(GLDataBaseCloseCompletion)completion
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

/**
 *  保存对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)save:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSArray *columns   = [model toDictionary].allKeys;
        NSString *sql      = [[GLSQLGenerator defaultGenerator] generateInsertSqlWithModel:model columns:columns];
        NSArray *arguments = [[GLSQLGenerator defaultGenerator] generateInsertArgumentsWithModel:model columns:columns];
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sql withArgumentsInArray:arguments];
            
            if(completion)
            {
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

/**
 *  更新对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)update:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSString *sql = [[GLSQLGenerator defaultGenerator] generateUpdateSqlWithModel:model
                                                                        operationType:GLSQLGeneratorSQLTypeUpdate];
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sql withParameterDictionary:[model toDictionary]];
            
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

/**
 *  插入或更新对象至数据库
 *
 *  @param model      数据库model
 *  @param completion 操作完成处理方法
 */
- (void)saveOrUpdate:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        Class clazz = [[GLSQLGenerator defaultGenerator] getClassForModel:model];
        
        id<GLDBModelProtocol> m = [self findModelForClass:clazz byId:model.modelId];
        if(m){
            [self update:model completion:completion];
        }else{
            [self save:model completion:completion];
        }
    };
    
    if(completion){
        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
        dispatch_async(_writeQueue, block);
    }else{
        block();
    }
}

- (BOOL)removeModel:(id<GLDBModelProtocol>)model
{
    __block BOOL successfully = NO;
    
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateUpdateSqlWithModel:model
                                                                    operationType:GLSQLGeneratorSQLTypeDelete];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        successfully = [db executeUpdate:sql];
    }];
    
    return successfully;
}

/**
 *  从数据库移除指定记录
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)removeModel:(id<GLDBModelProtocol>)model completion:(GLDataBaseRemoveCompletion)completion
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

/**
 *  批量删除数据库条目
 *
 *  @param models       models description
 *  @param completion   操作完成处理方法
 */
- (void)removeModels:(NSArray *)models completion:(GLDataBaseRemoveCompletion)completion
{
    dispatch_block_t block = ^{
        
        [models enumerateObjectsUsingBlock:^(id<GLDBModelProtocol> model, NSUInteger idx, BOOL *stop) {
            [self removeModel:model];
        }];
        
        if(completion){
            dispatch_async(_completionQueue, ^{
                completion(self, models, YES);
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

/**
 *  从数据库里移除指定id的model
 *
 *  @param objectId     指定model的id
 *  @param completion   操作完成处理方法
 */
- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
                        byId:(NSString *)objectId
                  completion:(GLDataBaseRemoveCompletion)completion
{
    id<GLDBModelProtocol> model = [self findModelForClass:clazz byId:objectId];
    
    [self removeModel:model completion:completion];
}


/**
 *  执行sql update语句
 *
 *  @param sqlString    sqlString description
 *  @param completion   操作完成处理方法
 */
- (void)executeUpdate:(NSString *)sqlString completion:(GLDataBaseUpdateCompletion)completion
{
    dispatch_block_t block = ^{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sqlString];
            
            if(completion)
            {
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

/**
 *  升級數據庫版本時需要用到的接口
 *
 *  @param sqlString    sql語句
 *  @param completion   操作完成处理方法
 */
- (void)upgradeBySql:(NSString *)sqlString completion:(GLDataBaseUpgradeCompletion)completion
{
    dispatch_block_t block = ^{
        
        [_queue inDatabase:^(FMDatabase *db) {
            
            BOOL successfully = [db executeUpdate:sqlString];
            
            if(completion)
            {
                dispatch_async(_completionQueue, ^{
                    
                    completion(self, sqlString, successfully);
                });
            }
        }];
    };
    
    // 有回调，则后台队列执行操作，并回到回调队列里执行回调
    if(completion){
        dispatch_async(_writeQueue, block);
    }
    else{
        block();
    }
}

/**
 *  按唯一标识查询记录
 *
 *  @param clazz    目标model类型
 *  @param objectId 目标id
 *
 *  @return 目标记录model
 */
- (id<GLDBModelProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz byId:(NSString *)objectId
{
    if(!objectId)   return nil;
    
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithParameters:@{@"modelId" : objectId} forClass:clazz];
    
    __block NSDictionary *dic = nil;
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        if(resultSet.next)
        {
            dic = resultSet.resultDictionary;
        }
        
        [resultSet close];
    }];
    
    if(dic.count == 0)  return nil;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    return [clazz modelWithDinctionay:dictionary];
}

/**
 *  按相等方式查詢，拼sql字符串的時候以＝作為操作符
 *
 *  @param clazz      要查找的model類型
 *  @param parameters 參數，key為數據庫字段，value為值
 *  @param clazz        要查的表
 *  @param completion   查询完的处理
 *
 *  @return return value description
 */
- (void)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withParameters:(NSDictionary *)parameters
                completion:(GLDataBaseQueryCompletion)completion
{
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithParameters:parameters forClass:clazz];
    
    [self findModelsForClass:clazz withSqlString:sql completion:completion];
}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withParameters:(NSDictionary *)parameters
{
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithParameters:parameters forClass:clazz];
    
    return [self executeQuery:sql forClass:clazz];
}

/**
 *  比較複雜的查詢，比如大於，小於，區間
 *
 *  @param clazz      要查找的model類型
 *  @param conditions sql語句WHERE後面的部分
 *  @param completion   查询完的处理
 *
 *  @return return value description
 */
- (void)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
            withConditions:(NSString *)conditions
                completion:(GLDataBaseQueryCompletion)completion
{
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithConditions:conditions forClass:clazz];
    
    [self findModelsForClass:clazz withSqlString:sql completion:completion];
}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withConditions:(NSString *)conditions
{
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithConditions:conditions forClass:clazz];
    
    return [self executeQuery:sql forClass:clazz];
}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
             withSqlString:(NSString *)sql
                completion:(GLDataBaseQueryCompletion)completion
{
    dispatch_block_t block = ^{
        
        NSArray *results = [self executeQuery:sql forClass:clazz];
        
        if(completion)
        {
            dispatch_async(_completionQueue, ^{
                
                completion(self, results, sql);
            });
        }
    };
    
    // 有回调，则后台队列执行操作，并回到回调队列里执行回调
    if(completion)
    {
        dispatch_async(_readQueue, block);
    }
}

/**
 *  执行sql query语句，返回数组，即使要查询的是一个值，也返回一个数组
 *
 *  @param sqlString    sql语句
 *  @param clazz        要查的表
 *  @param completion   查询完的处理
 *
 *  @return MMModel数组
 */
- (void)executeQuery:(NSString *)sqlString
            forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
      withCompletion:(GLDataBaseQueryCompletion)completion
{
    [self findModelsForClass:clazz withSqlString:sqlString completion:completion];
}

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
{
    NSMutableArray <id<GLDBModelProtocol>> *results = [NSMutableArray<id<GLDBModelProtocol>> array];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sqlString];
        
        while (resultSet.next) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
            
            id<GLDBModelProtocol> model = [clazz modelWithDinctionay:dic];
            
            [results addObject:model];
        }
        
        [resultSet close];
    }];
    
    return results;
}

/**
 *  计数
 *
 *  @param clazz      clazz description
 *  @param conditions conditions description
 *
 *  @return return value description
 */
- (NSUInteger)countOfModelsForClass:(Class<GLDBModelProtocol>)clazz withConditions:(NSString *)conditions
{
    NSString *sql = [[GLSQLGenerator defaultGenerator] generateQuerySqlWithConditions:conditions forClass:clazz];
    
    __block NSUInteger count = 0;
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while (resultSet.next) {
            
            count ++;
        }
        
        [resultSet close];
    }];
    
    return count;
}

@end
