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


@interface GLDBManager : NSObject

/**
 自带默认创建的数据库, 另外可根据业务创建多个数据库并控制优先级.
 */
@property (nonatomic, strong, readonly) GLDatabase *defaultDB;///< 默认创建的一个数据库

+ (instancetype)defaultManager;

/* =============================================================
                            数据库操作
 =============================================================*/

/**
 * @brief 打开默认数据库, 使用UserId区分
 */
- (GLDatabase *)openDefaultDatabaseWithUserId:(NSString *)userId;

/**
 * @brief 根据路径自动创建并打开数据库
 */
- (GLDatabase *)openedDatabaseWithPath:(NSString *)path;

/**
 * @brief 关闭数据库
 */
- (void)closeDatabase:(GLDatabase *)database;

/*===============================================================
                            默认设置
 ===============================================================*/
- (NSString *)defaultDBDirectory;
- (NSString *)defaultDBName;
//- (NSString *)defaultDBPath;
@end
