//
//  CZWSqlite.h
//  CZWSQL
//
//  Created by tianqu on 16/6/20.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface SqlQueryStringMaker : NSObject
@property (copy, nonatomic) NSString *result;
- (SqlQueryStringMaker *(^)(NSString *))select;
- (SqlQueryStringMaker *(^)(NSString *))from;
- (SqlQueryStringMaker *(^)(NSString *))where;
- (SqlQueryStringMaker *(^)(NSString *))groupBy;
- (SqlQueryStringMaker *(^)(NSString *))orderBy;
- (SqlQueryStringMaker *(^)(NSString *))limit;
@end

@interface NSString (czw_splicingSqlQueryString)
+ (NSString *)makeSqlQueryString:(void (^)(SqlQueryStringMaker *makeQS))splicing;
@end
@interface CZWSqlite : NSObject
@property (copy, nonatomic) NSString *currentDataBasePath;
@property (assign, nonatomic) sqlite3 *database;


- (NSString *)textToSimplified:(NSString *)text;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit handler:(void (^)(NSMutableDictionary *))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy handler:(void (^)(sqlite3_stmt *stmt))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy handler:(void (^)(sqlite3_stmt *stmt))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handler;

- (void)czw_searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handler;

- (void)czw_searchTable:(NSString *)table handler:(void (^)(sqlite3_stmt *stmt))handler;
@end
