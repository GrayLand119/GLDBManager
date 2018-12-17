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

@property (nonatomic, strong, readonly) GLDatabase *defaultDB;

+ (instancetype)defaultManager;

/* =============================================================
                            数据库操作
 =============================================================*/

/**
 * @brief 打开默认数据库
 */
- (GLDatabase *)openDefaultDatabase;

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
- (NSString *)defaultDBPath;
@end
