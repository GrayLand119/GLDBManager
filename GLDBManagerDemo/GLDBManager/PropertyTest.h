//
//  PropertyTest.h
//  GLDBManagerDemo
//
//  Created by GrayLand on 2018/12/17.
//  Copyright © 2018 GrayLand. All rights reserved.
//

#import "GLDBModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OtherProtocol <NSObject>

@optional
- (BOOL)optionalFunc:(NSInteger)input;

@required
- (NSInteger)requiredFunc;
@end

@protocol OtherProtocol2 <NSObject>

@optional
- (BOOL)optionalFunc2:(NSInteger)input;

@end

@interface OtherModel : NSObject
@property (nonatomic, assign) NSInteger p_NSInteger;
@property (nonatomic, strong) NSString *p_NSString;
@end

@interface PropertyTest : GLDBModel
@property (nonatomic, assign) BOOL p_BOOL;
@property (nonatomic, assign) NSInteger p_NSInteger;
@property (nonatomic, assign) CGFloat p_CGFloat;
@property (nonatomic, assign) float p_float;
@property (nonatomic, assign) double p_double;
@property (nonatomic, strong) NSString *p_NSString;
@property (nonatomic, strong) NSData *p_NSData;
@property (nonatomic, strong) NSMutableData *p_NSMutableData;
@property (nonatomic, strong) NSDate *p_NSDate;
@property (nonatomic, strong) NSArray *p_NSArray;
@property (nonatomic, strong) NSMutableArray *p_NSMutableArray;
@property (nonatomic, strong) NSDictionary *p_NSDictionary;
@property (nonatomic, strong) NSMutableDictionary *p_NSMutableDictionary;
@property (nonatomic, strong) OtherModel *p_OtherModel;
@property (nonatomic, strong) NSArray <OtherModel *> *p_OtherModels;

@property (nonatomic, strong) id <OtherProtocol, OtherProtocol2> delegate_OtherProtocol;
@property (nonatomic, weak) id weakObj;

- (void)displayClassInfo;

@end

NS_ASSUME_NONNULL_END
