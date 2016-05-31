//
//  GLSQLGenerator.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/5/31.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDBModelProtocol.h"

typedef enum
{
    GLSQLGeneratorSQLTypeUpdate,
    GLSQLGeneratorSQLTypeDelete
}GLSQLGeneratorSQLType;   // 查询的sql比较复杂，所以暂不支持

//typedef enum
//{
//    MMSqlGeneratorTypeCommon,
//    MMSqlGeneratorTypeDictionary
//}MMSqlGeneratorType;

@interface GLSQLGenerator : NSObject

+ (instancetype)defaultGenerator;

- (Class)getClassForModel:(id<GLDBModelProtocol>)model;

- (NSString *)generateInsertSqlWithModel:(id<GLDBModelProtocol>)model columns:(NSArray *)columns;

- (NSArray *)generateInsertArgumentsWithModel:(id<GLDBModelProtocol>)model columns:(NSArray *)columns;

- (NSString *)generateUpdateSqlWithModel:(id<GLDBModelProtocol>)model operationType:(GLSQLGeneratorSQLType)type;

- (NSString *)generateQuerySqlWithParameters:(NSDictionary *)parameters forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz;

- (NSString *)generateQuerySqlWithConditions:(NSString *)conditions forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz;

@end
