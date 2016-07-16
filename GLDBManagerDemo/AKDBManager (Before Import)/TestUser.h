//
//  TestUser.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKDBModel.h"
#import "AKDBPersistProtocol.h"

/* =============================================================
                            测试用Model
   =============================================================*/

@interface TestUser : AKDBModel
<AKDBPersistProtocol>

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSUInteger age;

/**
 *  不需要入库
 */
@property (nonatomic, copy) NSString <Ignore> *cachePWD;


@end
