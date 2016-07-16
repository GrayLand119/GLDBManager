//
//  AKSQLGenerator.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/16.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKDBPersistProtocol.h"

@interface AKSQLGenerator : NSObject

+ (instancetype)shareInstance;

- (Class)getClassForModel:(id<AKDBPersistProtocol>)model;

- (NSArray *)insertArgumentsWithModel:(id<AKDBPersistProtocol>)model columns:(NSArray *)columns;
- (NSString *)insertSqlWithModel:(id<AKDBPersistProtocol>)model columns:(NSArray *)columns;
- (NSString *)updateSqlWithModel:(id<AKDBPersistProtocol>)model;
- (NSString *)deleteSqlWithModel:(id<AKDBPersistProtocol>)model;
- (NSString *)querySqlWithParameters:(NSDictionary *)parameters forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz;
- (NSString *)querySqlWithConditions:(NSString *)conditions forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz;

@end
