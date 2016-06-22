//
//  CZWSqlite.m
//  CZWSQL
//
//  Created by tianqu on 16/6/20.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "CZWSqlite.h"
#import "convertGB_BIG.h"
@implementation SqlQueryStringMaker

/**
 *  拼语句
 */
- (SqlQueryStringMaker *(^)(NSString *))select{
    return ^SqlQueryStringMaker *(NSString *values){
        if (values) {
            self.result = [self.result stringByAppendingFormat:@"SELECT %@ ",values];
        } else {
            self.result = [self.result stringByAppendingFormat:@"SELECT * "];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))from{
    return ^SqlQueryStringMaker *( NSString *tables){
        if (tables) {
            self.result = [self.result stringByAppendingFormat:@"FROM %@ ",tables];
        } else {
            @throw [NSException exceptionWithName:@"SqlQueryStringMaker from('table') cannot be nil" reason:@"check SqlQueryStringMaker" userInfo:nil];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))where{
    return ^SqlQueryStringMaker *(NSString *where){
        if (where) {
            self.result = [self.result stringByAppendingFormat:@"WHERE %@ ",where];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))groupBy{
    return ^SqlQueryStringMaker *(NSString *groupBy){
        if (groupBy) {
            self.result = [self.result stringByAppendingFormat:@"GROUP BY %@ ",groupBy];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))orderBy{
    return ^SqlQueryStringMaker *(NSString *orderBy){
        if (orderBy) {
            self.result = [self.result stringByAppendingFormat:@"ORDER BY %@ ",orderBy];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))limit{
    return ^SqlQueryStringMaker *(NSString *limit){
        if (limit) {
            self.result = [self.result stringByAppendingFormat:@"LIMIT %@ ",limit];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))value{
    return ^SqlQueryStringMaker *(NSString *value){
        if (value) {
            self.result = [self.result stringByAppendingFormat:@"%@ ",value];
        }
        return self;
    };
}

- (SqlQueryStringMaker *(^)(NSString *))as{
    return ^SqlQueryStringMaker *(NSString *as){
        if (as) {
            self.result = [self.result stringByAppendingFormat:@"as %@,",as];
        }
        return self;
    };
}

@end

@implementation NSString (czw_splicingSqlQueryString)

+ (NSString *)makeSqlQueryString:(void (^)(SqlQueryStringMaker *makeQS))splicing
{
    SqlQueryStringMaker *maker = [[SqlQueryStringMaker alloc]init];
    maker.result = [[NSString alloc]init];
    splicing(maker);
    return maker.result;
}
+ (NSString *)makeSqlQueryString_value:(void (^)(SqlQueryStringMaker *makeQS_value))splicing
{
    SqlQueryStringMaker *maker = [[SqlQueryStringMaker alloc]init];
    maker.result = [[NSString alloc]init];
    splicing(maker);
    NSString *str = [maker.result substringFromIndex:(maker.result.length-1)];
    if ([[maker.result substringFromIndex:(maker.result.length-1)] isEqualToString:@","]) {
        maker.result
        NSString *da =
        [maker.result substringWithRange:NSMakeRange((maker.result.length - 2), 2)];
        [maker.result stringByReplacingCharactersInRange:NSMakeRange((maker.result.length - 2), 2) withString:@" "];
    }
    return maker.result;
}
@end


@implementation CZWSqlite
#pragma mark - sql相关操作


- (BOOL)sqliteOpen{
    if (sqlite3_open([self.currentDataBasePath UTF8String], &_database) == SQLITE_OK) {
        NSLog(@"sqliteOpen成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteOpen打开失败:%s",sqlite3_errmsg(_database));
        return NO;
    }
}

- (BOOL)sqliteClose{
    if (sqlite3_close(_database) == SQLITE_OK) {
        NSLog(@"sqliteClose成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteClose打开失败:%s",sqlite3_errmsg(_database));
        return NO;
    }
}




/**
 *  搜索table
 */

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit handler:(void (^)(NSMutableDictionary *))handler{
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    if ([self sqliteOpen]) {
        sqlite3_stmt *stmt;
        NSString *selSql = [NSString makeSqlQueryString:^(SqlQueryStringMaker *makeQS) {
            makeQS.select(values).from(table).where(condition).groupBy(groupBy).orderBy(orderBy).limit(limit);
        }];
        NSLog(@"Sql搜索语句 = %@",selSql);
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

/**
 *  繁体转简体;
 */

- (NSString *)textToSimplified:(NSString *)text{
    convertGB_BIG *convertGbToBig = [[convertGB_BIG alloc] init];
    return [convertGbToBig big5ToGb:[text uppercaseString]];
}
@end
