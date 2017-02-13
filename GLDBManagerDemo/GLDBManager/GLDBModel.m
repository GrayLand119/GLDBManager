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

+ (NSString *)uuidString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

- (NSString *)modelId {
    return _modelId;
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+(BOOL)propertyIsIgnored:(NSString*)propertyName
{
    return [@[] containsObject:propertyName];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ \n-------->\n%@", [super description], [self toJSONString]];
}

#pragma mark - GLDBModelProtocol
+ (NSString *)tableName {
    return NSStringFromClass(self.class).lowercaseString;
}

//+ (NSString *)sqlForCreate
//{
//    return
//    [NSString stringWithFormat:
//     @"CREATE TABLE IF NOT EXISTS %@"
//     "("
//     "modelId TEXT PRIMARY KEY UNIQUE"
//     ")"
//     ,[[self class] tableName]
//     ];
//}
+ (NSString *)sqlForCreate {
    
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    //    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableString *mStr = [[NSMutableString alloc]
                             initWithString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@", [[self class] tableName]]];
    [mStr appendString:@"(modelId TEXT PRIMARY KEY UNIQUE, "];
    for (int i = 0; i < count; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        //        const char* propertyType = property_getAttributes(properties[i]);
        NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(properties[i])];
        [mStr appendString:[NSString stringWithUTF8String:propertyName]];
        if ([propertyType containsString:@"NSString"]) {
            [mStr appendString:@" TEXT,"];
        }else {
            [mStr appendString:@" INTEGER,"];
        }
        //        NSString *pType = [NSString stringWithUTF8String:propertyType];
        //        NSLog(@"Name:%@ Type:%@", [NSString stringWithUTF8String:propertyName],  pType);
        //        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    [mStr deleteCharactersInRange:NSMakeRange(mStr.length - 1, 1)];
    //    [mStr stringByReplacingCharactersInRange:NSMakeRange(mStr.length-2, 1) withString:@""];
    [mStr appendString:@")"];
    free(properties);
    
    return mStr;
    
    //    return
    //    [NSString stringWithFormat:
    //     @"CREATE TABLE IF NOT EXISTS %@"
    //     "("
    //     "modelId TEXT PRIMARY KEY UNIQUE,"
    //     "userName TEXT, "
    //     "avatarUrl TEXT, "
    //     "userType INTEGER, "
    //     "thirdPartAvatarUrl TEXT, "
    //     "thirdPartNickName TEXT, "
    //     "sexType INTEGER, "
    //     "age INTEGER, "
    //     "phoneNum INTEGER, "
    //     "email TEXT"
    //     ")"
    //     ,[[self class] tableName]
    //     ];
    //    ;
    
}

+ (NSArray <NSString *> *)sqlForUpdate {
    //TODO: 判断数据库版本, 启动自动升级, 目前是手动
//#ifdef DEBUG
//    static BOOL bNeedUpdate = YES;// NO - 不自动升级
//#else
//    static BOOL bNeedUpdate = NO;// NO - 不自动升级
//#endif
    if (!APP_DATABASE_UPDATE) {
        return nil;
    }
//    bNeedUpdate = NO;
    
    u_int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *sqlArray    = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        NSMutableString *mSql = [[NSMutableString alloc] initWithString:
                                 [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN ", [[self class] tableName]]];
        [mSql appendString:[NSString stringWithUTF8String:property_getName(properties[i])]];
        
        NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(properties[i])];
        if ([propertyType containsString:@"NSString"]) {
            [mSql appendString:@" INTEGER DEFAULT(0)"];
        }else {
            [mSql appendString:@" TEXT"];
        }
        
        [sqlArray addObject:mSql];
    }
    
    return sqlArray;

}

+ (id <GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dictionary
{
    return [[self.class alloc] initWithDictionary:dictionary error:nil];
}

- (NSMutableDictionary *)toDatabaseDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:[self toDictionary]];
    
    return result;
}
@end
