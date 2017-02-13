//
//  GLDBModel.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "GLDBPersistProtocol.h"

#ifndef CK_ISNULL
#define CK_ISNULL(obj, default) (obj) == nil ? (default) : (obj)
#endif

@protocol GLDBPropertyNotSave

@optional

@end

@interface GLDBModel : JSONModel
<GLDBPersistProtocol>
{
    NSString *_modelId;
}

@property (nonatomic, strong) NSString *modelId;

+ (BOOL)propertyIsOptional:(NSString *)propertyName;//overwrite JSONModel
+ (BOOL)propertyIsIgnored:(NSString*)propertyName;

+ (NSString *)tableName;
+ (NSString *)sqlForCreate;
+ (NSArray <NSString *> *)sqlForUpdate;
+ (id <GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dictionary;

- (NSMutableDictionary *)toDatabaseDictionary;

- (NSString *)description;

+ (NSString *)uuidString;

@end
