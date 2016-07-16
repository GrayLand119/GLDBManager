//
//  AKDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKDatabase.h"

@implementation AKDatabase

- (instancetype)init
{
    if(self = [super init])
    {
        _readQueue = dispatch_queue_create("com.icomwell.queue.database.query", DISPATCH_QUEUE_CONCURRENT);
        
        _writeQueue = dispatch_queue_create("com.icomwell.queue.database.update", DISPATCH_QUEUE_CONCURRENT);
        
        _completionQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(AKDatabaseOpenCompletion)completion{}

- (void)closeDatabaseWithCompletion:(AKDatabaseCloseCompletion)completion{}

- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes{}

- (void)save:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion{}

- (void)update:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion{}

- (void)saveOrUpdate:(id<AKDBPersistProtocol>)model completion:(AKDatabaseUpdateCompletion)completion{}

- (void)removeModel:(id<AKDBPersistProtocol>)model completion:(AKDatabaseRemoveCompletion)completion{}

- (void)removeModels:(NSArray *)models completion:(AKDatabaseRemoveCompletion)completion{}

- (void)removeModelWithClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz byId:(NSString *)objectId completion:(AKDatabaseRemoveCompletion)completion{}

- (void)executeUpdate:(NSString *)sqlString completion:(AKDatabaseUpdateCompletion)completion{}

- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withCompletion:(AKDatabaseQueryCompletion)completion{}

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz{return nil;}

- (id<AKDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz byId:(NSString *)objectId{return nil;}

- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withConditions:(NSString *)conditions completion:(AKDatabaseQueryCompletion)completion{}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return nil;}

- (void)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters completion:(AKDatabaseQueryCompletion)completion{}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters{return nil;}

- (NSUInteger)countOfModelsForClass:(Class<AKDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return 0;}

- (void)upgradeBySql:(NSString *)sqlString completion:(AKDatabaseUpgradeCompletion)completion{}

@end
