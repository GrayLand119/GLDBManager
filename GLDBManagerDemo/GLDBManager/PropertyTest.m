//
//  PropertyTest.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 2018/12/17.
//  Copyright © 2018 GrayLand. All rights reserved.
//

#import "PropertyTest.h"
#import <objc/runtime.h>

#define GLPrint(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@implementation OtherModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _p_NSInteger = 2;
        _p_NSString = @"222";
    }
    return self;
}
@end

@implementation PropertyTest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _p_BOOL = YES;
        _p_NSInteger = 1;
        _p_CGFloat = 1.1;
        _p_float = 1.2;
        _p_double = 2.1;
        _p_NSString = @"aaa";
        void *bytes = malloc(100);
        _p_NSData = [NSData dataWithBytes:bytes length:100];
        _p_NSMutableData = [NSMutableData dataWithData:[_p_NSData copy]];
        _p_NSDate = [NSDate date];
        _p_NSArray = @[@1, @2];
        _p_NSMutableArray = [NSMutableArray arrayWithArray:_p_NSArray];
        _p_NSDictionary = @{@1:@"111"};
        _p_NSMutableDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@2:@"222"}];
        _p_OtherModel = [OtherModel new];
        _p_OtherModels = @[_p_OtherModel];
    }
    return self;
}

- (void)displayClassInfo {
    
    Class cls = [self class];
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    
    if (methods) {
        NSLog(@"Method Info:");
        for (unsigned int i = 0; i < methodCount; i++) {
            YYClassMethodInfo *info = [[YYClassMethodInfo alloc] initWithMethod:methods[i]];
            GLPrint(@"name=%@", info.name);
            GLPrint(@"typeEncoding=%@", info.typeEncoding);
            GLPrint(@"returnTypeEncoding=%@", info.returnTypeEncoding);
            GLPrint(@"argumentTypeEncodings=%@", info.argumentTypeEncodings);
        }
        free(methods);
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        GLPrint(@"Property Info:");
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            GLPrint(@"name=%@", info.name);
            GLPrint(@"typeEncoding=%@", info.typeEncoding);
            GLPrint(@"ivarName=%@", info.ivarName);
            GLPrint(@"protocols=%@", info.protocols);
        }
        free(properties);
    }
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        GLPrint(@"Ivar Info:");
        for (unsigned int i = 0; i < ivarCount; i++) {
            YYClassIvarInfo *info = [[YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            GLPrint(@"name=%@", info.name);
            GLPrint(@"offset=%@", @(info.offset));
            GLPrint(@"typeEncoding=%@", info.typeEncoding);
        }
        free(ivars);
    }
    
}

@end
