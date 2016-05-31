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



@class GLDataBase

@protocol GLDataBaseProtocol <NSObject>

@required

/**
 *  打开数据库文件
 *
 *  @param path         path description
 *  @param completion   操作完成处理方法
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(MMDatabaseOpenCompletion)completion;

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
- (void)closeDatabaseWithCompletion:(MMDatabaseCloseCompletion)completion;

/**
 *  保存对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)save:(id<MMPersistable>)model completion:(MMDatabaseUpdateCompletion)completion;

/**
 *  更新对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)update:(id<MMPersistable>)model completion:(MMDatabaseUpdateCompletion)completion;

/**
 *  插入或更新对象至数据库
 *
 *  @param model      数据库model
 *  @param completion 操作完成处理方法
 */
- (void)saveOrUpdate:(id<MMPersistable>)model completion:(MMDatabaseUpdateCompletion)completion;

/**
 *  从数据库移除指定记录
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)removeModel:(id<MMPersistable>)model completion:(MMDatabaseRemoveCompletion)completion;

/**
 *  批量删除数据库条目
 *
 *  @param models       models description
 *  @param completion   操作完成处理方法
 */
- (void)removeModels:(NSArray *)models completion:(MMDatabaseRemoveCompletion)completion;

/**
 *  从数据库里移除指定id的model
 *
 *  @param objectId     指定model的id
 *  @param completion   操作完成处理方法
 */
- (void)removeModelWithClass:(__unsafe_unretained Class<MMPersistable>)clazz byId:(NSString *)objectId
                  completion:(MMDatabaseRemoveCompletion)completion;


/**
 *  执行sql update语句
 *
 *  @param sqlString    sqlString description
 *  @param completion   操作完成处理方法
 */
- (void)executeUpdate:(NSString *)sqlString completion:(MMDatabaseUpdateCompletion)completion;

/**
 *  升級數據庫版本時需要用到的接口
 *
 *  @param sqlString    sql語句
 *  @param completion   操作完成处理方法
 */
- (void)upgradeBySql:(NSString *)sqlString completion:(MMDatabaseUpgradeCompletion)completion;

/**
 *  按唯一标识查询记录
 *
 *  @param clazz    目标model类型
 *  @param objectId 目标id
 *
 *  @return 目标记录model
 */
- (id<MMPersistable>)findModelForClass:(__unsafe_unretained Class<MMPersistable>)clazz byId:(NSString *)objectId;

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
- (void)findModelsForClass:(__unsafe_unretained Class<MMPersistable>)clazz withParameters:(NSDictionary *)parameters
                completion:(MMDatabaseQueryCompletion)completion;

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<MMPersistable>)clazz withParameters:(NSDictionary *)parameters;

/**
 *  比較複雜的查詢，比如大於，小於，區間
 *
 *  @param clazz      要查找的model類型
 *  @param conditions sql語句WHERE後面的部分
 *  @param completion   查询完的处理
 *
 *  @return return value description
 */
- (void)findModelsForClass:(__unsafe_unretained Class<MMPersistable>)clazz withConditions:(NSString *)conditions
                completion:(MMDatabaseQueryCompletion)completion;

- (NSArray *)findModelsForClass:(__unsafe_unretained Class<MMPersistable>)clazz withConditions:(NSString *)conditions;

/**
 *  执行sql query语句，返回数组，即使要查询的是一个值，也返回一个数组
 *
 *  @param sqlString    sql语句
 *  @param clazz        要查的表
 *  @param completion   查询完的处理
 *
 *  @return MMModel数组
 */
- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<MMPersistable>)clazz
      withCompletion:(MMDatabaseQueryCompletion)completion;

- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<MMPersistable>)clazz;

/**
 *  计数
 *
 *  @param clazz      clazz description
 *  @param conditions conditions description
 *
 *  @return return value description
 */
- (NSUInteger)countOfModelsForClass:(Class<MMPersistable>)clazz withConditions:(NSString *)conditions;


@end