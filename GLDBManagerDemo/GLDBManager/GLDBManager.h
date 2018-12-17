//
//  GLDBManager.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDatabase.h"
#import "GLDBPersistProtocol.h"


/* =============================================================
                统一增删改查接口, 支持多类型数据库
 =============================================================*/
typedef NS_ENUM(NSUInteger, GLDatabaseType) {
    GLDatabaseTypeNONE,
    GLDatabaseTypeFMDB,
    GLDatabaseTypeCoreData
};

@interface GLDBManager : NSObject

@property (nonatomic, assign) GLDatabaseType         type;

@property (nonatomic, assign) BOOL                   opened;

@property (nonatomic, strong, readonly) GLDatabase  *currentDB;

@property (nonatomic, strong) NSString              *path;

@property (nonatomic, strong) NSString              *version;

/* =============================================================
                            接口
 =============================================================*/
+ (instancetype)defaultManager;


/* =============================================================
                            数据库操作
 =============================================================*/
/**
 *  打开数据库
 */
- (GLDatabase *)openDefaultDatabase;
- (GLDatabase *)openedDatabaseWithPath:(NSString *)path;

- (void)openDatabaseWithFileAtPath:(NSString *)path
                        completion:(GLDatabaseOpenCompletion)completion;

///**
// *  关闭当前数据库
// *
// *  @param completion   操作完成处理方法
// */
//- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion;
//
///**
// *  升级数据库调用接口
// *
// *  @param sqlString    sql語句
// *  @param completion   操作完成处理方法
// */
//- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion;
//
///* =============================================================
//                            表操作
// =============================================================*/
///**
// *  建表 - 建过表后会记录起来，如果下次再企图建表，将跳过.
// *  如改表，请使用-upgradeBySql:completion:
// *  @see -upgradeBySql:completion:
// *
// *  必须实现了MMPersistable协议才可以入库
// *
// *  @param classes
// */
//- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes;
//
//
///* =============================================================
//                            数据操作
// =============================================================*/
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
///**
// *  执行sql update语句
// *
// *  @param sqlString    sqlString description
// *  @param completion   操作完成处理方法
// */
//- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion;
//
///**
// *  按唯一标识查询记录
// *
// *  @param clazz    目标model类型
// *  @param objectId 目标id (modelId)
// *
// *  @return 目标记录model
// */
//- (id<GLDBPersistProtocol>)findModelForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId;
//
///**
// *  按相等方式查詢，拼sql字符串的時候以＝作為操作符
// *
// *  @param clazz        要查找的model類型
// *  @param parameters   参数, "age = 18" ==> @{age : @18}
// *  @param completion   查询完的处理
// *
// *  @return return value description
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters
//                completion:(GLDatabaseQueryCompletion)completion;
//
//- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withParameters:(NSDictionary *)parameters;
//
///**
// *  比較複雜的查詢，比如大於，小於，區間
// *
// *  @param clazz      要查找的model類型
// *  @param conditions sql語句WHERE後面的部分
// *  @param completion   查询完的处理
// *
// */
//- (void)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions
//                completion:(GLDatabaseQueryCompletion)completion;
//
//- (NSArray *)findModelsForClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz withConditions:(NSString *)conditions;
//
///**
// *  执行sql query语句，返回数组，即使要查询的是一个值，也返回一个数组
// *
// *  @param sqlString    sql语句
// *  @param clazz        要查的表
// *  @param completion   查询完的处理
// *
// */
//- (void)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz
//      withCompletion:(GLDatabaseQueryCompletion)completion;
//
//- (NSArray *)executeQuery:(NSString *)sqlString forClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz;
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
