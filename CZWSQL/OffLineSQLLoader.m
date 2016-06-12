//
//  OffLineSQLLoader.m
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "OffLineSQLLoader.h"
#import "convertGB_BIG/convertGB_BIG.h"
#import <sqlite3.h>
@interface OffLineSQLLoader ()
@property (copy, nonatomic) NSString *currentDataBasePath;
@property (assign, nonatomic) sqlite3 *database;
@end
@implementation OffLineSQLLoader

+ (instancetype)shareLoader{
    static dispatch_once_t onceToken;
    static id sharedInstance; dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentDataBasePath = nil;
    }
    return self;
}

/**
 *  设定sql读取路径用
 */

- (void)configureDataBasePathWithCityPinyin:(NSString *)pinyin{
    NSString *str = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sql", pinyin]];
    self.currentDataBasePath = path;
}

#pragma mark - sql相关操作
- (BOOL)sqliteOpen{
    if (sqlite3_open([self.currentDataBasePath UTF8String], &_database) == SQLITE_OK) {
        NSLog(@"sqliteOpen成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteOpen失败");
        return NO;
    }
}

- (BOOL)sqliteClose{
    if (sqlite3_close(_database) == SQLITE_OK) {
        NSLog(@"sqliteClose成功->path:%@",self.currentDataBasePath);
        return YES;
    } else {
        NSLog(@"sqliteClose失败");
        return NO;
    }
}


/**
 *  拼语句
 */
- (NSString *)splicingQueryStringFromTable:(NSString *)table where:(NSString *)condition{
    NSString *select = [NSString stringWithFormat:@"SELECT * FROM %@",table];
    if (condition) {
        NSString *where = [NSString stringWithFormat:@" where %@ ",condition];
        select = [select stringByAppendingString:where];
    }
    return select;
}

- (void)searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handle{
    sqlite3_stmt *stmt;
    NSString *selSql = [self splicingQueryStringFromTable:table where:condition];
    int ret2 = sqlite3_prepare_v2(_database, [selSql UTF8String], -1, &stmt, NULL);
    if (ret2 == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {//遍历
            handle(stmt);
        }
    } else{
        NSLog(@"table打开失败:%s",sqlite3_errmsg(_database));
    }
    sqlite3_finalize(stmt);
}

/**
 *  繁体转简体;
 */

- (NSString *)textToSimplified:(NSString *)text{
    convertGB_BIG *convertGbToBig = [[convertGB_BIG alloc] init];
    return [convertGbToBig big5ToGb:[text uppercaseString]];
}

- (NSArray *)czw_searchLineWithText:(NSString *)searchText{
    //todo:先将查询text繁体转简体;
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    if ([self sqliteOpen]) {
        NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [self searchTable:@"lines" where:condition handler:^(sqlite3_stmt *stmt) {
            int lineid = sqlite3_column_int(stmt, 0);
            const char *name = (const char *)sqlite3_column_blob(stmt, 1);
            int categoryID = sqlite3_column_int(stmt, 2);
            int isShow = sqlite3_column_int(stmt, 3);
            int number = sqlite3_column_int(stmt, 4);
            const char *code = (const char *)sqlite3_column_blob(stmt, 5);
            int type = sqlite3_column_int(stmt, 6);
            int sudu = sqlite3_column_int(stmt, 7);
            NSString* lineName = [NSString stringWithUTF8String:name];
            NSString *lineCode = [NSString stringWithUTF8String:code];
            NSLog(@"lineid = %d,lineName = %@, categoryID = %d ,isShow = %d ,number = %d ,lineCode = %@ ,type = %d ,sudu = %d",lineid,lineName,categoryID,isShow,number,lineCode,type,sudu);
            [dic setObject:[NSNumber numberWithInt:lineid] forKey:@"lineid"];
            [dic setObject:lineName forKey:@"lineName"];
            [dic setObject:[NSNumber numberWithInt:categoryID] forKey:@"categoryID"];
            [dic setObject:[NSNumber numberWithInt:isShow] forKey:@"isShow"];
            [dic setObject:[NSNumber numberWithInt:number] forKey:@"number"];
            [dic setObject:lineCode forKey:@"lineCode"];
            [resultArray addObject:dic];
        }];
        
    } else {
        NSLog(@"table打开失败:%s",sqlite3_errmsg(_database));
    }
    [self sqliteClose];
    return resultArray;
}
@end
