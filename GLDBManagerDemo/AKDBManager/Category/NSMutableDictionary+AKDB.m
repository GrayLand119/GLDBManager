//
//  NSMutableDictionary+AKDB.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "NSMutableDictionary+AKDB.h"

@implementation NSMutableDictionary (AKDB)

- (void)nonnullify
{
    [[self allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        id value = self[key];
        
        if([value isKindOfClass:[NSNull class]])
        {
            [self removeObjectForKey:key];
        }
    }];
}

@end
