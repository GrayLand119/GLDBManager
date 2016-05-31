//
//  GLDataBase.h
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GLDataBase;
@protocol GLDataBaseProtocol;

typedef void (^GLDataBaseOpenCompletion)(GLDataBase *database, NSString *path, BOOL successfully);
typedef void (^GLDataBaseCloseCompletion)(GLDataBase *database, BOOL successfully);
typedef void (^GLDataBaseUpdateCompletion)(GLDataBase *database, id<GLDataBaseProtocol> model, NSString *sql, BOOL successfully);
typedef void (^GLDataBaseRemoveCompletion)(GLDataBase *database, NSArray *models, BOOL successfully);
typedef void (^GLDataBaseUpgradeCompletion)(GLDataBase *database, NSString *sql, BOOL successfully);
typedef void (^GLDataBaseQueryCompletion)(GLDataBase *database, NSArray *models, NSString *sql);

@interface GLDataBase : NSObject



@end
