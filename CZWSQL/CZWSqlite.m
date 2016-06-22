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
            self.result = [self.result stringByAppendingFormat:@"%@ ",values];
        } else {
            self.result = [self.result stringByAppendingFormat:@"* "];
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
                    switch (dataType) {
                        case SQLITE_INTEGER :{
                            int lineId = sqlite3_column_int(stmt, i);
                            dic setObject:[ forKey:<#(nonnull id<NSCopying>)#>
                            break;
                        }
                        case SQLITE_BLOB :{
                            
                            break;
                        }
                        case SQLITE_TEXT :{
                            
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

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:groupBy orderBy:orderBy limit:nil handler:^(sqlite3_stmt *stmt) {
        handler(stmt);
    }];
}

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:groupBy orderBy:nil handler:^(sqlite3_stmt *stmt) {
        handler(stmt);
    }];
}

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self czw_searchValues:values fromTable:table where:condition groupBy:nil handler:^(sqlite3_stmt *stmt) {
        handler(stmt);
    }];
}

- (void)czw_searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self czw_searchValues:nil fromTable:table where:condition handler:^(sqlite3_stmt *stmt) {
        handler(stmt);
    }];
}

- (void)czw_searchTable:(NSString *)table handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self czw_searchTable:table where:nil handler:^(sqlite3_stmt *stmt) {
        handler(stmt);
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
