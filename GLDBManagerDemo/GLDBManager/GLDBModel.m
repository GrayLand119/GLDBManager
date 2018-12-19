//
//  GLDBModel.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBModel.h"
#import <objc/runtime.h>
#import <objc/message.h>

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

+ (NSArray <NSString *> *)glBlackList {
    return nil;
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    NSMutableArray *tMArr = [NSMutableArray arrayWithArray:[self defaultBlackList]];
    NSArray *arr = [self glBlackList];
    if (arr) {
        [tMArr addObjectsFromArray:arr];
    }
    if ([self autoIncrement]) {
        [tMArr addObject:@"primaryKey"];
    }
    
    return tMArr;
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

/**
 * @brief 继承自父类的属性.
 */
+ (NSArray * _Nonnull)defaultBlackList {
    return @[@"hash", @"superclass", @"description", @"debugDescription", @"cachedBlackListPropertys"];
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
//        NSSet *objectPropertys = [NSSet setWithArray:[self defaultBlackList]];
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            NSString *typeEncoding = info.typeEncoding;
            if (blackSet && [blackSet containsObject:info.name]) {
                continue;
            }
//            if ([objectPropertys containsObject:info.name]) {
//                continue;
//            }
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
 * @brief 升级表 SQL, 有新字段自动增加, 有自定义升级则执行自定义升级
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
//        NSSet *objectPropertys = [NSSet setWithArray:[self defaultBlackList]];
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            
            if (blackSet && [blackSet containsObject:info.name]) {
                continue;
            }
//            if ([objectPropertys containsObject:info.name]) {
//                continue;
//            }
            
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

//- (NSSet *)cachedBlackListPropertys {
//    if (!_cachedBlackListPropertys) {
//
//        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:64];
//        NSArray *blackList = [[self class] modelPropertyBlacklist];
//        if (blackList) {
//            [mArr addObjectsFromArray:blackList];
//        }
//        [mArr addObjectsFromArray:[self.class objectProperty]];
//        _cachedBlackListPropertys = [NSSet setWithArray:mArr];
//    }
//    return _cachedBlackListPropertys;
//}

- (void)getInsertSQLWithCompletion:(void (^)(NSString *insertSQL, NSArray *values))completion {
    
    if (!completion) {
        return;
    }
    
    Class cls = [self class];
    NSString *tableName = [cls tableName];
    
    // Get All Property
    NSSet *blackSet = [NSSet setWithArray:[cls modelPropertyBlacklist]];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClassName:NSStringFromClass(cls)];
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    NSMutableArray *propertyValues = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    [classInfo.propertyInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YYClassPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![blackSet containsObject:key]) {
            [propertyNames addObject:key];
            [placeholders addObject:@"?"];
            id pValue = @0;
            
            switch (obj.type & YYEncodingTypeMask) {
                case YYEncodingTypeBool: {
                    bool num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    pValue = @(num);
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeInt8:
                case YYEncodingTypeUInt8: {
                    uint8_t num = ((bool (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    pValue = @(num);
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeInt16:
                case YYEncodingTypeUInt16: {
                    uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    pValue = @(num);
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeInt32:
                case YYEncodingTypeUInt32: {
                    uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    pValue = [NSNumber numberWithInt:num];
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeInt64:
                case YYEncodingTypeUInt64: {
                    uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    pValue = @(num);
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeFloat: {
                    float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    if (isnan(num) || isinf(num)){
                        pValue = @0;
                    }else {
                        pValue = @(num);
                    }
                    [propertyValues addObject:pValue];
                } break;
                case YYEncodingTypeDouble: {
                    double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    if (isnan(num) || isinf(num)) {
                        pValue = @0;
                    } else {
                        pValue = @(num);
                    }
                    [propertyValues addObject:pValue];
                }break;
                case YYEncodingTypeLongDouble: {
                    double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    if (isnan(num) || isinf(num)){
                        pValue = @0;
                    }else {
                        pValue = @(num);
                    }
                    [propertyValues addObject:pValue];
                }break;
                case YYEncodingTypeClass:
                case YYEncodingTypeCString:
                case YYEncodingTypeSEL:
                case YYEncodingTypePointer:
                case YYEncodingTypeStruct:
                case YYEncodingTypeUnion:
                case YYEncodingTypeBlock: {
                    [propertyValues addObject:@0];
                }break;
                case YYEncodingTypeObject:{
                    id yyObj = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    if (yyObj) {
                        if ([obj.typeEncoding containsString:@"NSString"] ||
                            [obj.typeEncoding containsString:@"NSNumber"]) {
                            [propertyValues addObject:yyObj];
                        }else {
                            [propertyValues addObject:[yyObj yy_modelToJSONString]];
                        }
                    }else {
                        [propertyValues addObject:@0];
                    }
                }break;
                    
                default: [propertyValues addObject:@0];
            }
        }
    }];
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"INSERT INTO %@ ", tableName];
    [sql appendFormat:@"(%@) VALUES (%@)",
     [propertyNames componentsJoinedByString:@", "],
     [placeholders componentsJoinedByString:@", "]];
    
    completion(sql, propertyValues);
}

@end
