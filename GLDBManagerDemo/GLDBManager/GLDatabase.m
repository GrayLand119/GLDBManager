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
    NSArray *results = [self executeQueryWithSQL:sql completion:nil];
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
                        [self excuteUpdateWithSQL:customSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, BOOL successfully, NSString *errorMsg) {
                            DebugLog(@"自定义升级 %@", successfully?@"成功":@"失败");
                        }];
                    }
                });
                return;
            }
            
            // 无自定义升级, 默认.
            NSArray <NSString *> *sqlArray = [cls upgradeTableSQLWithOldColumns:columnNamesInTable];
            
            if (![cls autoIncrement]) {
                if (![columnNamesInTable containsObject:@"primaryKey"]) {
                    NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN primaryKey TEXT", tableName];
                    NSMutableArray *tMArr = [NSMutableArray arrayWithArray:sqlArray];
                    [tMArr addObject:sql];
                    sqlArray = tMArr;
                }
            }
            if ([sqlArray count] == 0) {
                DebugLog(@"Table %@ 无需升级", tableName);
                continue;
            }
            dispatch_async(_writeQueue, ^{
                DebugLog(@"执行默认升级...");
                dispatch_async(self->_writeQueue, ^{
                    for (NSString *upgradeSQL in sqlArray) {
                        [self excuteUpdateWithSQL:upgradeSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, BOOL successfully, NSString *errorMsg) {
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
                [self excuteUpdateWithSQL:createSQL completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, BOOL successfully, NSString *errorMsg) {
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
 * @brief 执行查询功能的 SQL
 */
-  (NSMutableArray *)executeQueryWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion {
    
    NSMutableArray *results = [NSMutableArray array];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
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
 * @brief 执行更新功能的 SQL
 */
- (void)excuteUpdateWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion {
    dispatch_async(_writeQueue, ^{
        [self->_dbQueue inDatabase:^(FMDatabase *db) {
            BOOL result = [db executeUpdate:sql];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    if (completion) {
                        completion(self, nil, YES, nil);
                    }
                }else {
                    NSError *error = [db lastError];
                    NSLog(@"%@", error);
                    if (completion) {
                        completion(self, nil, NO, error.localizedDescription);
                    }
                }
            });
        }];
    });
}


/**
 * @brief 获取表的所有列信息
 */
- (NSArray <NSDictionary *> *)getAllColumnsInfoInTable:(NSString *)table {
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", table];
    return [self executeQueryWithSQL:sql completion:nil];
}

/**
 * @brief 插入 Model
 */
- (void)insertModel:(id <GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion {
    [self insertModel:model isUpdateWhenExist:YES completion:completion];
}

/**
 * @brief 插入 Model
 * @param isUpdateWhenExist YES-当插入对象已存在时, 如果是使用 primaryKey, 则更新, 反之则返回错误.
 */
- (void)insertModel:(id <GLDBPersistProtocol>)model isUpdateWhenExist:(BOOL)isUpdateWhenExist completion:(GLDatabaseUpdateCompletion)completion {
    
    if (isUpdateWhenExist) {
        NSString *condition = [NSString stringWithFormat:@"%@ = %ld", [model autoIncrementName], [model autoIncrementValue]];
        [self updateModelWithModel:model withCondition:condition completion:completion];
        return;
    }
    dispatch_async(_writeQueue, ^{
        [model getInsertSQLWithCompletion:^(NSString *insertSQL, NSArray *propertyNames, NSArray *values) {
            // Faster
            [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSError *error = nil;
                [db executeUpdate:insertSQL values:values error:&error];
                if (error) {
                    if (isUpdateWhenExist) {
                        // TODO: Update
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(self, model, insertSQL, NO, error.localizedDescription);
                            }
                        });
                    }
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(self, model, insertSQL, YES, nil);
                    });
                }
            }];
            
            // Safer
//            [_dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
//                NSError *error = nil;
//                [db executeUpdate:insertSQL values:values error:&error];
//                if (error) {
//                    *rollback = YES;
//                    if (completion) {
//                        completion(self, model, insertSQL, NO, error.localizedDescription);
//                    }
//                }else {
//                    if (completion) {
//                        completion(self, model, insertSQL, YES, nil);
//                    }
//                }
//            }];
        }];
    });
    
}

/**
 * @brief 查询, 异步
 * @param condition e.g. : @"age > 10", @"name = Mike" ...
 */
- (void)findModelWithClass:(Class)class condition:(NSString *)condition completion:(GLDatabaseQueryCompletion)completion {
    
    if (!completion) {
        return;
    }
    
    NSString *tableName = [class tableName];
    NSString *sql;
    if (condition.length) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, condition];
    }else {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    }
    NSMutableArray *results = [NSMutableArray array];
    
    dispatch_async(_readQueue, ^{
        [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet *resultSet = [db executeQuery:sql];
            while (resultSet.next) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:resultSet.resultDictionary];
                
                id <GLDBPersistProtocol> model = [class yy_modelWithJSON:dic];
                if (model) {
                    [results addObject:model];                    
                }
            }
            
            [resultSet close];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(self, results, sql);
        });
    });
}

/**
 * @brief 查询, 同步
 * @param condition e.g. : @"age > 10", @"name = Mike" ...
 */
- (NSMutableArray <id <GLDBPersistProtocol>> *)findModelWithClass:(Class)class condition:(NSString *)condition {
    NSString *tableName = [class tableName];
    NSString *sql;
    if (condition.length) {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@", tableName, condition];
    }else {
        sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    }
    NSMutableArray *results = [NSMutableArray array];
    
    [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:sql];
        while (resultSet.next) {
            id <GLDBPersistProtocol> model = [class yy_modelWithJSON:resultSet.resultDictionary];
            if (model) {
                [results addObject:model];
            }
        }
        
        [resultSet close];
    }];
    return results;
}

/**
 * @brief 全量更新 Model 更方便. autoIncrement=YES, 使用AutoincrementValue 匹配, autoIncrement=NO, 使用 primaryKey匹配.
 */
- (void)updateModelWithModel:(id <GLDBPersistProtocol>)model withCompletion:(GLDatabaseUpdateCompletion)completion {
    NSString *condition;
    if ([[model class] autoIncrement]) {
        condition = [NSString stringWithFormat:@"%@ = %@", [model autoIncrementName], @([model autoIncrementValue])];
    }else {
        condition = [NSString stringWithFormat:@"primaryKey = '%@'", model.primaryKey];
    }
    [self updateModelWithModel:model withCondition:condition completion:completion];
}

/**
 * @brief 全量更新 Model 更方便.
 */
- (void)updateModelWithModel:(id <GLDBPersistProtocol>)model withCondition:(NSString *)condition completion:(GLDatabaseUpdateCompletion)completion {
//    dispatch_async(_readQueue, ^{
//    });
    BOOL needToInsert = ![[self findModelWithClass:model.class condition:condition] count];
    if (needToInsert) {
        dispatch_async(self->_writeQueue, ^{
            [self insertModel:model isUpdateWhenExist:NO completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(self, model, sql, successfully, errorMsg);
                    }
                });
            }];
        });
    }else {
        dispatch_async(self->_writeQueue, ^{
            [model getUpdateSQLWithCompletion:^(NSString *updateSQL, NSArray *names, NSArray *values) {
                [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                    
                    NSString *updateSQLFull = [NSString stringWithFormat:@"%@ WHERE %@", updateSQL, condition];
//                    BOOL result = [db executeUpdate:updateSQLFull];
                    BOOL result = [db executeUpdate:updateSQLFull withArgumentsInArray:values];
                    
                    if (!result) {
                        NSError *error = nil;
                        error = [db lastError];// lastError 不能切换线程 不然报错.
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(self, model, updateSQLFull, NO, error.localizedDescription);
                            }
                        });
                    }else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(self, model, updateSQLFull, YES, nil);
                            }
                        });
                    }
                    
                }];
            }];
        });
    }
    
}

/**
 * @brief 手动更新, 效率更高.
 * @param bindingValues A Binding Dictionary that key=propertyName, value=propertyValue.
 */
- (void)updateInTable:(NSString * _Nonnull)table withBindingValues:(NSDictionary * _Nonnull)bindingValues condition:(NSString * _Nonnull)condition completion:(GLDatabaseUpdateCompletion)completion {
    if (!bindingValues || !condition || !table) {
        return;
    }
    dispatch_async(_writeQueue, ^{
        NSMutableString *updateSQL = [NSMutableString stringWithFormat:@"UPDATE %@ SET ", table];
        NSMutableArray *keys = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        [bindingValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [keys addObject:key];
            [values addObject:[NSString stringWithFormat:@"%@", obj]];
        }];
        
        if (keys.count) {
            [updateSQL appendString: [NSString stringWithFormat:@" (%@) VALUES (%@)",
                                      [keys componentsJoinedByString:@", "],
                                      [values componentsJoinedByString:@", "]]];
        }
        [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL result = [db executeUpdate:updateSQL];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    NSError *error = [db lastError];
                    if (completion) {
                        completion(self, nil, updateSQL, NO, error.localizedDescription);
                    }
                }else {
                    if (completion) {
                        completion(self, nil, updateSQL, YES, nil);
                    }
                    
                }
            });
        }];
    });
}

/**
 * @brief 删除 Model
 */
- (void)deleteModelWithModel:(id <GLDBPersistProtocol>)model completion:(GLDatabaseDeleteCompletion)completion {
    NSString *condition;
    NSString *table = [model tableName];
    if ([[model class] autoIncrement]) {
        condition = [NSString stringWithFormat:@"%@ = %@", [model autoIncrementName], @([model autoIncrementValue])];
    }else {
        condition = [NSString stringWithFormat:@"primaryKey = '%@'", model.primaryKey];
    }
    [self deleteInTable:table withCondition:condition completion:completion];
}

/**
 * @brief 删除 Model, 通过 condition.
 */
- (void)deleteInTable:(NSString *)table withCondition:(NSString *)condition completion:(GLDatabaseDeleteCompletion)completion {
    dispatch_async(_writeQueue, ^{
        NSString *deleteSQL;
        if (condition.length) {
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", table.lowercaseString, condition];
        }else {
            deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@", table.lowercaseString];
        }
        [self->_dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL result = [db executeUpdate:deleteSQL];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!result) {
                    if (completion) {
                        NSError *error = [db lastError];
                        completion(self, NO, error.localizedDescription);
                    }
                }else {
                    if (completion) {
                        completion(self, YES, nil);
                    }
                }
            });
        }];
    });
}

#pragma mark - Setter

#pragma mark - Getter

- (BOOL)isOpened {
    return _dbQueue != nil;
}

@end
