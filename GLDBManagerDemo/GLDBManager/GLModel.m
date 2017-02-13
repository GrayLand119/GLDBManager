//
//  GLModel.m
//  FeverShoe
//
//  Created by GrayLand on 16/12/26.
//  Copyright © 2016年 Odun. All rights reserved.
//

#import "GLModel.h"

@implementation GLModel

+ (BOOL)saveModels:(NSArray <GLModel *> *)models withPath:(NSString *)path
{
    if (!path.length) {
        return NO;
    }
    
    NSMutableArray *arrToSave = [NSMutableArray arrayWithCapacity:models.count];
    for (GLModel *model in models) {
        [arrToSave addObject:model.toDictionary];
    }
    BOOL bResult = [arrToSave writeToFile:path atomically:YES];
    NSLog(@"saveModels:%@ withPath:%@", bResult?@"success":@"failed", path);
    return bResult;
}

+ (NSMutableArray *)readModelsWithPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    NSArray *loadList = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:loadList.count];
    for (NSDictionary *dic in loadList) {
        id shoe = [[[self class] alloc] initWithDictionary:dic error:nil];
        [models addObject:shoe];
    }
    
    return models;
}

@end
