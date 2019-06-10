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

//#define GLLog(str, ...) {\
//NSLog(str, ##__VA_ARGS__);\
//_logView.text = [_logView.text stringByAppendingString:str];\
//_logView.text = [_logView.text stringByAppendingString:@"\n"];\
//CGSize size = _logView.contentSize;\
//_logView.contentOffset = CGPointMake(0, size.height-UIScreen.mainScreen.bounds.size.height);}


static NSString *const kOpenDataBaseTitle  = @"打开数据库";
static NSString *const kCloseDataBaseTitle = @"关闭数据库";
@interface ViewController ()
<UITextViewDelegate>

@property (nonatomic, assign) BOOL isDBOpened;

@property (weak, nonatomic) IBOutlet UIButton *openBtn;
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
//@property (weak, nonatomic) IBOutlet UITextView *logView;

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
    
//    _logView.delegate = self;
//    _logView.text = @"";
    
//    _logView.showsHorizontalScrollIndicator = YES;
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
        NSLog(@"打开数据库");
        _pathLabel.text = [NSString stringWithFormat:@"路径:%@", _dbManager.defaultDB.path];
        NSLog(@"%@", _pathLabel.text);
        
        [_openBtn setTitle:@"关闭数据库" forState:UIControlStateNormal];
        
    }else{
        NSLog(@"关闭数据库");
        _pathLabel.text = @"";
        
        [_openBtn setTitle:@"打开数据库" forState:UIControlStateNormal];
    }
}

- (void)displayAllTableInfo {
    NSLog(@"获取所有表信息...");
    NSArray *allTables = [_dbManager.defaultDB getAllTableNameUsingCache:NO];
    NSLog(@"All Table : %@", allTables);
    for (NSString *tableName in allTables) {
        id infos = [_dbManager.defaultDB getAllColumnsInfoInTable:tableName];
        NSLog(@"%@ - Info:%@", tableName, infos);
    }
}

#pragma mark - Action

/**
 * @brief 打开数据库
 */
- (void)onOpenDataBase {
    _dbManager = [GLDBManager defaultManager];
    [_dbManager openDefaultDatabaseWithUserId:@"UserA"];
    
    NSLog(@"DataBase Path Default : %@", _dbManager.defaultDB.path);

    if (_isDBOpened) return;

    if ([_dbManager openDefaultDatabaseWithUserId:@"UserA"]) {
        self.isDBOpened = YES;
        NSLog(@"打开数据库 成功!");
    }else {
        NSLog(@"打开数据库 失败!");
    }
}

/**
 * @brief 关闭数据库
 */
- (void)onCloseDataBase {
    
    [_dbManager.defaultDB closeDatabaseWithCompletion:^(GLDatabase * _Nonnull database, BOOL successfully) {
        NSLog(@"数据库关闭%@!", successfully?@"Successfully":@"Failure");
        self.isDBOpened = NO;
    }];
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
        [[NSFileManager defaultManager] removeItemAtPath:_dbManager.defaultDB.path error:nil];
    }
    if (error) {
        NSLog(@"删除失败: %@", error);
    }else {
        NSLog(@"删除成功!");
    }
}

/**
 * @brief 插入数据
 */
- (IBAction)onInsert:(id)sender {
    
    Car *car = [Car new];
    
    // 随机设置信息
    NSInteger randomId = arc4random_uniform(100);
    car.name = [NSString stringWithFormat:@"Car-%ld", (long)randomId];
    car.age  = arc4random_uniform(120) + 10;
    car.buildDate = [NSDate date];
    
    [_dbManager.defaultDB insertModel:car completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
        
        NSLog(@"Insert: %@", successfully?@"Success":@"Failed");
        if (errorMsg) {
            NSLog(@"Error:%@", errorMsg);
        }
    }];
}

/**
 插入大量数据
 */
- (IBAction)onInsertMassOfData:(id)sender {
    [self insertBenchmark];
}

- (void)insertBenchmark {
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_HIGH), ^{
        CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
        // do something
        NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:10001];
        for (int i = 1; i < 10001; i++) {
            @autoreleasepool {
                Car *car = [Car new];
                car.age = i;
                [mArr addObject:car];
                [self->_dbManager.defaultDB insertModel:car isUpdateWhenExist:NO completion:nil];
                if (i % 1000 == 0) {
                    NSLog(@"插入: %d", i);
                }
            }
        }
        
        Car *car = [Car new];
        car.age = 10001;
        [mArr addObject:car];
        
//        dispatch_sync(self->_dbManager.defaultDB.writeQueue, ^{
//            [car getInsertSQLWithCompletion:^(NSString *insertSQL, NSArray *propertyNames, NSArray *values) {
//                // Faster
//                [self->_dbManager.defaultDB.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
//                    NSError *error = nil;
//                    [db executeUpdate:insertSQL values:values error:&error];
//                }];
//            }];
//            CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//            NSLog(@"方法1:插入数据完成");
//            NSLog(@"SpendTime:%f", end - start);
//            // SpendTime:8.409036
//        });
        
        [self->_dbManager.defaultDB insertMassOfModels:mArr completion:^(GLDatabase * _Nonnull database, id<GLDBPersistProtocol>  _Nullable model, NSString * _Nullable sql, BOOL successfully, NSString * _Nullable errorMsg) {
            CFAbsoluteTime end2 = CFAbsoluteTimeGetCurrent();
            NSLog(@"方法2:插入数据完成");
            NSLog(@"SpendTime:%f", end2 - start);
            // SpendTime:7.852897
        }];
        
    });
}

/**
 * @brief 更新数据
 */
- (IBAction)onUpdate:(id)sender {
    
    [_dbManager.defaultDB findModelWithClass:[Car class] condition:@"age < 10" completion:^(GLDatabase *database, NSMutableArray <id<GLDBPersistProtocol>> *models, NSString *sql) {
        
        NSLog(@"%@", models);
        Car *car = [models firstObject];
        if (car) {
            NSLog(@"Update Model : %@", [car yy_modelDescription]);
            car.age = arc4random_uniform(5);
            car.name = [NSString stringWithFormat:@"c%@", car.name];
            [self->_dbManager.defaultDB updateModelWithModel:car withCompletion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                NSLog(@"Update %@", successfully?@"Successed!":@"Failed!");
            }];
            
            [self->_dbManager.defaultDB updateInTable:[Car tableName]
                              withBindingValues:@{@"age":@10,
                                                  @"name":@"A63 AMG"}
                                      condition:@"modelId = 1"
                                     completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                                         
                                     }];
        }else {
            NSLog(@"No Model to Update");
        }
    }];
}

/**
 * @brief 删除
 */
- (IBAction)onDelete:(id)sender {
    
    [_dbManager.defaultDB findModelWithClass:[Car class] condition:@"age > 10" completion:^(GLDatabase *database, NSMutableArray<id<GLDBPersistProtocol>> *models, NSString *sql) {
        
        NSLog(@"%@", models);
        Car *car = [models firstObject];
        if (car) {
            NSLog(@"Delete %@", [car yy_modelDescription]);
            [self->_dbManager.defaultDB deleteModelWithModel:car completion:^(GLDatabase *database, BOOL successfully, NSString *errorMsg) {
                NSLog(@"Delete %@", successfully?@"Successful":@"Failed");
            }];
        }else {
            NSLog(@"No Model to Delete");
        }
    }];
}

- (IBAction)onDeleteAll:(id)sender {
    [self->_dbManager.defaultDB deleteInTable:Car.tableName withCondition:nil completion:^(GLDatabase * _Nonnull database, BOOL successfully, NSString * _Nullable errorMsg) {
        NSLog(@"Delete %@", successfully?@"Successful":@"Failed");
    }];
}

/**
 * @brief 查询
 */
- (IBAction)onQuery:(id)sender {
    [_dbManager.defaultDB findModelWithClass:[Car class] condition:@"age > 0" completion:^(GLDatabase *database, NSMutableArray<id<GLDBPersistProtocol>> *models, NSString *sql) {
        
//        NSInteger iLast = 0;
//        for (id model in models) {
//            Car *car = (Car *)model;
//            if (car.age - iLast > 1) {
//                NSLog(@"Sequence Error!!!");
//                break;
//            }
//            iLast = car.age;
//        }
        NSLog(@"%ld", models.count);
        NSArray *dispArray = [models subarrayWithRange:NSMakeRange(0, models.count > 10 ? 10 : models.count)];
        NSLog(@"%@", [dispArray yy_modelDescription]);
    }];
}

@end
