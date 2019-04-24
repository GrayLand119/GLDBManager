//
//  GLDBPersistProtocol.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <YYModel/YYModel.h>

#ifndef GLDBPersistProtocol_h
#define GLDBPersistProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol GLDBPersistProtocol <YYModel>

@optional
/**
 * @brief 数组中的属性不会写入数据库
 */
+ (NSArray <NSString *> *)glBlackList;

@required

/**
 * @brief 是否使用自增长, YES-使用 modelId Integer类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement;
- (BOOL)autoIncrement;

/**
 自定义自增长主键名称和值
 */
+ (NSString *)autoIncrementName;
- (NSString *)autoIncrementName;
- (NSInteger)autoIncrementValue;

/**
 自定义主键名称和值
 */
+ (NSString *)primaryKeyName;
- (NSString *)primaryKeyName;
- (NSString *)primaryKeyValue;

/**
 *  获取tableName
 *
 *  @return tableName
 */
+ (NSString *)tableName;
- (NSString *)tableName;
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
 *  Model类型转字典类型
 *
 *  @return 字典类型
 */
- (NSMutableDictionary *)toDatabaseDictionary;

///**
// * @brief 自增长 Id
// */
//- (NSUInteger)modelId;
//
///**
// * @brief 主键, autoIncrement=NO时使用
// */
//- (NSString *)primaryKey;

/**
 * @brief 插入语句
 */
- (void)getInsertSQLWithCompletion:(void (^)(NSString *insertSQL, NSArray * _Nullable propertyNames, NSArray * _Nullable values))completion;

/**
 * @brief runtime 生成更新语句.
 */
- (void)getUpdateSQLWithCompletion:(void (^)(NSString *updateSQL, NSArray *names, NSArray *values))completion;

@end

NS_ASSUME_NONNULL_END

#endif /* GLDBPersistProtocol_h */

