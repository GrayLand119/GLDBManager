//
//  GLSQLGenerator.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/5/31.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLSQLGenerator.h"

#define MM_SHOW_DATABASE_DEBUG 0

@implementation GLSQLGenerator

+ (instancetype)defaultGenerator
{
    static GLSQLGenerator *generator;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        generator = [[GLSQLGenerator alloc] init];
    });
    
    return generator;
}

- (Class)getClassForModel:(id<GLDBModelProtocol>)model
{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(model)];
    
    return NSClassFromString(className);
}

- (NSArray *)generateInsertArgumentsWithModel:(id<GLDBModelProtocol>)model columns:(NSArray *)columns
{
    NSDictionary *dic = [model toDictionary];
    
    NSMutableArray *arguments = [NSMutableArray array];
    
    [columns enumerateObjectsUsingBlock:^(NSString *column, NSUInteger idx, BOOL *stop) {
        
        [arguments addObject:dic[column]];
    }];
    
    return arguments;
}

- (NSString *)generateInsertSqlWithModel:(id<GLDBModelProtocol>)model columns:(NSArray *)columns
{
    Class clazz = [self getClassForModel:model];
    NSString *tableName = [clazz tableName];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [result appendFormat:@"INSERT INTO %@ (", tableName];
    
    [result appendFormat:@"%@) VALUES (", [columns componentsJoinedByString:@", "]];
    
#ifdef DEBUG
    
    NSMutableString *__nothing = [[NSMutableString alloc] initWithString:result];
    
    NSDictionary *dic = [model toDictionary];
#endif
    
    
    [columns enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        [result appendFormat:@"?"];
        
#ifdef DEBUG
        
        id value = dic[key];
        if([value isKindOfClass:[NSString class]])
        {
            [__nothing appendFormat:@"'%@'", value];
        }
        else if([value isKindOfClass:[NSNumber class]])
        {
            [__nothing appendFormat:@"%f", [value doubleValue]];
        }
        else if([value isKindOfClass:[NSNull class]])
        {
            [__nothing appendFormat:@"NULL"];
        }
#endif
        
        if(idx+1 < columns.count)
        {
            [result appendString:@", "];
            
#ifdef DEBUG
            
            [__nothing appendString:@", "];
#endif
        }
    }];
    
    [result appendFormat:@")"];
    
#ifdef DEBUG
    
    [__nothing appendFormat:@")"];
    
    NSLog(@"insert~~~~~%@", __nothing);
#endif
    
    return result;
}

- (NSString *)generateUpdateSqlWithModel:(id<GLDBModelProtocol>)model operationType:(GLSQLGeneratorSQLType)type
{
    Class clazz = [self getClassForModel:model];
    
    NSString *tableName = [clazz tableName];
    
    NSMutableDictionary *dic = [model toDictionary];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    switch (type)
    {
        case GLSQLGeneratorSQLTypeDelete  :
        {
            [result appendFormat:@"DELETE FROM %@ WHERE modelId = '%@'", tableName, [model modelId]];
            
            break;
        }
        case GLSQLGeneratorSQLTypeUpdate  :
        {
            [result appendFormat:@"UPDATE %@ SET ", tableName];
            
#ifdef DEBUG
            NSMutableString *__nothing = [[NSMutableString alloc] initWithString:result];
#endif
            [dic.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
                
                [result appendFormat:@"%@ = :%@", key, key];
                
#ifdef DEBUG
                
                id value = dic[key];
                if([value isKindOfClass:[NSString class]])
                {
                    [__nothing appendFormat:@"%@ = '%@'", key, value];
                }
                else if([value isKindOfClass:[NSNumber class]])
                {
                    [__nothing appendFormat:@"%@ = %ld", key, [value longValue]];
                }
                else if([value isKindOfClass:[NSNull class]])
                {
                    [__nothing appendFormat:@"%@ = NULL", key];
                }
#endif
                
                if(idx+1 < dic.allKeys.count)
                {
                    [result appendString:@", "];
                    
#ifdef DEBUG
                    [__nothing appendString:@", "];
#endif
                }
            }];
            
            [result appendFormat:@" WHERE modelId = '%@'", [model modelId]];
            
#ifdef DEBUG
            [__nothing appendFormat:@" WHERE modelId = '%@'", [model modelId]];
            
            if (MM_SHOW_DATABASE_DEBUG) {
                NSLog(@"update~~~~~%@", __nothing);
            }
#endif
            break;
        }
    }
    
    return result;
}

- (NSString *)generateQuerySqlWithParameters:(NSDictionary *)parameters forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
{
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ", [clazz tableName]];
    
    [parameters.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        id value = parameters[key];
        
        if([value isKindOfClass:[NSNumber class]])
        {
            [result appendFormat:@"%@ = %f", key, [value doubleValue]];
        }
        else if([value isKindOfClass:[NSString class]])
        {
            [result appendFormat:@"%@ = '%@'", key, value];
        }
        
        if(idx+1 < parameters.allKeys.count)
        {
            [result appendString:@" AND "];
        }
    }];
    if (MM_SHOW_DATABASE_DEBUG) {
        NSLog(@".....fmdb.query....[%@]", result);
    }
    
    return result;
}

- (NSString *)generateQuerySqlWithConditions:(NSString *)conditions forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
{
    conditions = [conditions stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(   [conditions rangeOfString:@"ORDER " options:NSCaseInsensitiveSearch].location == 0
       || [conditions rangeOfString:@"GROUP " options:NSCaseInsensitiveSearch].location == 0)
    {
        conditions = [NSString stringWithFormat:@"1=1 %@", conditions];
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@", [clazz tableName], conditions];
    
    if (MM_SHOW_DATABASE_DEBUG) {
        NSLog(@".....fmdb.query....[%@]", sql);
    }
    
    return sql;
}

@end
