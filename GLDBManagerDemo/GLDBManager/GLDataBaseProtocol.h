//
//  GLDataBaseProtocol.h
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#ifndef GLDataBaseProtocol_h
#define GLDataBaseProtocol_h


#endif /* GLDataBaseProtocol_h */


#include "GLDataBase.h"
#include "GLDBModelProtocol.h"

@class GLDataBase;

typedef void (^GLDataBaseOpenCompletion)(GLDataBase *database, NSString *path, BOOL successfully);
typedef void (^GLDataBaseCloseCompletion)(GLDataBase *database, BOOL successfully);
typedef void (^GLDataBaseUpdateCompletion)(GLDataBase *database, id<GLDBModelProtocol> model, NSString *sql, BOOL successfully);
typedef void (^GLDataBaseRemoveCompletion)(GLDataBase *database, NSArray *models, BOOL successfully);
typedef void (^GLDataBaseUpgradeCompletion)(GLDataBase *database, NSString *sql, BOOL successfully);
typedef void (^GLDataBaseQueryCompletion)(GLDataBase *database, NSArray *models, NSString *sql);

@protocol GLDataBaseProtocol <NSObject>

@required

/**
 *  打开数据库文件
 *
 *  @param path         path description
 *  @param completion   操作完成处理方法
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDataBaseOpenCompletion)completion;

/**
 *  建表，建过表后会记录起来，如果下次再企图建表，将跳过此条要求，
 *  如改表，请使用@see -upgradeBySql:completion:
 *
 *  @param classes classes description
 */
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes;

/**
 *  关闭数据库
 *
 *  @param completion   操作完成处理方法
 */
- (void)closeDatabaseWithCompletion:(GLDataBaseCloseCompletion)completion;

/**
 *  保存对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)save:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion;

/**
 *  更新对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)update:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion;

/**
 *  插入或更新对象至数据库
 *
 *  @param model      数据库model
 *  @param completion 操作完成处理方法
 */
- (void)saveOrUpdate:(id<GLDBModelProtocol>)model completion:(GLDataBaseUpdateCompletion)completion;

/**
 *  从数据库移除指定记录
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)removeModel:(id<GLDBModelProtocol>)model completion:(GLDataBaseRemoveCompletion)completion;

/**
 *  批量删除数据库条目
 *
 *  @param models       models description
 *  @param completion   操作完成处理方法
 */
- (void)removeModels:(NSArray *)models completion:(GLDataBaseRemoveCompletion)completion;

/**
 *  从数据库里移除指定id的model
 *
 *  @param objectId     指定model的id
 *  @param completion   操作完成处理方法
 */
- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz byId:(NSString *)objectId
                  completion:(GLDataBaseRemoveCompletion)completion;


/**
 *  执行sql update语句
 *
 *  @param sqlString    sqlString description
 *  @param completion   操作完成处理方法
 */
- (void)executeUpdate:(NSString *)sqlString completion:(GLDataBaseUpdateCompletion)completion;

/**
 *  升級數據庫版本時需要用到的接口
 *
 *  @param sqlString    sql語句
 *  @param completion   操作完成处理方法
 */
- (void)upgradeBySql:(NSString *)sqlString completion:(GLDataBaseUpgradeCompletion)completion;

/**
 *  按唯一标识查询记录
 *
 *  @param clazz    目标model类型
 *  @param objectId 目标id
 *
 *  @return 目标记录model
 */
- (id<GLDBModelProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz byId:(NSString *)objectId;

/**
 *  按相等方式查詢，拼sql字符串的時候以＝作為操作符
 *
 *  @param clazz      要查找的model類型
 *  @param parameters 參數，key為數據庫字段，value為值
 *  @param clazz        要查的表
 *  @param completion   查询完的处理
 *
 *  @return return value description
 */
- (void)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withParameters:(NSDictionary *)parameters
                completion:(GLDataBaseQueryCompletion)completion;

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withParameters:(NSDictionary *)parameters;

/**
 *  比較複雜的查詢，比如大於，小於，區間
 *
 *  @param clazz      要查找的model類型
 *  @param conditions sql語句WHERE後面的部分
 *  @param completion   查询完的处理
 *
 *  @return return value description
 */
- (void)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withConditions:(NSString *)conditions
                completion:(GLDataBaseQueryCompletion)completion;

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz withConditions:(NSString *)conditions;

/**
 *  执行sql query语句，返回数组，即使要查询的是一个值，也返回一个数组
 *
 *  @param sqlString    sql语句
 *  @param clazz        要查的表
 *  @param completion   查询完的处理
 *
 *  @return MMModel数组
 */
- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz
      withCompletion:(GLDataBaseQueryCompletion)completion;

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBModelProtocol>)clazz;

/**
 *  计数
 *
 *  @param clazz      clazz description
 *  @param conditions conditions description
 *
 *  @return return value description
 */
- (NSUInteger)countOfModelsForClass:(Class<GLDBModelProtocol>)clazz withConditions:(NSString *)conditions;


@end