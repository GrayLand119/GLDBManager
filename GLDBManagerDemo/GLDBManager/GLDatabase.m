//
//  GLDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDatabase.h"

#if DEBUG
#define DebugLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#define GLPrint(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define DebugLog(fmt, ...) nil
#define GLPrint(FORMAT, ...) nil
#endif

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
    NSArray *results = [self executeReadActionWithSQL:sql completion:nil];
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
 * @brief 注册: 根据Model自动创建表, 若有新字段则自动添加, 若有自定义升级则使用自定义升级
 */
- (void)registTablesWithModels:(NSArray <Class <GLDBPersistProtocol>> *)models {
    NSArray *tables = [self getAllTableNameUsingCache:NO];
    NSSet *tableSet = [NSSet setWithArray:tables];
    
    DebugLog(@"开始注册表...");
    for (Class <GLDBPersistProtocol> cls in models) {
        NSString *tableName = [cls tableName];
        if ([tableSet containsObject:tableName]) {
            DebugLog(@"表存在, 检查Columns...");
            // Check Table Column
            NSArray <NSDictionary *> *allColumnsInTable = [self getAllColumnsInfoInTable:tableName];
            /*
             Example:
             {
             cid = 0;
             "dflt_value" = "<null>";
             name = modelId;
             notnull = 0;
             pk = 1;
             type = INTEGER;
             }
             */
            NSMutableArray *columnNamesInTable = [NSMutableArray arrayWithCapacity:allColumnsInTable.count];
            for (NSDictionary *dict in allColumnsInTable) {
                [columnNamesInTable addObject:dict[@"name"]];
            }
            
            DebugLog(@"allColumns-%@:%@", tableName, columnNamesInTable);
            
            // 是否有自定义
            NSArray <NSString *> *customSQLArray = [cls customUpgradeTableSQLWithOldColumns:columnNamesInTable];
            if (customSQLArray) {
                DebugLog(@"执行自定义升级...");
                dispatch_async(_writeQueue, ^{
                    for (NSString *customSQL in customSQLArray) {
                        [self executeWriteActionWithSQL:customSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                            DebugLog(@"自定义升级 %@", successfully?@"成功":@"失败");
                        }];
                    }
                });
                return;
            }
            
            // 无自定义升级, 默认.
            NSArray <NSString *> *sqlArray = [cls upgradeTableSQLWithOldColumns:columnNamesInTable];
            if ([sqlArray count] == 0) {
                DebugLog(@"Table %@ 无需升级", tableName);
                return;
            }
            dispatch_async(_writeQueue, ^{
                DebugLog(@"执行默认升级...");
                dispatch_async(_writeQueue, ^{
                    for (NSString *upgradeSQL in sqlArray) {
                        [self executeWriteActionWithSQL:upgradeSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                            DebugLog(@"默认升级 %@", successfully?@"成功":@"失败");
                        }];
                    }
                });
            });
        }else {
            DebugLog(@"创建表-%@...", tableName);
            // Create Table
            NSString *createSQL = [cls createTableSQL];
            dispatch_async(_readQueue, ^{
                [self executeWriteActionWithSQL:createSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                    if (successfully) {
                        DebugLog(@"创建表成功!");
                    }else{
                        DebugLog(@"创建表失败!:%@", errorMsg);
                    }
                }];
            });
        }
    }
}

/**
 * @brief 获取表的所有列信息
 */
- (NSArray <NSDictionary *> *)getAllColumnsInfoInTable:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", table];
    return [self executeReadActionWithSQL:sql completion:nil];
}

/**
 * @brief 执行查询功能的 SQL
 */
-  (NSMutableArray *)executeReadActionWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion {
    
    NSMutableArray *results = [NSMutableArray array];
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
            [results addObject:dic];
        }
        
        [resultSet close];
    }];
    
    if(completion) {
        completion(self, results, YES, nil);
    }
    
    return results;
}

/**
 * @brief 执行写功能的 SQL
 */
- (void)executeWriteActionWithSQL:(NSString *)sql completion:(GLDatabaseUpdateCompletion)completion {
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql, nil];
        if (result) {
            completion(self, nil, sql, YES, nil);
        }else {
            NSError *error = [db lastError];
            NSLog(@"%@", error);
            completion(self, nil, sql, NO, error.localizedDescription);
        }
    }];
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
