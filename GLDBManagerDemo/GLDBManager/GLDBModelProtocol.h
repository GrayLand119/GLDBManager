//
//  GLDBModelProtocol.h
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#ifndef GLDBModelProtocol_h
#define GLDBModelProtocol_h


#endif /* GLDBModelProtocol_h */

@protocol GLDBModelProtocol <NSObject>

@required

+ (NSString *)tableName;
+ (NSString *)sqlForCreate;
+ (NSArray <NSString *> *)sqlForUpdate;

+ (id <GLDBModelProtocol>)modelWithDinctionay:(NSDictionary *)dictionary;
- (NSMutableDictionary *)toDictionary;

@property (nonatomic, strong) NSString *modelId;



@end