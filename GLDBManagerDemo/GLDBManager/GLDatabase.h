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
#import "GLDBModel.h"

#ifdef DEBUG
#   define DBLog(fmt, ...)  NSLog((@"%s [Line %d] >>>\n" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DBLog(...)
#endif

@class GLDatabase;

typedef void (^GLDatabaseCloseCompletion)(GLDatabase *database, BOOL successfully);
typedef void (^GLDatabaseUpdateCompletion)(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg);
typedef void (^GLDatabaseDeleteCompletion)(GLDatabase *database, BOOL successfully, NSString *errorMsg);
typedef void (^GLDatabaseUpgradeCompletion)(GLDatabase *database, NSString *sql, BOOL successfully);
typedef void (^GLDatabaseQueryCompletion)(GLDatabase *database, NSMutableArray <id <GLDBPersistProtocol>> *models, NSString *sql);
typedef void (^GLDatabaseExcuteCompletion)(GLDatabase *database, id respond, BOOL successfully, NSString *errorMsg);

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

/**
 * @brief 获取表的所有列的信息
 */
- (NSArray <NSDictionary *> *)getAllColumnsInfoInTable:(NSString *)table;

/*===============================================================
 Action
 ===============================================================*/

/**
 * @brief 注册: 根据Model自动创建表, 若有新字段则自动添加, 若有自定义升级则使用自定义升级
 */
- (void)registTablesWithModels:(NSArray <Class <GLDBPersistProtocol>> *)models;

/**
 * @brief 执行查询功能的 SQL, 默认当前线程
 */
-  (NSMutableArray *)executeQueryWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion;

/**
 * @brief 执行更新功能的 SQL, 默认当前线程
 */
- (void)excuteUpdateWithSQL:(NSString *)sql completion:(GLDatabaseExcuteCompletion)completion;

/**
 * @brief 插入 Model
 */
- (void)insertModel:(id <GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;

/**
 * @brief 插入 Model
 * @param isUpdateWhenExist YES-当插入对象已存在时, 如果是使用 primaryKey, 则更新, 反之则返回错误.
 */
- (void)insertModel:(id <GLDBPersistProtocol>)model isUpdateWhenExist:(BOOL)isUpdateWhenExist completion:(GLDatabaseUpdateCompletion)completion;

/**
 * @brief 查询,
 * @param condition e.g. : @"age > 10", @"name = Mike" ...
 */
- (void)findModelWithClass:(Class <GLDBPersistProtocol>)class condition:(NSString *)condition completion:(GLDatabaseQueryCompletion)completion;

/**
 * @brief 全量更新 Model, 更方便. autoIncrement=YES, 使用modelId 匹配, autoIncrement=NO, 使用 primaryKey匹配.
 */
- (void)updateModelWithModel:(id <GLDBPersistProtocol>)model withCompletion:(GLDatabaseUpdateCompletion)completion;

/**
 * @brief 全量更新 Model, 更方便.
 */
- (void)updateModelWithModel:(id <GLDBPersistProtocol>)model withCondition:(NSString *)condition completion:(GLDatabaseUpdateCompletion)completion;

/**
 * @brief 手动更新, 效率更高.
 * @param bindingValues A Binding Dictionary that key=propertyName, value=propertyValue.
 */
- (void)updateInTable:(NSString * _Nonnull)table withBindingValues:(NSDictionary * _Nonnull)bindingValues condition:(NSString * _Nonnull)condition completion:(GLDatabaseUpdateCompletion)completion;

/**
 * @brief 删除 Model
 */
- (void)deleteModelWithModel:(id <GLDBPersistProtocol>)model completion:(GLDatabaseDeleteCompletion)completion;

/**
 * @brief 删除 Model, 通过 condition.
 */
- (void)deleteInTable:(NSString *)table withCondition:(NSString *)condition completion:(GLDatabaseDeleteCompletion)completion;

@end
