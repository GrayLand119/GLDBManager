//
//  GLDBPersistProtocol.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#ifndef GLDBPersistProtocol_h
#define GLDBPersistProtocol_h

@protocol GLDBPersistProtocol

@optional
/**
 * @brief 与YYModel相同, 数组中的属性不会写入数据库
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

@required

/**
 * @brief 是否使用自增长, YES-使用 modelId Integer类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement;

/**
 *  获取tableName
 *
 *  @return tableName
 */
+ (NSString *)tableName;

/**
 *  返回创建与该Model对应的表的SQL语句
 *
 *  @return 创建表的SQL语句
 */
+ (NSString *)createTableSQL;

/**
 *  返回更新与该Model对应的表的SQL语句
 *
 *  @return 升级表的SQL语句
 */
+ (NSArray <NSString *> *)upgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns;

/**
 * @brief 自定义升级表 SQL
 */
+ (NSArray <NSString *> *)customUpgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns;

/**
 *  字典类型转Model类型
 *
 *  @param dic 字典类型
 *
 *  @return Model类型
 */
+ (id<GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dic;

/**
 *  Model类型转字典类型
 *
 *  @return 字典类型
 */
- (NSMutableDictionary *)toDatabaseDictionary;

/**
 * @brief 自增长 Id
 */
- (NSUInteger)modelId;

/**
 * @brief 主键, autoIncrement=NO时使用
 */
- (NSString *)primaryKey;

@end


#endif /* GLDBPersistProtocol_h */

