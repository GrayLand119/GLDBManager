//
//  AKDBModel.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "AKDBModel.h"

@implementation AKDBModel


+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ \n-------->\n%@", [super description], [self toJSONString]];
}

@end
