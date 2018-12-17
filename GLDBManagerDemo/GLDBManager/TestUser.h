//
//  TestUser.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBModel.h"
#import "GLDBPersistProtocol.h"

/* =============================================================
                            测试用Model
   =============================================================*/

@interface TestUser : GLDBModel
<YYModel>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;

/**
 *  不需要入库
 */
@property (nonatomic, copy) NSString *cachePWD;


@end
