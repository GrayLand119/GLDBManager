# GLDBManagerDemo

## 简介

`GLDBManager`是基于`FMDB`和`YYModel`的写的轻量级数据库插件. 在 Demo 中演示了如何使用它.

设计思想和特点:

设计初衷也就是特点, 就是非常方便使用. CURD都可以直接对对象进行操作, 不需要写SQL语句, 全部依赖 Runtime 自动生成.

主要功能:

1. 自动创建数据库, 开/关或删除数据库, 增、添、改、删操作.
2. 自动升级数据库, 模型添加字段后数据库会自动添加.
3. Model可以嵌套, 即模型中可以包含模型, 归档时会自动把内在模型转化为 `JSON String` 进行存储, 读取后自动还原.
4. Model 可以设置是 `自增长`或`唯一主键`类型.
5. 仿 `CoreData`, 可以`直接对模型进行增删改查`. 也提供基础的手动执行SQL语句的方法.

组件介绍:

1. `GLDBManager` 提供对多个数据库的管理, 自带一个默认数据库, 另外可根据业务需求添加多个数据库. 比如, `根据大文件读写/高低频/高低优先级,来拆分数据库`.
2. `GLDatabase` 提供对数据库的 `增/改/查/删(CURD)`操作, 自带读写线程.
3. `GLDBModel` 模型要归档的基础实现.
4. `GLDBPersistProtocol` 协议, 数据库归档以及 CURD 的基础协议.

实现原理:

使用了Runtime, 能够根据当前的Model类自动生成SQL语句, 从而实现自动建表和自动更新, 在数据库表结构改变的情况下升级数据库保留旧数据, 自动插入新字段.

![DemoImage](https://github.com/GrayLand119/GLDBManagerDemo/blob/master/GLDBManagerDemo.jpg)

目前数据库支持4个类型, 会通过 `runtime` 自动生成:

* 所有整型类型都存储为 `INTEGER` 类型.
* 所有浮点类型都存储为 `REAL` 类型.
* 字符串类型和所有对象类型(JSON)存储为 `TEXT` 类型.
* 其他类型都存储 `NONE` 类型.

## 使用方法

```objc

// 1. 打开or自动创建数据库
_dbManager = [GLDBManager defaultManager];
if ([_dbManager openDefaultDatabase]) {
    NSLog(@"打开数据库 成功!");
}else {
    NSLog(@"打开数据库 失败!");
}

// 2. 注册需要归档的对象
// 注册过程: 2.1 检查表是否存在/不存在自动创建 ---> 2.2 检查表字段和Model的字段是否匹配,不匹配则自动添加字段
// 2.2 若实现了手动升级方法, 则执行手动升级方法
[_dbManager.defaultDB registTablesWithModels:@[Car.class, OtherModel.class]];

// 3. 添加插入数据
Car *car = [Car new];
car.name = [NSString stringWithFormat:@"Car-%ld", arc4random_uniform(100)];
car.age  = arc4random_uniform(120) + 10;

[_dbManager.defaultDB insertModel:car completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {

    NSLog(@"Insert: %@", successfully?@"Success":@"Failed");
    if (errorMsg) {
    NSLog(@"Error:%@", errorMsg);
    }
}];

// 4. 更新数据
car.age = arc4random_uniform(5);
car.name = [NSString stringWithFormat:@"c%@", car.name];
// 方法1
[_dbManager.defaultDB updateModelWithModel:car withCompletion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
    NSLog(@"Update %@", successfully?@"Successed!":@"Failed!");
}];
// 方法2
[_dbManager.defaultDB updateInTable:[Car tableName]
                              withBindingValues:@{@"age":@10,
                                                  @"name":@"A63 AMG"}
                                      condition:@"modelId = 1"
                                     completion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
                                         
                                     }];

// 5. 查询数据
[_dbManager.defaultDB findModelWithClass:[Car class] condition:@"age > 0" completion:^(GLDatabase *database, NSMutableArray<id<GLDBPersistProtocol>> *models, NSString *sql) {
    NSLog(@"%@", models);
}];

// 6. 删除数据
// 方法1
[_dbManager.defaultDB updateModelWithModel:car withCompletion:^(GLDatabase *database, id<GLDBPersistProtocol> model, NSString *sql, BOOL successfully, NSString *errorMsg) {
    NSLog(@"Update %@", successfully?@"Successed!":@"Failed!");
}];
// 方法2
[_dbManager.defaultDB deleteInTable:[Car tableName] withCondition:@"age = 5" completion:^(GLDatabase *database, BOOL successfully, NSString *errorMsg) {
}];

```


## 用法

> pod 'GLDBManager'


