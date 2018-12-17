//
//  GLDBPersistProtocol.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#ifndef GLDBPersistProtocol_h
#define GLDBPersistProtocol_h

@protocol GLDBPersistProtocol

@required
@property (nonatomic, strong) NSString *primaryKey;




/**
 *  获取tableName
 *
 *  @return tableName
 */
+ (NSString *)tableName;

/**
 *  返回创建与该Model对应的表的SQL语句
 *
 *  @return 创建表的SQL语句
 */
+ (NSString *)sqlForCreate;

/**
 *  返回更新与该Model对应的表的SQL语句
 *
 *  @return 更新表的SQL语句
 */
+ (NSArray *)sqlForUpdate;

/**
 *  字典类型转Model类型
 *
 *  @param dic 字典类型
 *
 *  @return Model类型
 */
+ (id<GLDBPersistProtocol>)modelWithDinctionay:(NSDictionary *)dic;

/**
 *  Model类型转字典类型
 *
 *  @return 字典类型
 */
- (NSMutableDictionary *)toDatabaseDictionary;


@optional
+ (BOOL)propertyIsIgnored:(NSString *)propertyName;



@end


#endif /* GLDBPersistProtocol_h */

