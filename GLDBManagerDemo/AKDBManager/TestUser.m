//
//  TestUser.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

/**
 *  当model和JSONModel不匹配时进行转换
 *
 *  @return JSONKeyMapper转换器
 */
+ (JSONKeyMapper *)keyMapper
{
    JSONKeyMapper *mapper = [[JSONKeyMapper alloc] initWithDictionary:@{}];
    
    return mapper;
}

+ (BOOL)propertyIsIgnored:(NSString*)propertyName
{
    return [@[@"cachePWD"] containsObject:propertyName];
}

#pragma mark -
#pragma Public

- (NSString *)modelId
{
    return _modelId;
}

#pragma mark -
#pragma AKDBPersistProtocol
+ (id<AKDBPersistProtocol>)modelWithDatabaseDictionary:(NSDictionary *)dic
{
    return [[self.class alloc] initWithDictionary:dic error:nil];
}

- (NSMutableDictionary *)toDatabaseDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self toDictionary]];
    
    return result;
}


+ (NSString *)tableName
{
    return NSStringFromClass(self.class).lowercaseString;
}

+ (NSString *)creationSql
{
    //TODO: 使用Runtime自动生成
    
    return
    [NSString stringWithFormat:
     @"CREATE TABLE IF NOT EXISTS %@"
     "("
     "modelId TEXT PRIMARY KEY UNIQUE,"
     "name TEXT, "
     "age INTEGER"
     ")"
     ,
     [[self class] tableName]
     ];
}

+ (NSArray *)upgradeSqls
{
    //TODO: 使用Runtime自动生成
    
    return @[
             [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN name TEXT DEFAULT(0)", [[self class] tableName]],
             [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN age INTEGER", [[self class] tableName]]
             ];
}
@end
