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
        [tMArr addObject:[self primaryKeyName]];//自定义主键
        [tMArr addObject:@"primaryKey"];// 默认主键字段
    }
    
    return tMArr;
}

+ (instancetype)yy_modelWithDictionary:(NSDictionary *)dictionary {
    NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    Class cls = [self class];
    // Get All Property
    NSSet *blackSet = [NSSet setWithArray:[cls modelPropertyBlacklist]];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClassName:NSStringFromClass(cls)];
    NSMutableArray *objPropertyNames = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    [classInfo.propertyInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YYClassPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![blackSet containsObject:key]) {
            if ((obj.type & YYEncodingTypeMask) == YYEncodingTypeObject) {
                if ([obj.typeEncoding containsString:@"NSArray"]) {
                    [objPropertyNames addObject:key];
                }
            }
        }
    }];
    for (NSString *pName in objPropertyNames) {
        NSString *tV = [mDic objectForKey:pName];
        if (!tV || ![tV isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *jsonString = (NSString *)tV;
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *jObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err) {
            NSLog(@"json解析失败：%@",err);
            continue;
        }
        
        mDic[pName] = jObj;
    }
    id obj = [super yy_modelWithDictionary:mDic];
    return obj;
}

#pragma mark - GLDBModelProtocol

+ (NSString *)tableName {
    return NSStringFromClass(self.class).lowercaseString;
}

- (NSString *)tableName {
    return [[self class] tableName];
}

/**
 * @brief 是否使用自增长, YES-使用 modelId Integer类型, NO-使用 PrimaryKey Text类型
 */
+ (BOOL)autoIncrement {
    return YES;
}

- (BOOL)autoIncrement {
    return [[self class] autoIncrement];
}

+ (NSString *)autoIncrementName {
    return @"modelId";
}

- (NSString *)autoIncrementName {
    return [[self class] autoIncrementName];
}

- (NSInteger)autoIncrementValue {
    return _modelId;
}

+ (NSString *)primaryKeyName {
    return @"primaryKey";
}

- (NSString *)primaryKeyName {
    return [[self class] primaryKeyName];
}

- (NSString *)primaryKeyValue {
    return _primaryKey;
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
        [mStr appendString:[NSString stringWithFormat:@"(%@ INTEGER PRIMARY KEY AUTOINCREMENT, ", [self autoIncrementName]]];
    }else {
        [mStr appendString:[NSString stringWithFormat:@"(%@ TEXT PRIMARY KEY UNIQUE, ", [self primaryKeyName]]];
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

/**
 * @brief 主键, 自定义主键请继承并重写.
 */
- (NSString *)primaryKey {
    if (!_primaryKey) {
        _primaryKey = [GLDBModel uuidString];
    }
    return _primaryKey;
}

/**
 * @brief 获取属性信息
 */
- (void)getPropertyInfoWithCompletion:(void (^)(NSArray *propertyNames, NSArray *values))completion {
    if (!completion) {
        return;
    }
    
    Class cls = [self class];
    // Get All Property
    NSSet *blackSet = [NSSet setWithArray:[cls modelPropertyBlacklist]];
    YYClassInfo *classInfo = [YYClassInfo classInfoWithClassName:NSStringFromClass(cls)];
    NSMutableArray *propertyNames = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    NSMutableArray *propertyValues = [NSMutableArray arrayWithCapacity:classInfo.propertyInfos.allKeys.count];
    [classInfo.propertyInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, YYClassPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![blackSet containsObject:key]) {
            [propertyNames addObject:key];
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
//                    if ([obj.typeEncoding containsString:@"NSArray"] ||
//                        [obj.typeEncoding containsString:@"NSMutableArray"]) {
//                        Ivar iv = class_getInstanceVariable([self class], [obj.ivarName UTF8String]);
//                        id marray = object_getIvar((id)self, iv);
//                        NSLog(@"123: %@", marray);
//                    }
                    id yyObj = ((id (*)(id, SEL))(void *) objc_msgSend)((id)self, obj.getter);
                    if (yyObj) {
                        if ([obj.typeEncoding containsString:@"NSString"] ||
                            [obj.typeEncoding containsString:@"NSNumber"]) {
                            [propertyValues addObject:yyObj];
                        }else if ([obj.typeEncoding containsString:@"NSArray"]) {
//                            id jsonObj = [yyObj yy_modelToJSONObject];
//                            [propertyValues addObject:jsonObj];
//                            NSData *jsonData = [yyObj yy_modelToJSONData];
//                            [propertyValues addObject:jsonData];
                            NSString *jsonString = [yyObj yy_modelToJSONString];
                            [propertyValues addObject:jsonString];
                        }else if ( [obj.typeEncoding containsString:@"Data"]) {
                            [propertyValues addObject:yyObj];
                        }else if ( [obj.typeEncoding containsString:@"Date"]) {
                            NSDate *date = (NSDate *)yyObj;
                            NSString *dateS = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
                            [propertyValues addObject:dateS];
//                            NSTimeInterval dateInterval = [date timeIntervalSince1970];
//                            [propertyValues addObject:@(dateInterval)];
                        }else {
                            NSLog(@"[GLDBModel] Not support type!");
                        }
                    }else {
                        [propertyValues addObject:@0];
                    }
                }break;
                    
                default: [propertyValues addObject:@0];
            }
        }
    }];
    
    if (![[self class] autoIncrement]) {
        [propertyNames addObject:[self primaryKeyName]];
        [propertyValues addObject:[self primaryKeyValue]];
    }
    
    completion(propertyNames, propertyValues);
}

/**
 * @brief runtime 生成插入语句.
 */
- (void)getInsertSQLWithCompletion:(void (^)(NSString *insertSQL, NSArray *propertyNames, NSArray *values))completion {
    
    if (!completion) {
        return;
    }
    
    [self getPropertyInfoWithCompletion:^(NSArray *propertyNames, NSArray *values) {
        NSString *tableName = [self tableName];
        NSMutableString *sql = [[NSMutableString alloc] init];
        NSMutableArray *placeholders = [NSMutableArray arrayWithCapacity:values.count];
        for (int i = 0; i < values.count; i++) {
            [placeholders addObject:@"?"];
        }
        [sql appendFormat:@"INSERT INTO %@ ", tableName];
        [sql appendFormat:@"(%@) VALUES (%@)",
         [propertyNames componentsJoinedByString:@", "],
         [placeholders componentsJoinedByString:@", "]];
        
        completion(sql, propertyNames, values);
    }];
}

/**
 * @brief runtime 生成更新语句.
 */
- (void)getUpdateSQLWithCompletion:(void (^)(NSString *updateSQL ,NSArray *names, NSArray *values))completion {
    
    if (!completion) {
        return;
    }
    
    [self getPropertyInfoWithCompletion:^(NSArray *propertyNames, NSArray *values) {
        NSMutableString *updateSQL = [NSMutableString string];
        [updateSQL appendString:[NSString stringWithFormat:@"UPDATE %@ SET ", [self tableName]]];
        for (int i = 0; i < propertyNames.count; i++) {
//            id value = values[i];
//            if ([value isKindOfClass:[NSString class]]) {
//                NSString *valueStr = (NSString *)values[i];
//                valueStr = [NSString stringWithFormat:@"'%@'", values[i]];
//                [updateSQL appendString:[NSString stringWithFormat:@"%@ = %@, ", propertyNames[i], valueStr]];
//            }else if ([value isKindOfClass:[NSData class]]) {
//                [blobArray addObject:value];
//                [updateSQL appendString:[NSString stringWithFormat:@"%@ = ?, ", propertyNames[i]]];
//            }else {
//                [updateSQL appendString:[NSString stringWithFormat:@"%@ = %@, ", propertyNames[i], value]];
//            }
            [updateSQL appendString:[NSString stringWithFormat:@"%@ = ?, ", propertyNames[i]]];
        }
        if (propertyNames.count > 0) {
            [updateSQL deleteCharactersInRange:NSMakeRange(updateSQL.length-2, 2)];
        }
        completion(updateSQL, propertyNames, values);
    }];
}

- (NSMutableDictionary *)toDatabaseDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self yy_modelToJSONObject]];
    return result;
}


@end
