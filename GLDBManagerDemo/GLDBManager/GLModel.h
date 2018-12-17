//
//  GLModel.h
//  FeverShoe
//
//  Created by GrayLand on 16/12/26.
//  Copyright © 2016年 Odun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@interface GLModel : NSObject

+ (BOOL)saveModels:(NSArray <GLModel *> *)models withPath:(NSString *)path;
+ (NSMutableArray *)readModelsWithPath:(NSString *)path;
    
@end
