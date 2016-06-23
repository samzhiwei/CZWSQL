//
//  CZWSqlite.m
//  CZWSQL
//
//  Created by tianqu on 16/6/20.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "CZWSqlite.h"


@implementation SqlQueryStringBaseMaker
- (NSString *)result{
    if (!_result) {
        _result = [[NSString alloc]init];
    }
    return _result;
}
@end

@implementation SqlQueryStringStatementMaker

/**
 *  拼语句
 */
- (SqlQueryStringStatementMaker *(^)(NSString *))select{
    return ^SqlQueryStringStatementMaker *(NSString *values){
        if (values) {
            self.result = [self.result stringByAppendingFormat:@"SELECT %@ ",values];
        } else {
            self.result = [self.result stringByAppendingFormat:@"SELECT * "];
        }
        return self;
    };
}

- (SqlQueryStringStatementMaker *(^)(NSString *))from{
    return ^SqlQueryStringStatementMaker *( NSString *tables){
        if (tables) {
            self.result = [self.result stringByAppendingFormat:@"FROM %@ ",tables];
        } else {
            @throw [NSException exceptionWithName:@"SqlQueryStringMaker from('table') cannot be nil" reason:@"check SqlQueryStringMaker" userInfo:nil];
        }
        return self;
    };
}

- (SqlQueryStringStatementMaker *(^)(NSString *))where{
    return ^SqlQueryStringStatementMaker *(NSString *where){
        if (where) {
            self.result = [self.result stringByAppendingFormat:@"WHERE %@ ",where];
        }
        return self;
    };
}

- (SqlQueryStringStatementMaker *(^)(NSString *))groupBy{
    return ^SqlQueryStringStatementMaker *(NSString *groupBy){
        if (groupBy) {
            self.result = [self.result stringByAppendingFormat:@"GROUP BY %@ ",groupBy];
        }
        return self;
    };
}

- (SqlQueryStringStatementMaker *(^)(NSString *))orderBy{
    return ^SqlQueryStringStatementMaker *(NSString *orderBy){
        if (orderBy) {
            self.result = [self.result stringByAppendingFormat:@"ORDER BY %@ ",orderBy];
        }
        return self;
    };
}

- (SqlQueryStringStatementMaker *(^)(NSString *))limit{
    return ^SqlQueryStringStatementMaker *(NSString *limit){
        if (limit) {
            self.result = [self.result stringByAppendingFormat:@"LIMIT %@ ",limit];
        }
        return self;
    };
}



@end
@implementation SqlQueryStringValueMaker
- (SqlQueryStringValueMaker *(^)(NSString *))value{
    return ^SqlQueryStringValueMaker *(NSString *value){
        if (value) {
            self.result = [self.result stringByAppendingFormat:@"%@ ",value];
        }
        return self;
    };
}
- (SqlQueryStringValueMaker *(^)(NSString *))as{
    return ^SqlQueryStringValueMaker *(NSString *as){
        if (as) {
            self.result = [self.result stringByAppendingFormat:@"as %@,",as];
        }
        return self;
    };
}

@end

@implementation SqlQueryStringTableMaker

- (SqlQueryStringTableMaker *(^)(NSString *))table{
    return ^SqlQueryStringTableMaker *(NSString *table){
        if (table) {
            self.result = [self.result stringByAppendingFormat:@"%@ ",table];
        }
        return self;
    };
}

- (SqlQueryStringTableMaker *(^)(NSString *))as{
    return ^SqlQueryStringTableMaker *(NSString *as){
        if (as) {
            self.result = [self.result stringByAppendingFormat:@"as %@,",as];
        }
        return self;
    };
}

@end

@implementation SqlQueryStringConditionMaker
- (SqlQueryStringConditionMaker *(^)(NSString *))value{
    return ^SqlQueryStringConditionMaker *(NSString *value){
        if (value) {
            self.result = [self.result stringByAppendingFormat:@"%@ ",value];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *)also{
    self.result = [self.result stringByAppendingString:@"AND "];
    return  self;
}
- (SqlQueryStringConditionMaker *)either{
    self.result = [self.result stringByAppendingString:@"OR "];
    return self;
}

- (SqlQueryStringConditionMaker *(^)(NSString *))equalTo{
    return ^SqlQueryStringConditionMaker *(NSString *equalTo){
        if (equalTo) {
            self.result = [self.result stringByAppendingFormat:@"= %@ ",equalTo];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *(^)(NSString *))unequalTo{
    return ^SqlQueryStringConditionMaker *(NSString *unequalTo){
        if (unequalTo) {
            self.result = [self.result stringByAppendingFormat:@"<> %@ ",unequalTo];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *(^)(NSString *))greaterThan{
    return ^SqlQueryStringConditionMaker *(NSString *greaterThan){
        if (greaterThan) {
            self.result = [self.result stringByAppendingFormat:@"> %@ ",greaterThan];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *(^)(NSString *))lessThan{
    return ^SqlQueryStringConditionMaker *(NSString *lessThan){
        if (lessThan) {
            self.result = [self.result stringByAppendingFormat:@"< %@ ",lessThan];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *(^)(NSString *))between{
    return ^SqlQueryStringConditionMaker *(NSString *between){
        if (between) {
            self.result = [self.result stringByAppendingFormat:@"BETWEEN %@ ",between];
        }
        return self;
    };
}
- (SqlQueryStringConditionMaker *(^)(NSString *))like{
    return ^SqlQueryStringConditionMaker *(NSString *like){
        if (like) {
            self.result = [self.result stringByAppendingFormat:@"LIKE %@ ",like];
        }
        return self;
    };
}

@end


@implementation NSString (czw_splicingSqlQueryString)
+ (NSString *)makeSqlQueryString_statement:(void (^)(SqlQueryStringStatementMaker *makeQS))splicing
{
    SqlQueryStringStatementMaker *maker = [[SqlQueryStringStatementMaker alloc]init];
    splicing(maker);
    return maker.result;
}

+ (NSString *)makeSqlQueryString_value:(void (^)(SqlQueryStringValueMaker *makeQS_value))splicing
{
    SqlQueryStringValueMaker *maker = [[SqlQueryStringValueMaker alloc]init];
    splicing(maker);
    if ([[maker.result substringFromIndex:(maker.result.length-1)] isEqualToString:@","]) {
        maker.result = [maker.result stringByReplacingCharactersInRange:NSMakeRange((maker.result.length - 1), 1) withString:@" "];
    }
    return maker.result;
}

+ (NSString *)makeSqlQueryString_table:(void (^)(SqlQueryStringTableMaker *makeQS_table))splicing
{
    SqlQueryStringTableMaker *maker = [[SqlQueryStringTableMaker alloc]init];
    splicing(maker);
    if ([[maker.result substringFromIndex:(maker.result.length-1)] isEqualToString:@","]) {
        maker.result = [maker.result stringByReplacingCharactersInRange:NSMakeRange((maker.result.length - 1), 1) withString:@" "];
    }
    return maker.result;
}

+ (NSString *)makeSqlQueryString_condition:(void (^)(SqlQueryStringConditionMaker *makeQS_condition))splicing
{
    SqlQueryStringConditionMaker *maker = [[SqlQueryStringConditionMaker alloc]init];
    splicing(maker);
    if ([[maker.result substringFromIndex:(maker.result.length-1)] isEqualToString:@","]) {
        maker.result = [maker.result stringByReplacingCharactersInRange:NSMakeRange((maker.result.length - 1), 1) withString:@" "];
    }
    return maker.result;
}
@end


@implementation CZWSqlite
#pragma mark - sql相关操作


- (BOOL)sqliteOpen{
    if (sqlite3_open([self.currentDataBasePath UTF8String], &_database) == SQLITE_OK) {
        //NSLog(@"sqliteOpen成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteOpen打开失败:%s",sqlite3_errmsg(_database));
        return NO;
    }
}

- (BOOL)sqliteClose{
    if (sqlite3_close(_database) == SQLITE_OK) {
        //NSLog(@"sqliteClose成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteClose打开失败:%s",sqlite3_errmsg(_database));
        return NO;
    }
}




/**
 *  搜索table
 *  values = nil就是显示全部
 */

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit handler:(void (^)(NSMutableDictionary *))handler{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    if ([self sqliteOpen]) {
        sqlite3_stmt *stmt;
        NSString *selSql = [NSString makeSqlQueryString_statement:^(SqlQueryStringStatementMaker *make) {
            make.select(values).from(table).where(condition).groupBy(groupBy).orderBy(orderBy).limit(limit);
        }];
        //NSLog(@"Sql搜索语句 = %@",selSql);
        int ret2 = sqlite3_prepare_v2(_database, [selSql UTF8String], -1, &stmt, NULL);
        if (ret2 == SQLITE_OK) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {//遍历
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                int count = sqlite3_column_count(stmt);
                for (int i = 0; i < count; i ++) {
                    int dataType = sqlite3_column_type(stmt,i);
                    const char *columnName = sqlite3_column_name(stmt,i);
                    NSString *keyName = [NSString stringWithUTF8String:columnName];
                    switch (dataType) {
                        case SQLITE_INTEGER :{
                            int inter = sqlite3_column_int(stmt, i);
                            [dic setObject:[NSNumber numberWithInt:inter] forKey:keyName];
                            break;
                        }
                        case SQLITE_BLOB :{
                            NSLog(@"sql输出数据为blob类型，待完成");
                            break;
                        }
                        case SQLITE_TEXT :{
                            const char *text = (const char*)sqlite3_column_text(stmt, i);
                            NSString *textStr = nil;
                            if (text) {
                                textStr = [NSString stringWithUTF8String:text];
                            } else {
                                textStr = @"Not a valid string";
                            }
                            [dic setObject:textStr forKey:keyName];
                            break;
                        }
                        case SQLITE_FLOAT: {
                            double floater = sqlite3_column_double(stmt, i);
                            [dic setObject:[NSNumber numberWithDouble:floater] forKey:keyName];
                            break;
                        }
                        case SQLITE_NULL :{
                            NSLog(@"sql输出数据为空,待完成");
                            break;
                        }
                        default:{
                            NSLog(@"sql输出数据type不能识别");
                            
                            break;
                        }
                    }
                }
                
                handler(dic);
            }
        } else{
            NSLog(@"table打开失败:%s",sqlite3_errmsg(_database));
        }
        sqlite3_finalize(stmt);
        [self sqliteClose];
        NSLog(@"sqlite搜索库用时:%f",CFAbsoluteTimeGetCurrent() - startTime);
    } else {
        handler(NULL);
    }
}

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy handler:(void (^)(NSMutableDictionary *))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:groupBy orderBy:orderBy limit:nil handler:^(NSMutableDictionary *mDic) {
        handler(mDic);
    }];
}

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy handler:(void (^)(NSMutableDictionary *))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:groupBy orderBy:nil handler:^(NSMutableDictionary *mDic) {
        handler(mDic);
    }];
}

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition handler:(void (^)(NSMutableDictionary *))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:nil handler:^(NSMutableDictionary *mDic) {
        handler(mDic);
    }];
}

- (void)czw_searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(NSMutableDictionary *))handler{
    [self czw_searchValues:nil fromTable:table where:condition handler:^(NSMutableDictionary *mDic) {
        handler(mDic);
    }];
}

- (void)czw_searchTable:(NSString *)table handler:(void (^)(NSMutableDictionary *))handler{
    [self czw_searchTable:table where:nil handler:^(NSMutableDictionary *mDic) {
        handler(mDic);
    }];
}
@end
