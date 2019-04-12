//
//  TestUser.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBModel.h"
#import "GLDBPersistProtocol.h"
#import "Tire.h"
#import "CarFrame.h"
/* =============================================================
                            测试用Model
   =============================================================*/

@interface Car : GLDBModel
<YYModel>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, strong) NSArray <Tire *> *tires;
@property (nonatomic, strong) CarFrame *frame;
@property (nonatomic, strong) NSDate *buildDate;

/**
 *  不需要入库
 */
@property (nonatomic, copy) NSString *unusedProperty;


@end
