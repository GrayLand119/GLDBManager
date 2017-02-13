//
//  GLModel.h
//  FeverShoe
//
//  Created by GrayLand on 16/12/26.
//  Copyright © 2016年 Odun. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface GLModel : JSONModel

+ (BOOL)saveModels:(NSArray <GLModel *> *)models withPath:(NSString *)path;
+ (NSMutableArray *)readModelsWithPath:(NSString *)path;
    
@end
