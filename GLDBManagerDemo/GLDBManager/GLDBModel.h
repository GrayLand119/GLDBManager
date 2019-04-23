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

/*===============================================================
 通过 + (BOOL)autoIncrement; 判断使用自增长或主键.
 ===============================================================*/
@property (nonatomic, assign) NSUInteger modelId;///< 自增长类型时使用的 Id
@property (nonatomic, strong) NSString *primaryKey;///< 非自增长类型时使用的 Key

@property (nonatomic, strong) NSSet *cachedBlackListPropertys;
/**
 * @brief 是否使用自增长, YES-使用 modelId NSUInteger类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement;
- (BOOL)autoIncrement;

/**
 自增长 Id 字段名称, 重写方法以修改名称, 默认 modelId.
 */
+ (NSString *)autoIncrementName;
- (NSString *)autoIncrementName;

- (NSInteger)autoIncrementValue;

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


- (NSMutableDictionary *)toDatabaseDictionary;

@end
