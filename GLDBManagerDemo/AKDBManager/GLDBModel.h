//
//  GLDBModel.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/7/15.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface GLDBModel : JSONModel
{
    NSString *_modelId;
}

@property (nonatomic, strong) NSString *modelId;

+ (BOOL)propertyIsOptional:(NSString *)propertyName;//overwrite JSONModel

@end
