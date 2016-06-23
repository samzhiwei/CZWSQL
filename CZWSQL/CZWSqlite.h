//
//  CZWSqlite.h
//  CZWSQL
//
//  Created by tianqu on 16/6/20.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface SqlQueryStringBaseMaker : NSObject;
@property (copy, nonatomic) NSString *result;
@end

@interface SqlQueryStringStatementMaker : SqlQueryStringBaseMaker
- (SqlQueryStringStatementMaker *(^)(NSString *))select;
- (SqlQueryStringStatementMaker *(^)(NSString *))from;
- (SqlQueryStringStatementMaker *(^)(NSString *))where;
- (SqlQueryStringStatementMaker *(^)(NSString *))groupBy;
- (SqlQueryStringStatementMaker *(^)(NSString *))orderBy;
- (SqlQueryStringStatementMaker *(^)(NSString *))limit;
@end

@interface SqlQueryStringValueMaker : SqlQueryStringBaseMaker;
- (SqlQueryStringValueMaker *(^)(NSString *))value;
- (SqlQueryStringValueMaker *(^)(NSString *))as;
@end

@interface SqlQueryStringTableMaker : SqlQueryStringBaseMaker;
/**
 *  跟value方法实现一样
 */
- (SqlQueryStringTableMaker *(^)(NSString *))table;
- (SqlQueryStringTableMaker *(^)(NSString *))as;
@end

@interface SqlQueryStringConditionMaker : SqlQueryStringBaseMaker;
- (SqlQueryStringConditionMaker *(^)(NSString *))value;
/**
 *  相当于and语句
 */
- (SqlQueryStringConditionMaker *)also;
/**
 *  相当于or语句
 */
- (SqlQueryStringConditionMaker *)either;
- (SqlQueryStringConditionMaker *(^)(NSString *))equalTo;
- (SqlQueryStringConditionMaker *(^)(NSString *))unequalTo;
- (SqlQueryStringConditionMaker *(^)(NSString *))greaterThan;
- (SqlQueryStringConditionMaker *(^)(NSString *))lessThan;
- (SqlQueryStringConditionMaker *(^)(NSString *))between;
- (SqlQueryStringConditionMaker *(^)(NSString *))like;
@end

@interface NSString (czw_splicingSqlQueryString)
/**
 *  建立查询语句
 */
+ (NSString *)makeSqlQueryString_statement:(void (^)(SqlQueryStringStatementMaker *make))splicing;
+ (NSString *)makeSqlQueryString_value:(void (^)(SqlQueryStringValueMaker *make))splicing;
+ (NSString *)makeSqlQueryString_table:(void (^)(SqlQueryStringTableMaker *make))splicing;
+ (NSString *)makeSqlQueryString_condition:(void (^)(SqlQueryStringConditionMaker *make))splicing;
@end
@interface CZWSqlite : NSObject
@property (copy, nonatomic) NSString *currentDataBasePath;
@property (assign, nonatomic) sqlite3 *database;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy limit:(NSString *)limit handler:(void (^)(NSMutableDictionary *mDic))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy orderBy:(NSString *)orderBy handler:(void (^)(NSMutableDictionary *))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition groupBy:(NSString *)groupBy handler:(void (^)(NSMutableDictionary *))handler;

- (void)czw_searchValues:(NSString *)values fromTable:(NSString *)table where:(NSString *)condition handler:(void (^)(NSMutableDictionary *))handler;

- (void)czw_searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(NSMutableDictionary *))handler;

- (void)czw_searchTable:(NSString *)table handler:(void (^)(NSMutableDictionary *))handler;
@end
