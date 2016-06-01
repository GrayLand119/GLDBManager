//
//  PersonModel.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/6/1.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDBModelProtocol.h"

@interface PersonModel : NSObject <GLDBModelProtocol>

+ (NSString *)tableName;
+ (NSString *)sqlForCreate;
+ (NSArray <NSString *> *)sqlForUpdate;

+ (id <GLDBModelProtocol>)modelWithDinctionay:(NSDictionary *)dictionary;
- (NSMutableDictionary *)toDictionary;


@property (nonatomic, strong) NSString *modelId;

@end
