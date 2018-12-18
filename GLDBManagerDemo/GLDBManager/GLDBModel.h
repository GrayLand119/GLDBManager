//
//  GLDBModel.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import "GLDBPersistProtocol.h"

// Check is Null
#ifndef CK_ISNULL
#define CK_ISNULL(obj, default) (obj) == nil ? (default) : (obj)
#endif

@interface GLDBModel : NSObject
<GLDBPersistProtocol>
{
    NSUInteger _modelId;
    NSString *_primaryKey;
}
@property (nonatomic, assign) NSUInteger modelId;
@property (nonatomic, strong) NSString *primaryKey;

//+ (BOOL)propertyIsOptional:(NSString *)propertyName;//overwrite JSONModel
//+ (BOOL)propertyIsIgnored:(NSString*)propertyName;

/**
 * @brief 是否使用自增长, YES-使用 modelId Integer类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement;

/**
 * @brief 表名称, 默认:类名
 */
+ (NSString *)tableName;

/**
 * @brief 创建表SQL
 */
+ (NSString *)createTableSQL;

/**
 * @brief 升级表 SQL
 */
+ (NSArray <NSString *> *)upgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns;

/**
 * @brief 自定义升级表 SQL
 */
+ (NSArray <NSString *> *)customUpgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns;

+ (id <GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dictionary;

- (NSMutableDictionary *)toDatabaseDictionary;

@end
