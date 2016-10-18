//
//  GLDBManager.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBManager.h"
#import "GLFMDBDatabase.h"
#import "GLCoreDatabase.h"


@interface GLDBManager()

@property (nonatomic, strong) GLDatabase          *database;///<当前数据库

@property (nonatomic, strong) NSMutableDictionary *databaseDictionary;///<储存多个数据库 key = path

@end

@implementation GLDBManager
#pragma mark -
#pragma mark 单例
+ (instancetype)defaultManager
{
    static GLDBManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[GLDBManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        // 默认使用FMDB
        self.type = GLDatabaseTypeFMDB;
        // 默认路径
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _path = [cacheDir stringByAppendingPathComponent:@"default.sqlite"];
    }
    
    return self;
}
#pragma mark -
#pragma mark Getter & Setter
- (GLDatabase *)database
{
    return _database;
}

- (void)setType:(GLDatabaseType)type
{
    if(_type != type)
    {
        _type = type;
        
        _database = [self databaseWithType:_type];
        
        _databaseDictionary = [NSMutableDictionary dictionary];
    }
}

#pragma mark -
#pragma mark 打开数据库
- (GLDatabase *)openedDatabaseWithPath:(NSString *)path
{
    if(!path.length) return nil;
    
    if (_type == GLDatabaseTypeNONE) return nil;
    
    // 如果已打开,直接返回
    if([_databaseDictionary.allKeys containsObject:path]){
        _path = path;
        return _databaseDictionary[path];
    }
    
    // 打开新的数据库
    GLDatabase *database = [self databaseWithType:_type];
    _path = path;
    
    [database openDatabaseWithFileAtPath:path completion:nil];
    
    return database;
}

- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDatabaseOpenCompletion)completion
{
    if(completion)
    {
        [_database openDatabaseWithFileAtPath:path completion:^(GLDatabase *database, NSString *path, BOOL successfully) {
            
            if(successfully && database){
                _databaseDictionary[path] = database;
            }
            
            completion(database, path, successfully);
        }];
    }
    else
    {
        [_database openDatabaseWithFileAtPath:path completion:nil];
        
        _databaseDictionary[path] = _database;
    }
}

- (GLDatabase *)databaseWithType:(GLDatabaseType)type
{
    switch (type)
    {
        case GLDatabaseTypeFMDB:
        {
            return [[GLFMDBDatabase alloc] init];
        }
         
        case GLDatabaseTypeCoreData:
        {
            return [[GLCoreDatabase alloc] init];
        }
            
        default:
            return nil;
    }
}

#pragma mark -
#pragma mark 关闭数据库
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion
{
    [_database closeDatabaseWithCompletion:completion];
    
    NSArray *keys = [_databaseDictionary allKeysForObject:_database];
    
    [_databaseDictionary removeObjectsForKeys:keys];
}

#pragma mark -
#pragma mark 升级数据库
- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion
{
    [_database upgradeBySql:sqlString completion:completion];
}

#pragma mark -
#pragma mark 创建 or 更新表
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes
{
    [_database createOrUpgradeTablesWithClasses:classes];
}

#pragma mark -
#pragma mark 保存
- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_database save:model completion:completion];
}

- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_database saveOrUpdate:model completion:completion];
}

#pragma mark -
#pragma mark 更新
- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion
{
    [_database update:model completion:completion];
}

- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion
{
    [_database executeUpdate:sqlString completion:completion];
}

#pragma mark -
#pragma mark 删除
- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion
{
    [_database removeModel:model completion:completion];
}

- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion
{
    [_database removeModels:models completion:completion];
}

- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                        byId:(NSString *)objectId
                  completion:(GLDatabaseRemoveCompletion)completion
{
    [_database removeModelWithClass:clazz byId:objectId completion:completion];
}

#pragma mark -
#pragma mark 查询
- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                                        byId:(NSString *)objectId
{
    return [_database findModelForClass:clazz byId:objectId];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                 withConditions:(NSString *)conditions
{
    return [_database findModelsForClass:clazz withConditions:conditions];
}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
            withConditions:(NSString *)conditions
                completion:(GLDatabaseQueryCompletion)completion
{
    [_database findModelsForClass:clazz withConditions:conditions completion:completion];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
                 withParameters:(NSDictionary *)parameters
{
    return [_database findModelsForClass:clazz withParameters:parameters];
}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
            withParameters:(NSDictionary *)parameters
                completion:(GLDatabaseQueryCompletion)completion
{
    return [_database findModelsForClass:clazz withParameters:parameters completion:completion];
}



- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
{
    return [_database executeQuery:sqlString forClass:clazz];
}

- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withCompletion:(GLDatabaseQueryCompletion)completion
{
    [_database executeQuery:sqlString forClass:clazz withCompletion:completion];
}

#pragma mark -
#pragma mark 统计数量
- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions
{
    return [_database countOfModelsForClass:clazz withConditions:conditions];
}

@end
