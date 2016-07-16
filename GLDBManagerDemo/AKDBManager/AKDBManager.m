//
//  AKDBManager.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKDBManager.h"
#import "AKFMDBDatabase.h"
#import "AKCoreDatabase.h"


@interface AKDBManager()

@property (nonatomic, strong) AKDatabase          *database;///<当前数据库

@property (nonatomic, strong) NSMutableDictionary *databaseDictionary;///<储存多个数据库 key = path

@end

@implementation AKDBManager
#pragma mark -
#pragma mark 单例
+ (instancetype)defaultManager
{
    static AKDBManager *manager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[AKDBManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        // 默认使用FMDB
        self.type = AKDatabaseTypeFMDB;
        // 默认路径
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _path = [cacheDir stringByAppendingPathComponent:@"default.sqlite"];
    }
    
    return self;
}
#pragma mark -
#pragma mark Getter & Setter
- (AKDatabase *)database
{
    return _database;
}

- (void)setType:(AKDatabaseType)type
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
- (AKDatabase *)openedDatabaseWithPath:(NSString *)path
{
    if(!path.length) return nil;
    
    // 如果已打开,直接返回
    if([_databaseDictionary.allKeys containsObject:path]){
        _path = path;
        return _databaseDictionary[path];
    }
    
    // 打开新的数据库
    AKDatabase *database = [self databaseWithType:_type];
    _path = path;
    
    [database openDatabaseWithFileAtPath:path completion:nil];
    
    return database;
}

- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(AKDatabaseOpenCompletion)completion
{
    if(completion)
    {
        [_database openDatabaseWithFileAtPath:path completion:^(AKDatabase *database, NSString *path, BOOL successfully) {
            
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

- (AKDatabase *)databaseWithType:(AKDatabaseType)type
{
    switch (type)
    {
        case AKDatabaseTypeFMDB:
        {
            return [[AKFMDBDatabase alloc] init];
        }
         
        case AKDatabaseTypeCoreData:
        {
            return [[AKCoreDatabase alloc] init];
        }
            
        default:
            return nil;
    }
}

#pragma mark -
#pragma mark 关闭数据库
- (void)closeDatabaseWithCompletion:(AKDatabaseCloseCompletion)completion
{
    [_database closeDatabaseWithCompletion:completion];
    
    NSArray *keys = [_databaseDictionary allKeysForObject:_database];
    
    [_databaseDictionary removeObjectsForKeys:keys];
}

#pragma mark -
#pragma mark 升级数据库
- (void)upgradeBySql:(NSString *)sqlString completion:(AKDatabaseUpgradeCompletion)completion
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
- (void)save:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    [_database save:model completion:completion];
}

- (void)saveOrUpdate:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    [_database saveOrUpdate:model completion:completion];
}

#pragma mark -
#pragma mark 更新
- (void)update:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion
{
    [_database update:model completion:completion];
}

- (void)executeUpdate:(NSString *)sqlString completion:(AKDatabaseUpdateCompletion)completion
{
    [_database executeUpdate:sqlString completion:completion];
}

#pragma mark -
#pragma mark 删除
- (void)removeModel:(id<AKDBPersistProtocol>)model completion:(AKDatabaseRemoveCompletion)completion
{
    [_database removeModel:model completion:completion];
}

- (void)removeModels:(NSArray *)models completion:(AKDatabaseRemoveCompletion)completion
{
    [_database removeModels:models completion:completion];
}

- (void)removeModelWithClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                        byId:(NSString *)objectId
                  completion:(AKDatabaseRemoveCompletion)completion
{
    [_database removeModelWithClass:clazz byId:objectId completion:completion];
}

#pragma mark -
#pragma mark 查询
- (id<AKDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                                        byId:(NSString *)objectId
{
    return [_database findModelForClass:clazz byId:objectId];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                 withConditions:(NSString *)conditions
{
    return [_database findModelsForClass:clazz withConditions:conditions];
}

- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
            withConditions:(NSString *)conditions
                completion:(AKDatabaseQueryCompletion)completion
{
    [_database findModelsForClass:clazz withConditions:conditions completion:completion];
}



- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
                 withParameters:(NSDictionary *)parameters
{
    return [_database findModelsForClass:clazz withParameters:parameters];
}

- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
            withParameters:(NSDictionary *)parameters
                completion:(AKDatabaseQueryCompletion)completion
{
    return [_database findModelsForClass:clazz withParameters:parameters completion:completion];
}



- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
{
    return [_database executeQuery:sqlString forClass:clazz];
}

- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withCompletion:(AKDatabaseQueryCompletion)completion
{
    [_database executeQuery:sqlString forClass:clazz withCompletion:completion];
}

#pragma mark -
#pragma mark 统计数量
- (NSUInteger)countOfModelsForClass:(Class<AKDBPersistProtocol>)clazz withConditions:(NSString *)conditions
{
    return [_database countOfModelsForClass:clazz withConditions:conditions];
}

@end
