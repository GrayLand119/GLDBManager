//
//  GLDataBase.h
//  SQLiteDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLDataBaseProtocol.h"
#import "GLDBModelProtocol.h"

@class GLDataBase;

@interface GLDataBase : NSObject <GLDataBaseProtocol>
{
    @protected
    
    dispatch_queue_t _readQueue;
    dispatch_queue_t _writeQueue;
    dispatch_queue_t _completionQueue;
}

@property (nonatomic, strong) NSString *path;

@property (nonatomic, assign) BOOL     isOpened;

@end
