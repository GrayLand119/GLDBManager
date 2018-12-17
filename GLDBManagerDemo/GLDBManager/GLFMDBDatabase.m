//
//  GLFMDBDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLFMDBDatabase.h"
#import "GLSQLGenerator.h"
//#import <objc/runtime.h>

@interface GLFMDBDatabase()

@end

@implementation GLFMDBDatabase


#pragma mark -
#pragma mark 打开数据库

#pragma mark -
#pragma mark 关闭数据库
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion
{
    
}
#pragma mark -
#pragma mark 创建或更新表

#pragma mark -
#pragma mark 保存
//- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
//{
//    dispatch_block_t block = ^{
//
//        NSArray *columns = [model toDatabaseDictionary].allKeys;
//
//        NSString *sql = [[GLSQLGenerator shareInstance] insertSqlWithModel:model columns:columns];
//        NSArray *arguments = [[GLSQLGenerator shareInstance] insertArgumentsWithModel:model columns:columns];
//
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//
//            BOOL successfully = [db executeUpdate:sql withArgumentsInArray:arguments];
//
//            if(completion){
//                dispatch_async(self->_completionQueue, ^{
//                    completion(self, model, sql, successfully);
//                });
//            }
//        }];
//    };
//
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
//        block();
//    }
//}
//#pragma mark -
//#pragma mark 更新
//- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
//{
//    dispatch_block_t block = ^{
//
//        NSString *sql = [[GLSQLGenerator shareInstance] updateSqlWithModel:model];
//
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//
//            BOOL successfully = [db executeUpdate:sql withParameterDictionary:[model toDatabaseDictionary]];
//
//            if(completion){
//                dispatch_async(self->_completionQueue, ^{
//                    completion(self, model, sql, successfully);
//                });
//            }
//        }];
//    };
//
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
//        block();
//    }
//}
//#pragma mark -
//#pragma mark 保存 | 更新
//- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion {
//
//    GLSQLGenerator *generator = [GLSQLGenerator shareInstance];
//
//    dispatch_block_t block = ^{
//
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//
//            Class clazz = [generator getClassForModel:model];
//
//            NSString *sql = [generator querySqlWithParameters:@{@"primaryKey" : [model primaryKey]} forClass:clazz];
////            if ([model primaryKey]) {
////                sql = [generator querySqlWithParameters:@{@"primaryKey" : [model primaryKey]} forClass:clazz];
////            }else {
////                sql = [generator querySqlWithParameters:@{@"modelId" : [model modelId]} forClass:clazz];
////            }
//
//            FMResultSet *resultSet = [db executeQuery:sql];
//
//            BOOL exists = resultSet.next;
//            [resultSet close];
//
//            BOOL successfully = NO;
//
//            if(exists) {
//                sql = [generator updateSqlWithModel:model];
//
//                successfully = [db executeUpdate:sql withParameterDictionary:[model toDatabaseDictionary]];
//            }else{
//                NSArray *columns = [model toDatabaseDictionary].allKeys;
//
//                sql = [generator insertSqlWithModel:model columns:columns];
//                NSArray *arguments = [generator insertArgumentsWithModel:model columns:columns];
//
//                successfully = [db executeUpdate:sql withArgumentsInArray:arguments];
//                if (!successfully) {
//                    DBLog(@"!!!%@", [db lastError]);
//                }
//            }
//
//            if(completion){
//                dispatch_async(self->_completionQueue, ^{
//                    completion(self, model, sql, successfully);
//                });
//            }
//        }];
//    };
//
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        block();
//    }
//}
//
//- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion
//{
//    dispatch_block_t block = ^{
//
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//
//            BOOL successfully = [db executeUpdate:sqlString];
//
//            if(completion){
//                dispatch_async(self->_completionQueue, ^{
//                    completion(self, nil, sqlString, successfully);
//                });
//            }
//        }];
//    };
//
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
//        block();
//    }
//}
//#pragma mark -
//#pragma mark 删除
//
//- (BOOL)removeAllInTable:(NSString *)tableName {
//    __block BOOL successfully = NO;
//
//    NSString *sql = [[GLSQLGenerator shareInstance] deleteAllSqlWithModelName:tableName];
//
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        successfully = [db executeUpdate:sql];
//        if (!successfully) {
//            DBLog(@"!!!%@", [db lastError]);
//        }
//    }];
//
//    return successfully;
//}
//
//- (BOOL)removeModel:(id<GLDBPersistProtocol>)model {
//
//    __block BOOL successfully = NO;
//
//    NSString *sql = [[GLSQLGenerator shareInstance] deleteSqlWithModel:model];
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        successfully = [db executeUpdate:sql];
//        if (!successfully) {
//            DBLog(@"!!!%@", [db lastError]);
//        }
//    }];
//
//    return successfully;
//}
//
//- (BOOL)removeModelWithId:(NSString *)modelId inTable:(NSString *)tableName {
//    __block BOOL successfully = NO;
//    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE modelId = '%@'", [tableName lowercaseString], modelId];
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        successfully = [db executeUpdate:sql];
//        if (!successfully) {
//            DBLog(@"!!!%@", [db lastError]);
//        }
//    }];
//
//    return successfully;
//}
//
//- (void)removeModelWithId:(NSString *)modelId inTable:(NSString *)tableName completion:(GLDatabaseExcuteCompletion)completion {
//    dispatch_block_t block = ^{
//        BOOL successfully = [self removeModelWithId:modelId inTable:tableName];
//        if(completion){
//            dispatch_async(self->_completionQueue, ^{
//                completion(self, modelId, successfully);
//            });
//        }
//    };
//
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
//        block();
//    }
//}

//- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion {
//    dispatch_block_t block = ^{
//        
//        BOOL successfully = [self removeModel:model];
//        
//        if(completion){
//            dispatch_async(self->_completionQueue, ^{
//                completion(self, [NSMutableArray arrayWithArray:@[model]], successfully);
//            });
//        }
//    };
//    
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        // 无回调，则在主线程中执行操作，但必须是阻塞的，因为不阻塞的话，可能这里还没执行完，就执行到调用此方法的下一行了
//        block();
//    }
//}
//
//- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//                        byId:(NSString *)objectId
//                  completion:(GLDatabaseRemoveCompletion)completion
//{
//    id<GLDBPersistProtocol> model = [self findModelForClass:clazz byId:objectId];
//    
//    [self removeModel:model completion:completion];
//}
//#pragma mark -
//#pragma mark 查询
///**
// *  查询
// *
// *  @param sqlString
// *  @param clazz
// *
// *  @return result
// */
//- (NSMutableArray *)executeQuery:(NSString *)sqlString
//                 forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//{
//    NSMutableArray<id<GLDBPersistProtocol>> *results = [NSMutableArray<id<GLDBPersistProtocol>> array];
//    
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        
//        FMResultSet *resultSet = [db executeQuery:sqlString];
//        
//        while (resultSet.next)
//        {
//            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
//            
//            id<GLDBPersistProtocol> model = [clazz modelWithDinctionay:dic];
//            
//            [results addObject:model];
//        }
//        
//        [resultSet close];
//    }];
//    
//    return results;
//}
//
//- (void)executeQuery:(NSString *)sqlString
//            forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//      withCompletion:(GLDatabaseQueryCompletion)completion
//{
//    [self findModelsForClass:clazz withSqlString:sqlString completion:completion];
//}
//
///**
// *  查询 - 通过ModelId
// *
// *  @param clazz
// *  @param objectId
// *
// *  @return
// */
//- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//                                        byId:(NSString *)objectId
//{
//    if(!objectId)   return nil;
//    
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithParameters:@{@"modelId" : objectId} forClass:clazz];
//    
//    __block NSDictionary *dic = nil;
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        
//        FMResultSet *resultSet = [db executeQuery:sql];
//        
//        if(resultSet.next){
//            dic = resultSet.resultDictionary;
//        }
//        
//        [resultSet close];
//    }];
//    
//    if(dic.count == 0)  return nil;
//    
//    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
//    
//    return [clazz modelWithDinctionay:dictionary];
//
//}
//
///**
// *  查询 - 通过SQL语句
// *
// *  @param clazz
// *  @param sql
// *  @param completion 有回调则异步查询,无回调则同步查询
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withSqlString:(NSString *)sql
//                completion:(GLDatabaseQueryCompletion)completion
//{
//    dispatch_block_t block = ^{
//        
//        NSMutableArray *results = [self executeQuery:sql forClass:clazz];
//        
//        if(completion){
//            dispatch_async(self->_completionQueue, ^{
//                completion(self, results, sql);
//            });
//        }
//    };
//    
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_readQueue, block);
//    }else{
//        block();
//    }
//}
//
///**
// *  查询 - 通过Dictionary (同步执行)
// *
// *  @param clazz
// *  @param parameters @{name:value}
// *
// *  @return result
// */
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//                 withParameters:(NSDictionary *)parameters
//{
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithParameters:parameters forClass:clazz];
//    
//    return [self executeQuery:sql forClass:clazz];
//}
//
///**
// *  查询 - 通过Dictionary (异步回调)
// *
// *  @param clazz
// *  @param parameters @{name:value}
// *  @param completion 执行完毕回调
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//            withParameters:(NSDictionary *)parameters
//                completion:(GLDatabaseQueryCompletion)completion
//{
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithParameters:parameters forClass:clazz];
//    
//    [self findModelsForClass:clazz withSqlString:sql completion:completion];
//}
//
///**
// *  查询 - 条件查询 (同步执行)
// *
// *  @param clazz
// *  @param conditions 查询条件,例如 conditions = @"age > 18"
// *
// *  @return result
// */
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//                 withConditions:(NSString *)conditions
//{
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
//    
//    return [self executeQuery:sql forClass:clazz];
//}
//
///**
// *  查询 - 条件查询 (异步回调)
// *
// *  @param clazz
// *  @param conditions 查询条件,例如 conditions = @"age > 18"
// *  @param completion 执行完毕回调
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//            withConditions:(NSString *)conditions
//                completion:(GLDatabaseQueryCompletion)completion
//{
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
//    
//    [self findModelsForClass:clazz withSqlString:sql completion:completion];
//}
//
//#pragma mark -
//#pragma mark 升级数据库
//- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion
//{
//    dispatch_block_t block = ^{
//        
//        [self.dbQueue inDatabase:^(FMDatabase *db) {
//            
//            BOOL successfully = [db executeUpdate:sqlString];
//            
//            if(completion){
//                dispatch_async(self->_completionQueue, ^{
//                    completion(self, sqlString, successfully);
//                });
//            }
//        }];
//    };
//    
//    if(completion){
//        // 有回调，则后台队列执行操作，并回到回调队列里执行回调
//        dispatch_async(_writeQueue, block);
//    }else{
//        block();
//    }
//}
//
//#pragma mark -
//#pragma mark 计数
//- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions
//{
//    NSString *sql = [[GLSQLGenerator shareInstance] querySqlWithConditions:conditions forClass:clazz];
//    
//    __block NSUInteger count = 0;
//    
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        
//        FMResultSet *resultSet = [db executeQuery:sql];
//        
//        while (resultSet.next) {
//            ++count;
//        }
//        
//        [resultSet close];
//    }];
//    
//    return count;
//}


@end
