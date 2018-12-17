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

- (NSString *)primaryKey {
    if (!_primaryKey) {
        CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
        CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
        NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
        CFRelease(uuid_ref);
        CFRelease(uuid_string_ref);
        _primaryKey = [uuid lowercaseString];
    }
    return _primaryKey;
}
@end
