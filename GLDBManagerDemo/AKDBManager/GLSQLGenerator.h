//
//  GLSQLGenerator.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/16.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDBPersistProtocol.h"

@interface GLSQLGenerator : NSObject

+ (instancetype)shareInstance;

- (Class)getClassForModel:(id<GLDBPersistProtocol>)model;

- (NSArray *)insertArgumentsWithModel:(id<GLDBPersistProtocol>)model columns:(NSArray *)columns;
- (NSString *)insertSqlWithModel:(id<GLDBPersistProtocol>)model columns:(NSArray *)columns;
- (NSString *)updateSqlWithModel:(id<GLDBPersistProtocol>)model;
- (NSString *)deleteSqlWithModel:(id<GLDBPersistProtocol>)model;
- (NSString *)querySqlWithParameters:(NSDictionary *)parameters forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz;
- (NSString *)querySqlWithConditions:(NSString *)conditions forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz;

@end
