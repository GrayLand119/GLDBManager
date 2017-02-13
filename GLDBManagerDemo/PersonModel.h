//
//  PersonModel.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/6/1.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "GLDBModel.h"


@interface PersonModel : GLDBModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *homeAddress;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) float     height;
@property (nonatomic, assign) float     weight;
@property (nonatomic, assign) BOOL      isMale;

@end
