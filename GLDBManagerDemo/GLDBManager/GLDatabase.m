//
//  GLDatabase.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDatabase.h"

@implementation GLDatabase

- (instancetype)init
{
    if(self = [super init])
    {
        _readQueue = dispatch_queue_create("com.queue.database.query", DISPATCH_QUEUE_CONCURRENT);
        
        _writeQueue = dispatch_queue_create("com.queue.database.update", DISPATCH_QUEUE_CONCURRENT);
        
        _completionQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDatabaseOpenCompletion)completion{}

- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion{}

- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes{}

- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}

- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}

- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion{}

- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion{}

- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion{}

- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId completion:(GLDatabaseRemoveCompletion)completion{}

- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion{}

- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withCompletion:(GLDatabaseQueryCompletion)completion{}

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz{return nil;}

- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId{return nil;}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions completion:(GLDatabaseQueryCompletion)completion{}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return nil;}

- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters completion:(GLDatabaseQueryCompletion)completion{}

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters{return nil;}

- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions{return 0;}

- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion{}

@end
