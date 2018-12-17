//
//  GLFMDBDatabase.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDatabase.h"
#import <FMDB/FMDB.h>

@interface GLFMDBDatabase : GLDatabase

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;

@end
