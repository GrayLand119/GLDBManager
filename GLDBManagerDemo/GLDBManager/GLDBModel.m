//
//  GLDBModel.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBModel.h"
#import <objc/runtime.h>

//TODO: 启动时,是否使用数据库升级.若APP_DATABASE_UPDATE == 1,则自动生成更新表的SQL语句
#define APP_DATABASE_UPDATE 1

@implementation GLDBModel

+ (NSString *)uuidString {
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return nil;
}

#pragma mark - GLDBModelProtocol

+ (NSString *)tableName {
    return NSStringFromClass(self.class).lowercaseString;
}

/**
 * @brief 是否使用自增长, YES-使用 modelId Integer类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement {
    return YES;
}

+ (NSSet *)objectProperty {
    static NSSet *_objectProperty = nil;
    if (!_objectProperty) {
        _objectProperty = [NSSet setWithArray:@[@"hash", @"superclass", @"description", @"debugDescription"]];
    }
    return _objectProperty;
}

/**
 * @brief 创建表SQL
 */
+ (NSString *)createTableSQL {
    
    NSMutableString *mStr =
    [[NSMutableString alloc] initWithString:
     [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", [[self class] tableName]]];
    if ([self autoIncrement]) {
        [mStr appendString:@"(modelId INTEGER PRIMARY KEY AUTOINCREMENT, "];
    }else {
        [mStr appendString:@"(primaryKey TEXT PRIMARY KEY UNIQUE, "];
    }
    
    NSArray *blackList = [[self class] modelPropertyBlacklist];
    NSSet *blackSet;
    if ([blackList count] > 0) {
        blackSet = [NSSet setWithArray:blackList];
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    if (properties) {
        NSSet *objectPropertys = [self objectProperty];
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            NSString *typeEncoding = info.typeEncoding;
            if (blackSet && [blackSet containsObject:info.name]) {
                continue;
            }
            if ([objectPropertys containsObject:info.name]) {
                continue;
            }
            if ([typeEncoding containsString:@"NSString"]) { // String -> TEXT
                [mStr appendString:[NSString stringWithFormat:@"%@ TEXT,", info.name]];
            }else if ([@"islqQISLB" containsString:typeEncoding]) { // INTEGER
                [mStr appendString:[NSString stringWithFormat:@"%@ INTEGER,", info.name]];
            }else if ([@"df" containsString:typeEncoding]) {// float double -> REAL
                [mStr appendString:[NSString stringWithFormat:@"%@ REAL,", info.name]];
            }else { // None
                [mStr appendString:[NSString stringWithFormat:@"%@ NONE,", info.name]];
            }
        }
        free(properties);
    }
    
    [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)];
    [mStr appendString:@")"];
    
    return mStr;
}

/**
 * @brief 升级表 SQL
 */
+ (NSArray <NSString *> *)upgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns {
    
    NSMutableArray *sqlArray = [NSMutableArray array];
    
    NSArray *blackList = [[self class] modelPropertyBlacklist];
    NSSet *blackSet;
    if ([blackList count] > 0) {
        blackSet = [NSSet setWithArray:blackList];
    }
    
    NSSet *oldColSet = [NSSet setWithArray:oldColumns];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    if (properties) {
        NSSet *objectPropertys = [self objectProperty];
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            
            if (blackSet && [blackSet containsObject:info.name]) {
                continue;
            }
            if ([objectPropertys containsObject:info.name]) {
                continue;
            }
            
            if ([oldColSet containsObject:info.name]) {
                // 有类型变化的, 请手动写升级语句, 实现 -> customUpgradeTableSQLWithOldColumns: 方法
                continue;
            }else {
                NSMutableString *mSql =
                [[NSMutableString alloc] initWithString:
                 [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN ", [[self class] tableName]]];
                NSString *typeEncoding = info.typeEncoding;
                if ([typeEncoding containsString:@"NSString"]) { // String -> TEXT
                    [mSql appendString:[NSString stringWithFormat:@"%@ TEXT", info.name]];
                }else if ([@"islqQISLB" containsString:typeEncoding]) {
                    //short/long/int/unsign/Bool/... -> INTEGER
                    [mSql appendString:[NSString stringWithFormat:@"%@ INTEGER DEFAULT(0)", info.name]];
                }else if ([@"df" containsString:typeEncoding]) {// float double -> REAL
                    [mSql appendString:[NSString stringWithFormat:@"%@ REAL DEFAULT(0)", info.name]];
                }else {
                    [mSql appendString:[NSString stringWithFormat:@"%@ NONE", info.name]];
                }
                [sqlArray addObject:mSql];
            }
        }
        free(properties);
    }
    
    return sqlArray;
}

/**
 * @brief 自定义升级表 SQL
 */
+ (NSArray <NSString *> *)customUpgradeTableSQLWithOldColumns:(NSArray <NSString *> *)oldColumns {
    return nil;
    // Sqlite 不支持 drop column/rename column/alter column.
    //    只有变通处理如下：
    //    
    //    -- 把原表改成另外一个名字作为暂存表
    //    ALTER TABLE old_table_name RENAME TO temp_table_name;
    //    
    //    -- 如果需要，可以删除原表的索引
    //    DROP INDEX ix_name;
    //
    //    -- 用原表的名字创建新表
    //    CREATE TABLE old_table_name(field_name INTEGER PRIMARY KEY AUTOINCREMENT, other_field_name text not null);
    //
    //    -- 如果需要，可以创建新表的索引
    //    CREATE INDEX ix_name ON old_table_name(field_name);
    //
    //    -- 将暂存表数据写入到新表，很方便的是不需要去理会自动增长的 ID
    //    INSERT INTO old_table_name SELECT * FROM temp_table_name
    //
    //    -- 删除暂存表
    //    DROP TABLE temp_table_name;
    //    ---------------------
}

+ (id <GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dictionary {
    return [self yy_modelWithJSON:dictionary];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _modelId = 0;
    }
    return self;
}

- (NSString *)primaryKey {
    if (!_primaryKey) {
        _primaryKey = [GLDBModel uuidString];
    }
    return _primaryKey;
}

- (NSMutableDictionary *)toDatabaseDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self yy_modelToJSONObject]];
    
    return result;
}

@end
