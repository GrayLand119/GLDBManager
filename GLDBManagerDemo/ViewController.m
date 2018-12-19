//
//  ViewController.m
//  GLDBManagerDemo
//
//  Created by GrayLand on 16/5/30.
//  Copyright © 2016年 GrayLand. All rights reserved.
//

#import "ViewController.h"
#import "GLDBManager.h"
#import "Car.h"
#import "PropertyTest.h"

#define STRING_ADD_RETURN(str) [NSString stringWithFormat:@"%@\n", str]

#define GLLog(str) {\
_logView.text = [_logView.text stringByAppendingString:str];\
_logView.text = [_logView.text stringByAppendingString:@"\n"];\
CGSize size = _logView.contentSize;\
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
    
//    PropertyTest *model = [PropertyTest new];
//    [model displayClassInfo];

//    TestUser *user = [[TestUser alloc] init];
//    NSInteger randomId = arc4random_uniform(100);
//    user.name = [NSString stringWithFormat:@"GrayLand-%ld", randomId];
//    user.age  = arc4random_uniform(120) + 10;

//    Car *car = [Car new];
//    NSLog(@"%@", [car yy_modelDescription]);
//
//    [car getInsertSQLWithCompletion:^(NSString *insertSQL, NSArray *values) {
//        NSLog(insertSQL);
//        NSLog(@"%@", values);
//    }];
    
//    NSLog(@"%@", [user insertSQL]);
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
        _pathLabel.text = [NSString stringWithFormat:@"路径:%@", _dbManager.defaultDB.path];
        GLLog(_pathLabel.text)
        
        [_openBtn setTitle:@"关闭数据库" forState:UIControlStateNormal];
        
    }else{
        GLLog(@"关闭数据库")
        _pathLabel.text = @"";
        
        [_openBtn setTitle:@"打开数据库" forState:UIControlStateNormal];
    }
}

- (void)displayAllTableInfo {
    GLLog(@"获取所有表信息...");
    NSArray *allTables = [_dbManager.defaultDB getAllTableNameUsingCache:NO];
    NSString *msg = [NSString stringWithFormat:@"%@", allTables];
    GLLog(msg);
    for (NSString *tableName in allTables) {
        id infos = [_dbManager.defaultDB getAllColumnsInfoInTable:tableName];
        NSString *msg2 = [NSString stringWithFormat:@"%@", infos];
        GLLog(msg2);
    }
}

#pragma mark - Action

/**
 * @brief 打开数据库
 */
- (void)onOpenDataBase {
    _dbManager = [GLDBManager defaultManager];
    [_dbManager openDefaultDatabase];
    
    NSLog(@"DataBase Path Default : %@", _dbManager.defaultDB.path);

    if (_isDBOpened) return;

    if ([_dbManager openDefaultDatabase]) {
        self.isDBOpened = YES;
        GLLog(@"打开数据库 成功!");
        
        [self displayAllTableInfo];
    }else {
        GLLog(@"打开数据库 失败!");
    }

}

/**
 * @brief 关闭数据库
 */
- (void)onCloseDataBase {
    [_dbManager closeDatabase:_dbManager.defaultDB];
    self.isDBOpened = NO;
}

- (IBAction)onDispTableInfos:(id)sender {
    [self displayAllTableInfo];
}

- (IBAction)onCreateTable:(id)sender {
    // id 实现 GLDBPersistProtocol 即可入库
    // GLDBModel<GLDBPersistProtocol> 含有默认实现.
    [_dbManager.defaultDB registTablesWithModels:@[Car.class]];
//    [_dbManager.currentDB createOrUpgradeTablesWithClasses:@[[TestUser class]]];
//    GLLog([[GLDBModel class] tableName]);
}

/**
 * @brief 删除默认数据库
 */
- (IBAction)onDeleteDefaultDB:(id)sender {
    NSError *error;
    if (_dbManager.defaultDB.isOpened) {
        [_dbManager.defaultDB closeDatabaseWithCompletion:nil];
        [[NSFileManager defaultManager] removeItemAtPath:_dbManager.defaultDB.path error:nil];
    }else {
        [[NSFileManager defaultManager] removeItemAtPath:[_dbManager defaultDBPath] error:nil];
    }
    if (error) {
        NSString *msg = [NSString stringWithFormat:@"删除失败: %@", error.localizedDescription];
        GLLog(msg);
    }else {
        GLLog(@"删除成功!");
    }
}

/**
 * @brief 插入数据
 */
- (IBAction)onInsert:(id)sender {
    
    Car *car = [Car new];
    
    // 随机设置信息
    NSInteger randomId = arc4random_uniform(100);
    car.name = [NSString stringWithFormat:@"Car-%ld", randomId];
    car.age  = arc4random_uniform(120) + 10;
    
    [_dbManager.defaultDB insertModel:car completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
        
        NSLog(@"Insert: %@", successfully?@"Success":@"Failed");
        if (errorMsg) {
            NSLog(@"Error:%@", errorMsg);
        }
    }];
}

/**
 * @brief 更新数据
 */
- (IBAction)onUpdate:(id)sender {
//    _dbManager update:<#(id<GLDBPersistProtocol>)#> completion:<#^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully)completion#>
}

/**
 * @brief 删除
 */
- (IBAction)onDelete:(id)sender {
//    _dbManager removeModel:<#(id<GLDBPersistProtocol>)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
//    _dbManager removeModels:<#(NSArray *)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
//    _dbManager removeModelWithClass:<#(__unsafe_unretained Class<GLDBPersistProtocol>)#> byId:<#(NSString *)#> completion:<#^(GLDatabase *database, NSArray *models, BOOL successfully)completion#>
}

/**
 * @brief 查询
 */
- (IBAction)onQuery:(id)sender {
    [_dbManager.defaultDB findModelWithClass:[Car class] condition:@"age > 0" completion:^(GLDatabase *database, NSMutableArray<id<GLDBPersistProtocol>> *models, NSString *sql) {
        
        NSLog(@"%@", models);
    }];
//    if(0)
//    {
//        TestUser *user = (TestUser *)[_dbManager.currentDB findModelForClass:[TestUser class] byId:@"1"];
//        if (user) {
//            NSString *tLog = [user description];
//            GLLog(tLog)
//        }
//    }
//
//    if(0)
//    {
//        NSArray <TestUser *> *allUser = [_dbManager.currentDB findModelsForClass:[TestUser class] withConditions:@"age > 0"];
//        [allUser enumerateObjectsUsingBlock:^(TestUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSString *log = [obj description];
//            GLLog(log)
//        }];
//    }
//
//    if(1)
//    {
//        NSArray <TestUser *> *allUser = [_dbManager.currentDB executeQuery:@"SELECT * FROM testuser" forClass:[TestUser class]];
//        [allUser enumerateObjectsUsingBlock:^(TestUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSString *log = [obj yy_modelDescription];
//            GLLog(log)
//        }];
//    }
}

@end
