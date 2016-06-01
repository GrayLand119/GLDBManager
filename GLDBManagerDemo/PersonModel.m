//
//  PersonModel.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/6/1.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "PersonModel.h"


@interface PersonModel()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *homeAddress;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) float     height;
@property (nonatomic, assign) float     weight;
@property (nonatomic, assign) BOOL      isMale;

@end


@implementation PersonModel

+ (NSString *)tableName
{
    return NSStringFromClass([self class]);
}

+ (NSString *)sqlForCreate
{
    return
    [NSString stringWithFormat:
     @"CREATE TABLE IF NOT EXISTS %@"
     "("
     "modelId TEXT PRIMARY KEY UNIQUE,"
     "name TEXT, "
     "homeAddress TEXT, "
     "email TEXT, "
     "age INTEGER, "
     "height INTEGER, "
     "weight INTEGER, "
     "isMale INTEGER"
     ")"
     ,[PersonModel tableName]
     ];
}

+ (NSArray <NSString *> *)sqlForUpdate
{
    return nil;
}

+ (id <GLDBModelProtocol>)modelWithDinctionay:(NSDictionary *)dictionary
{
    return nil;
}

- (NSMutableDictionary *)toDictionary
{
    return nil;
}

@end
