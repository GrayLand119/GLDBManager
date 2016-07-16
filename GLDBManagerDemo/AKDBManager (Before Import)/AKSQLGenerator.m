//
//  AKSQLGenerator.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/16.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKSQLGenerator.h"

#define AK_SHOW_DATABASE_DEBUG 0

typedef NS_ENUM(NSUInteger, AKSQLGeneratorType) {
    AKSQLGeneratorTypeUpdate,
    AKSQLGeneratorTypeDelete
};

@implementation AKSQLGenerator

+ (instancetype)shareInstance
{
    static AKSQLGenerator *generator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generator = [[AKSQLGenerator alloc] init];
    });
    
    return generator;
}

- (Class)getClassForModel:(id<AKDBPersistProtocol>)model
{
    NSString *className = [NSString stringWithUTF8String:object_getClassName(model)];

    return NSClassFromString(className);
}

- (NSArray *)insertArgumentsWithModel:(id<AKDBPersistProtocol>)model columns:(NSArray *)columns
{
    NSDictionary *dic = [model toDatabaseDictionary];
    NSMutableArray *arguments = [NSMutableArray array];
    
    [columns enumerateObjectsUsingBlock:^(NSString *column, NSUInteger idx, BOOL *stop) {
        [arguments addObject:dic[column]];
    }];
    
    return arguments;
}

- (NSString *)insertSqlWithModel:(id<AKDBPersistProtocol>)model columns:(NSArray *)columns
{
    Class clazz = [self getClassForModel:model];
    NSString *tableName = [clazz tableName];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    // INSERT INTO _tableName_ (_columnName_ , _columnName_) VALUES (?, ?)
    [result appendFormat:@"INSERT INTO %@ (", tableName];
    [result appendFormat:@"%@) VALUES (", [columns componentsJoinedByString:@", "]];
    
#ifdef DEBUG
    NSMutableString *__nothing = [[NSMutableString alloc] initWithString:result];
    NSDictionary *dic = [model toDatabaseDictionary];
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

- (NSString *)updateSqlWithModel:(id<AKDBPersistProtocol>)model
{
    return [self sqlWithModel:model operationType:AKSQLGeneratorTypeUpdate];
}

- (NSString *)deleteSqlWithModel:(id<AKDBPersistProtocol>)model
{
    return [self sqlWithModel:model operationType:AKSQLGeneratorTypeDelete];
}

- (NSString *)sqlWithModel:(id<AKDBPersistProtocol>)model operationType:(AKSQLGeneratorType)type
{
    Class clazz = [self getClassForModel:model];
    
    NSString *tableName = [clazz tableName];
    
    NSMutableDictionary *dic = [model toDatabaseDictionary];
    
    NSMutableString *result = [[NSMutableString alloc] init];
    
    switch (type)
    {
        case AKSQLGeneratorTypeDelete:
        {
            [result appendFormat:@"DELETE FROM %@ WHERE modelId = '%@'", tableName, [model modelId]];
            
            break;
        }
        case AKSQLGeneratorTypeUpdate:
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
            
            if (AK_SHOW_DATABASE_DEBUG) {
                NSLog(@"update~~~~~%@", __nothing);
            }
#endif
            break;
        }
    }
    
    return result;
}

- (NSString *)querySqlWithParameters:(NSDictionary *)parameters forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
{
    NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"SELECT * FROM %@ WHERE ", [clazz tableName]];
    
    [parameters.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        id value = parameters[key];
        
        if([value isKindOfClass:[NSNumber class]]){
            [result appendFormat:@"%@ = %f", key, [value doubleValue]];
        }else if([value isKindOfClass:[NSString class]]){
            [result appendFormat:@"%@ = '%@'", key, value];
        }
        
        if(idx+1 < parameters.allKeys.count){
            [result appendString:@" AND "];
        }
    }];
    
    if (AK_SHOW_DATABASE_DEBUG) {
        NSLog(@".....fmdb.query....[%@]", result);
    }
    
    return result;
}

- (NSString *)querySqlWithConditions:(NSString *)conditions forClass:(__unsafe_unretained Class<AKDBPersistProtocol>)clazz
{
    conditions = [conditions stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(   [conditions rangeOfString:@"ORDER " options:NSCaseInsensitiveSearch].location == 0
       || [conditions rangeOfString:@"GROUP " options:NSCaseInsensitiveSearch].location == 0)
    {
        conditions = [NSString stringWithFormat:@"1=1 %@", conditions];
    }
    
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@", [clazz tableName], conditions];
    
    if (AK_SHOW_DATABASE_DEBUG) {
        NSLog(@".....fmdb.query....[%@]", sql);
    }
    
    return sql;
}

@end
