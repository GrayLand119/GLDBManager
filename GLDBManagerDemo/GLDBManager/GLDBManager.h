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
    GLDBManagerTypeOriginal,///<系统原生
};

@interface GLDBManager : NSObject

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) GLDBManagerType type;///<使用数据库类型

@property (nonatomic, strong, readonly) GLDataBase *dataBase;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *version;


+ (instancetype)defaultManager;


@end
