//
//  ViewController.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "ViewController.h"
#import "GLDBManager.h"

static NSString *const kOpenDataBaseTitle = @"打开数据库";
static NSString *const kCloseDataBaseTitle = @"关闭数据库";
@interface ViewController ()

@property (nonatomic, assign) BOOL isDBOpened;

@property (weak, nonatomic) IBOutlet UIButton *openBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNavigation];
    
    _isDBOpened = NO;
    [_openBtn setTitle:kOpenDataBaseTitle forState:UIControlStateNormal];
    
}

- (void)setNavigation
{
    self.navigationItem.title = @"Demo";
}

- (IBAction)onOpenAndCloseBtn:(id)sender
{
    if (_isDBOpened) {
        [self onCloseDataBase];
    }else{
        [self onOpenDataBase];
    }
}


#pragma mark -
#pragma mark Private

#pragma mark -
#pragma mark onEvent

- (void)onOpenDataBase
{
    GLDBManager *dbManager = [GLDBManager defaultManager];
    
    dbManager.type = GLDBManagerTypeFMDB;
    NSLog(@"DataBase Path Default : %@", dbManager.path);
    
    [dbManager openDatabaseWithFileAtPath:@"" completion:^(GLDataBase *database, NSString *path, BOOL successfully) {
       
        if (successfully) {
            _isDBOpened = YES;
            
        }
    }];
}

- (void)onCloseDataBase
{
    GLDBManager *dbManager = [GLDBManager defaultManager];
    
    [dbManager closeDatabaseWithCompletion:^(GLDataBase *database, BOOL successfully) {
        
        if (successfully) {
            _isDBOpened = NO;
        }
    }];
}

- (void)onQuery
{
    
}

- (void)onAdd
{
    
}

- (void)onDelete
{
    
}

- (void)onUpdate
{
    
}

@end
