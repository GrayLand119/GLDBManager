//
//  CarFrame.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 2018/12/19.
//  Copyright © 2018 GrayLand. All rights reserved.
//

#import "CarFrame.h"

@implementation CarFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        _weight = arc4random_uniform(10000) / 10.0 + 1000.0;
    }
    return self;
}
@end
