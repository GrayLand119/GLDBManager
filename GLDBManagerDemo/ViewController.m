//
//  ViewController.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "ViewController.h"
#import "GLDBManager.h"
#import "TestUser.h"

#define STRING_ADD_RETURN(str) [NSString stringWithFormat:@"%@\n", str]

#define GLLog(str) {_logView.text = [_logView.text stringByAppendingString:STRING_ADD_RETURN(str)];CGSize size = _logView.contentSize;\
[_logView scrollRectToVisible:CGRectMake(0, 0, size.width, size.height) animated:YES];}


static NSString *const kOpenDataBaseTitle  = @"打开数据库";
static NSString *const kCloseDataBaseTitle = @"关闭数据库";
@interface ViewController ()
<UITextViewDelegate>

@property (nonatomic, assign) BOOL isDBOpened;

@property (weak, nonatomic) IBOutlet UIButton *openBtn;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
@property (weak, nonatomic) IBOutlet UITextView *logView;

@property (weak, nonatomic) IBOutlet UIButton *createTableBtn;
@property (nonatomic, strong) GLDBManager *dbManager;


@property (nonatomic, strong) NSMutableArray *peoples;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNavigation];
    
    self.isDBOpened = NO;
    
    _logView.delegate = self;
    _logView.text = @"";
    
    _logView.showsHorizontalScrollIndicator = YES;
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

- (void)setIsDBOpened:(BOOL)isDBOpened
{
    _isDBOpened = isDBOpened;
    if (isDBOpened) {
        GLLog(@"打开数据库")
        _pathLabel.text = [NSString stringWithFormat:@"路径:%@", _dbManager.path];
        GLLog(_pathLabel.text)
        
        [_openBtn setTitle:@"关闭数据库" forState:UIControlStateNormal];
        
    }else{
        GLLog(@"关闭数据库")
        _pathLabel.text = @"";
        
        [_openBtn setTitle:@"打开数据库" forState:UIControlStateNormal];
    }
}
#pragma mark -
#pragma mark Private

#pragma mark -
#pragma mark onEvent

/* =============================================================
                            打开数据库
 =============================================================*/
- (void)onOpenDataBase
{
    _dbManager = [GLDBManager defaultManager];
    
    NSLog(@"DataBase Path Default : %@", _dbManager.path);
    
    if (_isDBOpened) return;
    
    if ([_dbManager openDefaultDatabase]) {
        self.isDBOpened = YES;
        GLLog(@"打开数据库 成功!");
    }else {
        GLLog(@"打开数据库 失败!");
    }
    
}

- (void)onCloseDataBase
{
    [_dbManager.currentDB closeDatabaseWithCompletion:^(GLDatabase *database, BOOL successfully) {
        if (successfully) {
            self.isDBOpened = NO;
        }
    }];
}

/* =============================================================
                            建表
 =============================================================*/
- (IBAction)onCreateTable:(id)sender
{
    // TestUser 实现 GLDBPersistProtocol 即可入库
    [_dbManager.currentDB createOrUpgradeTablesWithClasses:@[[TestUser class]]];
}

/* =============================================================
                            插入数据
 =============================================================*/
- (IBAction)onInsert:(id)sender
{
    TestUser *user = [[TestUser alloc] init];
    
    // 随机设置信息
    NSInteger randomId = arc4random_uniform(100);
    user.name = [NSString stringWithFormat:@"GrayLand-%ld", randomId];
    user.age  = arc4random_uniform(120) + 10;
    
    [_dbManager.currentDB saveOrUpdate:user completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully) {
        NSString *info = [NSString stringWithFormat:@"insert %@ %@", sql, successfully?@"成功":@"失败"];
        GLLog(info);
        GLLog([user yy_modelDescription]);
    }];
}

/* =============================================================
                            更新数据
 =============================================================*/
- (IBAction)onUpdate:(id)sender
{
//    _dbManager update:<#(id<GLDBPersistProtocol>)#> completion:<#^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully)completion#>
}

/* =============================================================
                            删除
 =============================================================*/
- (IBAction)onDelete:(id)sender
{
//    _dbManager removeModel:<#(id<GLDBPersistProtocol>)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
//    _dbManager removeModels:<#(NSArray *)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
//    _dbManager removeModelWithClass:<#(__unsafe_unretained Class<GLDBPersistProtocol>)#> byId:<#(NSString *)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
}
/* =============================================================
                            查询
 =============================================================*/
- (IBAction)onQuery:(id)sender
{
    if(0)
    {
        TestUser *user = (TestUser *)[_dbManager.currentDB findModelForClass:[TestUser class] byId:@"1"];
        if (user) {
            NSString *tLog = [user description];
            GLLog(tLog)
        }
    }

    if(0)
    {
        NSArray <TestUser *> *allUser = [_dbManager.currentDB findModelsForClass:[TestUser class] withConditions:@"age > 0"];
        [allUser enumerateObjectsUsingBlock:^(TestUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *log = [obj description];
            GLLog(log)
        }];
    }
    
    if(1)
    {
        NSArray <TestUser *> *allUser = [_dbManager.currentDB executeQuery:@"SELECT * FROM testuser" forClass:[TestUser class]];
        [allUser enumerateObjectsUsingBlock:^(TestUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *log = [obj yy_modelDescription];
            GLLog(log)
        }];
    }
}


@end
