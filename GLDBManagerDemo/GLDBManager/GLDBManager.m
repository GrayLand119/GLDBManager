//
//  GLDBManager.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBManager.h"
#import "GLFMDBDatabase.h"

@interface GLDBManager()

//@property (nonatomic, strong) GLDatabase          *database;///<当前数据库

@property (nonatomic, strong) NSMutableDictionary *databaseDictionary;///<储存多个数据库 key = path

@end

@implementation GLDBManager
#pragma mark -
#pragma mark 单例
+ (instancetype)defaultManager {
    static GLDBManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[GLDBManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // 默认路径
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _path = [cacheDir stringByAppendingPathComponent:@"gldb_default.sqlite"];
        // 默认使用FMDB
        _type = GLDatabaseTypeFMDB;
        
        _databaseDictionary = [NSMutableDictionary dictionary];
        
        
    }
    
    return self;
}
#pragma mark -
#pragma mark Getter & Setter


#pragma mark -
#pragma mark 打开数据库

- (GLDatabase *)openDefaultDatabase {
    return [self openedDatabaseWithPath:_path];
}

- (GLDatabase *)openedDatabaseWithPath:(NSString *)path {
    if(!path.length) return nil;
    
    if (_type == GLDatabaseTypeNONE) return nil;
    
    // 如果已打开,直接返回
    if([_databaseDictionary.allKeys containsObject:path]){
        _path = path;
        return _databaseDictionary[path];
    }
    
    // 打开新的数据库
    _currentDB = [[GLFMDBDatabase alloc] init];
    _path = path;
    
    [_currentDB openDatabaseWithFileAtPath:path completion:nil];
    _databaseDictionary[path] = _currentDB;
    
    return _currentDB;
}

- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDatabaseOpenCompletion)completion
{
    if(completion)
    {
        [_currentDB openDatabaseWithFileAtPath:path completion:^(GLDatabase *database, NSString *path, BOOL successfully) {
            
            if(successfully && database){
                self->_databaseDictionary[path] = database;
            }
            
            completion(database, path, successfully);
        }];
    }
    else
    {
        [_currentDB openDatabaseWithFileAtPath:path completion:nil];
        
        _databaseDictionary[path] = _currentDB;
    }
}

#pragma mark -
#pragma mark 关闭数据库
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion
{
    [_currentDB closeDatabaseWithCompletion:completion];
    
    NSArray *keys = [_databaseDictionary allKeysForObject:_currentDB];
    
    [_databaseDictionary removeObjectsForKeys:keys];
}

#pragma mark -
#pragma mark 升级数据库
- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion
{
    [_currentDB upgradeBySql:sqlString completion:completion];
}

#pragma mark -
#pragma mark 创建 or 更新表
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes
{
    [_currentDB createOrUpgradeTablesWithClasses:classes];
}

#pragma mark -
#pragma mark 保存
- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_currentDB save:model completion:completion];
}

- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_currentDB saveOrUpdate:model completion:completion];
}

#pragma mark -
#pragma mark 更新
- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_currentDB update:model completion:completion];
}

- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion
{
    [_currentDB executeUpdate:sqlString completion:completion];
}

#pragma mark -
#pragma mark 删除
- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion
{
    [_currentDB removeModel:model completion:completion];
}

- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion
{
    [_currentDB removeModels:models completion:completion];
}

- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                        byId:(NSString *)objectId
                  completion:(GLDatabaseRemoveCompletion)completion
{
    [_currentDB removeModelWithClass:clazz byId:objectId completion:completion];
}

#pragma mark -
#pragma mark 查询
- (id <GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                                        byId:(NSString *)objectId
{
    return [_currentDB findModelForClass:clazz byId:objectId];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                 withConditions:(NSString *)conditions
{
    return [_currentDB findModelsForClass:clazz withConditions:conditions];
}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
            withConditions:(NSString *)conditions
                completion:(GLDatabaseQueryCompletion)completion
{
    [_currentDB findModelsForClass:clazz withConditions:conditions completion:completion];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                 withParameters:(NSDictionary *)parameters
{
    return [_currentDB findModelsForClass:clazz withParameters:parameters];
}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
            withParameters:(NSDictionary *)parameters
                completion:(GLDatabaseQueryCompletion)completion
{
    return [_currentDB findModelsForClass:clazz withParameters:parameters completion:completion];
}

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
{
    return [_currentDB executeQuery:sqlString forClass:clazz];
}

- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withCompletion:(GLDatabaseQueryCompletion)completion
{
    [_currentDB executeQuery:sqlString forClass:clazz withCompletion:completion];
}

#pragma mark -
#pragma mark 统计数量
- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions
{
    return [_currentDB countOfModelsForClass:clazz withConditions:conditions];
}

@end
