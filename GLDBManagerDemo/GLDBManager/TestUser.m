//
//  TestUser.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "TestUser.h"

@implementation TestUser

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"cachePWD"];
}

@end
