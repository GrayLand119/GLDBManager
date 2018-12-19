//
//  TestUser.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "Car.h"

@implementation Car

- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"noname";
        _age = arc4random_uniform(12);
        _tires = @[[Tire new],[Tire new],[Tire new],[Tire new]];
        _frame = [CarFrame new];
    }
    return self;
}

+ (NSArray<NSString *> *)glBlackList {
    return @[@"unusedProperty"];
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"frame":[CarFrame class],
             @"tires":[Tire class]
             };
}

@end
