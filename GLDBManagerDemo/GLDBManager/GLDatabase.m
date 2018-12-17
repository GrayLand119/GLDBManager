//
//  GLDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDatabase.h"

@implementation GLDatabase

- (instancetype)init {
    if(self = [super init]) {
        _readQueue = dispatch_queue_create("com.gldb.readqueue", DISPATCH_QUEUE_CONCURRENT);
        _writeQueue = dispatch_queue_create("com.gldb.writequeue", DISPATCH_QUEUE_CONCURRENT);
        _completionQueue = dispatch_get_main_queue();
    }
    
    return self;
}

/**
 * @brief 打开数据库
 */
- (void)openDatabaseWithPath:(NSString * _Nonnull)path {
    
    NSAssert(path, @"path is nil");
    
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    _path = path;
}

/**
 * @brief 关闭数据库
 */
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion {
    
    dispatch_block_t block = ^{
        [self->_dbQueue close];
        if(completion){
            dispatch_async(self->_completionQueue, ^{
                completion(self, YES);
            });
        }
    };
    
    if(completion) {
        dispatch_async(_writeQueue, block);
    }else{
        block();
    }
}

- (NSArray <NSString *> *)getAllTableNameUsingCache:(BOOL)usingCache {
    if (usingCache) {
        if (!_allTableCached) {
            _allTableCached = [self getAllTableNameUsingCache:NO];
        }
        return _allTableCached;
    }
    NSString *sql = @"SELECT * FROM sqlite_master";
    NSArray *results = [self excuteQueryWithSQL:sql completion:nil];
    NSMutableArray *tables = [NSMutableArray array];
    for (NSDictionary *info in results) {
        NSString *name = info[@"tbl_name"];
        if ([name isEqualToString:@"sqlite_sequence"]) {
            continue;
        }
        [tables addObject:name];
    }
    
    _allTableCached = tables;
    
    return tables;
}

/**
 * @brief 注册: 根据Model自动创建表, 若有新字段则自动添加
 */
- (void)registTablesWithModels:(NSArray *)models {
    NSArray *tables = [self getAllTableNameUsingCache:YES];
    for (NSString *table in tables) {
        // TODO: 实现自动升级
        
    }
}

/**
 * @brief 获取表的所有列
 */
- (NSArray <NSString *> *)allColumnsInTable:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", table];
    return [self excuteQueryWithSQL:sql completion:nil];
}

/**
 * @brief 执行查询功能的 SQL
 * @param completion若为nil, 则同步执行, 否则为异步执行
 */
-  (NSMutableArray *)excuteQueryWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion {
    
    NSMutableArray *results = [NSMutableArray array];
    
    dispatch_block_t block = ^{
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQuery:sql];
            while (resultSet.next) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
                [results addObject:dic];
            }
            
            [resultSet close];
        }];
    };
    
    if(completion) {
        dispatch_async(_readQueue, block);
        return nil;
    }else{
        block();
        return results;
    }
}

//- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes{}
//
//- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}
//
//- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}
//
//- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}
//
//- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion{}
//
//- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion{}
//
//- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId completion:(GLDatabaseRemoveCompletion)completion{}
//
//- (BOOL)removeAllInTable:(NSString *)tableName {return NO;}
//
//- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion{}
//
//- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withCompletion:(GLDatabaseQueryCompletion)completion{}
//
//- (NSMutableArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz{return nil;}
//
//- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId{return nil;}
//
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions completion:(GLDatabaseQueryCompletion)completion{}
//
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return nil;}
//
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters completion:(GLDatabaseQueryCompletion)completion{}
//
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters{return nil;}
//
//- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return 0;}
//
//- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion{}


#pragma mark - Setter

#pragma mark - Getter

- (BOOL)isOpened {
    return _dbQueue != nil;
}

@end
