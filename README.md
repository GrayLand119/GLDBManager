# GLDBManagerDemo

转行iOS开发一年有余, 是时候写一些组件练练手了. 

**GLDBManager**是基于FMDB的写的轻量级数据库插件.

主要功能:

1. 封装开/关数据库, 增、添、改、删操作.

2. 自动升级数据库.

3. 对象除了支持数据库存取外,支持本地文件写入和读取.

实现原理:

使用了Runtime, 能够根据当前的Model类自动生成SQL语句, 从而实现自动建表和自动更新, 在数据库表结构改变的情况下升级数据库保留旧数据.

![DemoImage](https://github.com/GrayLand119/GLDBManagerDemo/blob/master/GLDBManagerDemo.jpg)

目前数据库只有2个类型. **String** and **Integer**

**String:**所有的Integer以外的全部以String形式保存

**Integer:**Integer类型

## 自动升级开关

在实际使用过程当中, 我们不需要每次加载数据库的时候都进行升级, 目前是在**GLDBModel**中定义了**APP\_DATABASE\_UPDATE**. 若APP_DATABASE_UPDATE == 1,则自动生成更新表的SQL语句

TODO:修改开关为网络控制.

## 自动升级实现


更新SQL的语句: 
> (Integer) ALTER TABLE [**table_name**] ADD COLUMN [**property_type**] DEFAULT([**value**])
> 
> (String) ALTER TABLE [**table_name**] ADD COLUMN TEXT

```objc
+ (NSArray <NSString *> *)sqlForUpdate {

    if (!APP_DATABASE_UPDATE) {
        return nil;
    }
    
    u_int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray *sqlArray    = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
        NSMutableString *mSql = [[NSMutableString alloc] initWithString:
                                 [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN ", [[self class] tableName]]];
        [mSql appendString:[NSString stringWithUTF8String:property_getName(properties[i])]];
        
        NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(properties[i])];
        if ([propertyType containsString:@"NSString"]) {
            [mSql appendString:@" INTEGER DEFAULT(0)"];
        }else {
            [mSql appendString:@" TEXT"];
        }
        
        [sqlArray addObject:mSql];
    }
    
    return sqlArray;

}
```

## 主要接口
```objc
/* =============================================================
 Public function
 =============================================================*/

/**
 *  打开数据库文件
 *
 *  @param path         path description
 *  @param completion   操作完成处理方法
 */
- (void)openDatabaseWithFileAtPath:(NSString *)path completion:(GLDatabaseOpenCompletion)completion;

/**
 *  关闭数据库
 *
 *  @param completion   操作完成处理方法
 */
- (void)closeDatabaseWithCompletion:(GLDatabaseCloseCompletion)completion;

/**
 *  建表，建过表后会记录起来，如果下次再企图建表，将跳过此条要求，
 *  如改表，请使用upgradeBySql:completion:
    @see -upgradeBySql:completion:
 *
 *  @param classes classes description
 */
- (void)createOrUpgradeTablesWithClasses:(NSArray *)classes;

/**
 *  保存对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)save:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;

/**
 *  更新对象至数据库
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)update:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;

/**
 *  插入或更新对象至数据库
 *
 *  @param model      数据库model
 *  @param completion 操作完成处理方法
 */
- (void)saveOrUpdate:(id<GLDBPersistProtocol>)model completion:(GLDatabaseUpdateCompletion)completion;

/**
 *  从数据库移除指定记录
 *
 *  @param model        数据库model
 *  @param completion   操作完成处理方法
 */
- (void)removeModel:(id<GLDBPersistProtocol>)model completion:(GLDatabaseRemoveCompletion)completion;

/**
 *  批量删除数据库条目
 *
 *  @param models       models description
 *  @param completion   操作完成处理方法
 */
- (void)removeModels:(NSArray *)models completion:(GLDatabaseRemoveCompletion)completion;

/**
 *  从数据库里移除指定id的model
 *
 *  @param objectId     指定model的id
 *  @param completion   操作完成处理方法
 */
- (void)removeModelWithClass:(__unsafe_unretained Class<GLDBPersistProtocol>)clazz byId:(NSString *)objectId
                  completion:(GLDatabaseRemoveCompletion)completion;


/**
 *  执行sql update语句
 *
 *  @param sqlString    sqlString description
 *  @param completion   操作完成处理方法
 */
- (void)executeUpdate:(NSString *)sqlString completion:(GLDatabaseUpdateCompletion)completion;

/**
 *  升级数据库执行更新接口
 *
 *  @param sqlString    sql语句
 *  @param completion   操作完成处理方法
 */
- (void)upgradeBySql:(NSString *)sqlString completion:(GLDatabaseUpgradeCompletion)completion;

```


## 更多介绍

未完待续...
