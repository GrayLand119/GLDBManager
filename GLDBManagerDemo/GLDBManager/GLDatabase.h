//
//  GLDatabase.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

/* =============================================================
                数据库模型的基类, 定义一些通用接口
 =============================================================*/

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "GLDBPersistProtocol.h"

#ifdef DEBUG
#   define DBLog(fmt, ...)  NSLog((@"%s [Line %d] >>>\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DBLog(...)
#endif

@class GLDatabase;

typedef void (^GLDatabaseCloseCompletion)(GLDatabase *database, BOOL isScuccessful);
typedef void (^GLDatabaseUpdateCompletion)(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully);
typedef void (^GLDatabaseRemoveCompletion)(GLDatabase *database, NSMutableArray *models, BOOL successfully);
typedef void (^GLDatabaseUpgradeCompletion)(GLDatabase *database, NSString *sql, BOOL successfully);
typedef void (^GLDatabaseQueryCompletion)(GLDatabase *database, NSMutableArray *models, NSString *sql);
typedef void (^GLDatabaseExcuteCompletion)(GLDatabase *database, id respond, BOOL isScuccessful, NSString *error);

@interface GLDatabase : NSObject

@property (nonatomic, strong) NSString *path;///< 数据库路径
@property (nonatomic, assign) BOOL isOpened;///< 是否已打开

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) dispatch_queue_t readQueue;
@property (nonatomic, strong) dispatch_queue_t writeQueue;
@property (nonatomic, strong) dispatch_queue_t completionQueue;

@property (nonatomic, strong) NSArray *allTableCached;


/**
 * @brief 打开数据库文件
 */
- (void)openDatabaseWithPath:(NSString * _Nonnull)path;

/**
 * @brief 关闭数据库
 */
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion;

/**
 * @brief 获取所有表名称
 */
- (NSArray <NSString *> *)getAllTableNameUsingCache:(BOOL)usingCache;

/*===============================================================
 Action
 ===============================================================*/

/**
 * @brief 注册: 根据Model自动创建表, 若有新字段则自动添加
 */
- (void)registTablesWithModels:(NSArray *)models;

/**
 * @brief 获取表的所有列
 */
- (NSArray <NSString *> *)allColumnsInTable:(NSString *)table;

/**
 * @brief 执行查询功能的 SQL
 * @param completion若为nil, 则同步执行, 否则为异步执行
 */
-  (NSMutableArray *)excuteQueryWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion;

//
///**
// *  建表，建过表后会记录起来，如果下次再企图建表，将跳过此条要求，
// *  如改表，请使用upgradeBySql:completion:
//    @see -upgradeBySql:completion:
// *
// *  @param classes classes description
// */
//- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes;
//
///**
// *  保存对象至数据库
// *
// *  @param model        数据库model
// *  @param completion   操作完成处理方法
// */
//- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;
//
///**
// *  更新对象至数据库
// *
// *  @param model        数据库model
// *  @param completion   操作完成处理方法
// */
//- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;
//
///**
// *  插入或更新对象至数据库
// *
// *  @param model      数据库model
// *  @param completion 操作完成处理方法
// */
//- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;
//
///**
// *  从数据库移除指定记录
// *
// *  @param model        数据库model
// *  @param completion   操作完成处理方法
// */
//- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion;
//
//- (void)removeModelWithId:(NSString *)modelId inTable:(NSString *)tableName completion:(GLDatabaseExcuteCompletion)completion;
//
///**
// *  批量删除数据库条目
// *
// *  @param models       models description
// *  @param completion   操作完成处理方法
// */
//- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion;
//
///**
// *  从数据库里移除指定id的model
// *
// *  @param objectId     指定model的id
// *  @param completion   操作完成处理方法
// */
//- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId
//                  completion:(GLDatabaseRemoveCompletion)completion;
//
//
//- (BOOL)removeAllInTable:(NSString *)tableName;
//
///**
// *  执行sql update语句
// *
// *  @param sqlString    sqlString description
// *  @param completion   操作完成处理方法
// */
//- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion;
//
///**
// *  升级数据库执行更新接口
// *
// *  @param sqlString    sql语句
// *  @param completion   操作完成处理方法
// */
//- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion;
//
///**
// *  按唯一标识查询记录
// *
// *  @param clazz    目标model类型
// *  @param objectId 目标id
// *
// *  @return 目标记录model
// */
//- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId;
//
///**
// *  按相等方式查詢，拼sql字符串的時候以＝作為操作符
// *
// *  @param clazz      要查找的model類型
// *  @param parameters 參數，key為數據庫字段，value為值
// *  @param clazz        要查的表
// *  @param completion   查询完的处理
// *
// *  @return return value description
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters
//                completion:(GLDatabaseQueryCompletion)completion;
//
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters;
//
///**
// *  比較複雜的查詢，比如大於，小於，區間
// *
// *  @param clazz      要查找的model類型
// *  @param conditions sql語句WHERE後面的部分
// *  @param completion   查询完的处理
// *
// *  @return return value description
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions
//                completion:(GLDatabaseQueryCompletion)completion;
//
//- (NSMutableArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions;
//
///**
// *  执行sql query语句，返回数组，即使要查询的是一个值，也返回一个数组
// *
// *  @param sqlString    sql语句
// *  @param clazz        要查的表
// *  @param completion   查询完的处理
// *
// *  @return MMModel数组
// */
//- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//      withCompletion:(GLDatabaseQueryCompletion)completion;
//
//- (NSMutableArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz;
//
///**
// *  计数
// *
// *  @param clazz      clazz description
// *  @param conditions conditions description
// *
// *  @return return value description
// */
//- (NSUInteger)countOfModelsForClass:(Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions;


@end
