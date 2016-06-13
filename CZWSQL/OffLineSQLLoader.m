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
    NSString *path = [str stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", pinyin]];
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
- (NSString *)select:(NSString *)outPut{
    NSString *select = nil;
    if (outPut.length == 0) {
        select = [NSString stringWithFormat:@"SELECT %@ ",outPut];
    } else {
        select = [NSString stringWithFormat:@"SELECT * "];
    }
    return select;
}

- (NSString *)where:(NSString *)condition{
    NSString *where = nil;
    if (condition.length == 0) {
        NSString *where = [NSString stringWithFormat:@"WHERE %@",condition];
        where = [where stringByAppendingString:where];
    } else {
        return where;
    }
}
    

- (NSString *)splicingQueryStrWithFromOutPut:(NSString *)outPut fromTable:(NSString *)table where:(NSString *)condition orderBy:(NSString *)orderBy limit:(NSNumber *)limit{
    if (table.length == 0) {
        return nil;
    }
    NSString *select = [[self select:outPut] stringByAppendingFormat:@"%@",table];
    
    if (condition) {
        select = [select stringByAppendingString:]
    }
    return select;
}

/**
 *  搜索table
 */
- (void)searchTable:(NSString *)table where:(NSString *)condition handler:(void (^)(sqlite3_stmt *stmt))handler{
    sqlite3_stmt *stmt;
    NSString *selSql = [self splicingQueryStringFromTable:table where:condition];
    int ret2 = sqlite3_prepare_v2(_database, [selSql UTF8String], -1, &stmt, NULL);
    if (ret2 == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {//遍历
            handler(stmt);
        }
    } else{
        NSLog(@"table打开失败:%s",sqlite3_errmsg(_database));
    }
    sqlite3_finalize(stmt);
}

- (void)searchTable:(NSString *)table where:(NSString *)condition outPut:(NSString *)outPut handler:(void (^)(sqlite3_stmt *stmt))handler{
    [self searchTable:table where:condition handler:^(sqlite3_stmt *stmt) {
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

#pragma mark - Api

- (NSMutableArray *)czw_searchAllLineCategory{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if ([self sqliteOpen]) {
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [self searchTable:@"category" where:nil handler:^(sqlite3_stmt *stmt) {
            int categoryId = sqlite3_column_int(stmt, 0);
            const char *name = (const char *)sqlite3_column_blob(stmt, 1);
            [dic setObject:[NSNumber numberWithInt:categoryId] forKey:@"categoryId"];
            [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
            [resultArray addObject:dic];
        }];
        
        [self sqliteClose];
    }
    
    return resultArray;
}

- (NSMutableArray *)czw_searchLineWithCategoryId:(NSNumber *)categoryId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if ([self sqliteOpen]) {
        NSString *condition = [NSString stringWithFormat:@"categoryid = %d",[categoryId intValue]];
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [self searchTable:@"lines" where:condition handler:^(sqlite3_stmt *stmt) {
            int lineid = sqlite3_column_int(stmt, 0);
        }]
        
        
        [self sqliteClose];
    }
}


- (NSMutableArray *)czw_searchLineWithText:( NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    if ([self sqliteOpen]) {
        NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [self searchTable:@"lines" where:condition handler:^(sqlite3_stmt *stmt) {
            int lineid = sqlite3_column_int(stmt, 0);
            const char *name = (const char *)sqlite3_column_blob(stmt, 1);
            int categoryId = sqlite3_column_int(stmt, 2);
            int isShow = sqlite3_column_int(stmt, 3);
            int number = sqlite3_column_int(stmt, 4);
            const char *code = (const char *)sqlite3_column_blob(stmt, 5);
            int type = sqlite3_column_int(stmt, 6);
            int sudu = sqlite3_column_int(stmt, 7);
            NSString* lineName = [NSString stringWithUTF8String:name];
            NSString *lineCode = [NSString stringWithUTF8String:code];//查询线路有多少站点用
            NSLog(@"lineid = %d,lineName = %@, categoryID = %d ,isShow = %d ,number = %d ,lineCode = %@ ,type = %d ,sudu = %d",lineid,lineName,categoryId,isShow,number,lineCode,type,sudu);
            [dic setObject:[NSNumber numberWithInt:lineid] forKey:@"identification"];
            [dic setObject:lineName forKey:@"lineName"];
            [dic setObject:[NSNumber numberWithInt:categoryId] forKey:@"categoryId"];
            [dic setObject:[NSNumber numberWithInt:isShow] forKey:@"isShow"];
            [dic setObject:[NSNumber numberWithInt:number] forKey:@"lineNumber"];
            [dic setObject:lineCode forKey:@"lineCode"];
            [resultArray addObject:dic];
        }];
        [self sqliteClose];
    } else {
        NSLog(@"table打开失败:%s",sqlite3_errmsg(_database));
    }
    
#warning todo:排序
    return resultArray;
}

- (NSMutableArray *)czw_searchStationWithText:(NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    if ([self sqliteOpen]) {
        NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
        __block NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [self searchTable:@"station" where:condition handler:^(sqlite3_stmt *stmt) {
            int stationId = sqlite3_column_int(stmt, 0);
            const char *name = sqlite3_column_blob(stmt, 1);
            const char *pinyin = sqlite3_column_blob(stmt, 2);
            const char *code = sqlite3_column_blob(stmt, 3);
            int type = sqlite3_column_int(stmt, 4);
            int lat = sqlite3_column_int(stmt, 6);
            int lng = sqlite3_column_int(stmt, 5);
            int zid = sqlite3_column_int(stmt, 7);//查询站点有多少路线经过用
            //const char *zhan = sqlite3_column_blob(stmt, 8);
            [dic setObject:[NSNumber numberWithInt:stationId] forKey:@"identification"];
            [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
            [dic setObject:[NSString stringWithUTF8String:pinyin] forKey:@"pinyin"];
            [dic setObject:[NSString stringWithUTF8String:code] forKey:@"code"];
            [dic setObject:[NSNumber numberWithInt:type] forKey:@"type"];
            [dic setObject:[NSNumber numberWithFloat:lat/100000.0] forKey:@"lat"];
            [dic setObject:[NSNumber numberWithFloat:lng/100000.0] forKey:@"lng"];
            [dic setObject:[NSNumber numberWithInt:zid] forKey:@"stationId"];
            //[dic setObject:[NSString stringWithUTF8String:zhan] forKey:@"zhan"];
            if ([NSString stringWithUTF8String:name]) {
                [resultArray addObject:dic];
            }
        }];
        
        [self sqliteClose];
    }
#warning todo :排序&合并同名站点(有可能是站点位置有稍微变动)
    return resultArray;
}
@end
