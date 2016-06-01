//
//  GLDBManager.h
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/25.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GLDataBase.h"
#import "GLDBModelProtocol.h"

typedef NS_ENUM(NSUInteger, GLDBManagerType) {
    GLDBManagerTypeFMDB,///<FMDB
    GLDBManagerTypeCoreData,///<系统原生,待完成
};

@interface GLDBManager : NSObject

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) GLDBManagerType type;///<使用数据库类型

@property (nonatomic, strong, readonly) GLDataBase *dataBase;
@property (nonatomic, strong) NSMutableDictionary *databaseDictionary;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *version;


+ (instancetype)defaultManager;


/**
 *  打开数据库
 *
 *  @param path 数据库路径, nil 使用默认路径
 *  @param completion
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDataBaseOpenCompletion)completion;

/**
 *  关闭数据库
 *
 *  @param completion
 */
- (void)closeDatabaseWithCompletion:(GLDataBaseCloseCompletion)completion;

@end
