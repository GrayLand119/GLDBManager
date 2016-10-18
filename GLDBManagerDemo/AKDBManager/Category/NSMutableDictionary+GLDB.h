//
//  NSMutableDictionary+GLDB.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (GLDB)

/**
 *  去掉空值, 防止执行SQL崩溃
 */
- (void)nonnullify;

@end
