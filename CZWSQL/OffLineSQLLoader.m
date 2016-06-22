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

@implementation NSString (czw_splicingSqlQueryString)

+ (NSString *)makeSqlQueryString:(void (^)(SqlQueryStringMaker *makeQS))splicing
{
    SqlQueryStringMaker *maker = [[SqlQueryStringMaker alloc]init];
    maker.result = @"SELECT ";
    splicing(maker);
    return maker.result;
}
@end

@interface OffLineSQLLoader ()
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

#pragma mark - Api

- (NSMutableArray *)searchAllLineCategory{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    
    [self czw_searchValues:@"id,name" fromTable:@"category" where:nil handler:^(sqlite3_stmt *stmt) {
        int categoryId = sqlite3_column_int(stmt, 0);
        const char *name = (const char *)sqlite3_column_blob(stmt, 1);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSNumber numberWithInt:categoryId] forKey:@"categoryId"];
        [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
        [resultArray addObject:dic];
    }];
    
    return resultArray;
}

- (NSMutableArray *)searchLineWithCategoryId:(NSNumber *)categoryId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *condition = [NSString stringWithFormat:@"categoryid = %d",[categoryId intValue]];
    [self czw_searchValues:@"name ,code ,id" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(sqlite3_stmt *stmt) {
        const char *name = (const char *)sqlite3_column_blob(stmt, 0);
        const char *code = (const char *)sqlite3_column_blob(stmt, 1);
        int lineId = sqlite3_column_int(stmt, 2);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:code] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:lineId] forKey:@"lineId"];
        [resultArray addObject:dic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchLineWithLineCode:(NSString *)lineCode{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *values = [NSString stringWithFormat:@"l.name ,l.code ,l.number ,lo.time,lo.lastupdate,lo.start,lo.end ,c.name ,lo.note ,lo.fare"];
    NSString *tables = [NSString stringWithFormat:@"lines as l ,linesothers as lo,company as c"];
    NSString *condition = [NSString stringWithFormat:@"lo.companyid = c.id AND l.id = lo.lineid AND l.code = '%@'",lineCode];
    [self czw_searchValues:values fromTable:tables where:condition handler:^(sqlite3_stmt *stmt) {
        const char *lineName = (const char *)sqlite3_column_blob(stmt, 0);
        const char *lineCode = (const char *)sqlite3_column_blob(stmt, 1);
        int lineNumber = sqlite3_column_int(stmt, 2);
        const char *time = (const char *)sqlite3_column_blob(stmt, 3);
        const char *lastUpDate = (const char *)sqlite3_column_blob(stmt, 4);
        const char *start = (const char *)sqlite3_column_blob(stmt, 5);
        const char *end = (const char *)sqlite3_column_blob(stmt, 6);
        const char *companyName = (const char *)sqlite3_column_blob(stmt, 7);
        const char *note = (const char *)sqlite3_column_blob(stmt, 8);
        const char *fare = (const char *)sqlite3_column_blob(stmt, 9);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSString stringWithUTF8String:lineName] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:lineCode] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:lineNumber] forKey:@"lineNumber"];
        [dic setObject:[NSString stringWithUTF8String:time] forKey:@"serviceTime"];
        [dic setObject:[NSString stringWithUTF8String:lastUpDate] forKey:@"lastUpDate"];
        [dic setObject:[NSString stringWithUTF8String:start] forKey:@"starting"];
        [dic setObject:[NSString stringWithUTF8String:end] forKey:@"terminal"];
        [dic setObject:[NSString stringWithUTF8String:companyName] forKey:@"companyName"];
        if (note == NULL) {
            [dic setObject:@"" forKey:@"note"];
        } else {
            [dic setObject:[NSString stringWithUTF8String:note] forKey:@"note"];
        }
        if (fare == NULL) {
            [dic setObject:@"" forKey:@"fare"];
        } else {
            [dic setObject:[NSString stringWithUTF8String:fare] forKey:@"fare"];
        }
        [resultArray addObject:dic];
    }];
    return resultArray;
}


- (NSMutableArray *)searchLineWithText:( NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
    [self czw_searchValues:@"name,code,id" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(sqlite3_stmt *stmt) {
        const char *name = (const char *)sqlite3_column_blob(stmt, 0);
        const char *code = (const char *)sqlite3_column_blob(stmt, 1);
        int lineId = sqlite3_column_int(stmt, 2);//查询线路有多少站点用
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        NSString* lineName = [NSString stringWithUTF8String:name];
        NSString *lineCode = [NSString stringWithUTF8String:code];
        [dic setObject:lineName forKey:@"name"];
        [dic setObject:lineCode forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:lineId] forKey:@"lineId"];
        [resultArray addObject:dic];
    }];
    
#warning todo:排序
    return resultArray;
}

- (NSMutableArray *)searchStationInLineWithLineId:(NSNumber *)lineId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *values = @"s.id as id, s.name as name, s.code as code, s.type as type, ss.pm1 as pm1, ss.pm2 as pm2, ss.pm3 as pm3, c.longitude1 as longitude1, c.latitude1 as latitude1, c.longitude2 as longitude2, c.latitude2 as latitude2, c.longitude3 as longitude3, c.latitude3 as latitude3 ,s.zid as zid";
    NSString *tables = @"station as s,stations as ss,coordinate as c";
    NSString *condition = [NSString stringWithFormat:@"s.id=ss.stationid and ss.id=c.stationsid and ss.lineid=%d",[lineId intValue]];
    [self czw_searchValues:values fromTable:tables where:condition handler:^(sqlite3_stmt *stmt) {
        int stationId = sqlite3_column_int(stmt, 0);
        const char *stationName = sqlite3_column_blob(stmt, 1);
        const char *stationCode = sqlite3_column_blob(stmt, 2);
        int type = sqlite3_column_int(stmt, 3);//1为有地铁的站
        int pm1 = sqlite3_column_int(stmt, 4);//去程站点顺序号
        int pm2 = sqlite3_column_int(stmt, 5);//回程站点顺序号
        int pm3 = sqlite3_column_int(stmt, 6);//环线站点顺序号
        int lat1 = sqlite3_column_int(stmt, 7);
        int lng1 = sqlite3_column_int(stmt, 8);
        int lat2 = sqlite3_column_int(stmt, 9);
        int lng2 = sqlite3_column_int(stmt, 10);
        int lat3 = sqlite3_column_int(stmt, 11);
        int lng3 = sqlite3_column_int(stmt, 12);
        int zid = sqlite3_column_int(stmt, 13);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSNumber numberWithInt:stationId] forKey:@"identification"];
        [dic setObject:[NSString stringWithUTF8String:stationName] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:stationCode] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:type] forKey:@"type"];
        [dic setObject:[NSNumber numberWithInt:pm1] forKey:@"pm1"];
        [dic setObject:[NSNumber numberWithInt:pm2] forKey:@"pm2"];
        [dic setObject:[NSNumber numberWithInt:pm3] forKey:@"pm3"];
        [dic setObject:[NSNumber numberWithFloat:lat1/100000.0f] forKey:@"lat1"];
        [dic setObject:[NSNumber numberWithFloat:lng1/100000.0f] forKey:@"lng1"];
        [dic setObject:[NSNumber numberWithFloat:lat2/100000.0f] forKey:@"lat2"];
        [dic setObject:[NSNumber numberWithFloat:lng2/100000.0f] forKey:@"lng2"];
        [dic setObject:[NSNumber numberWithFloat:lat3/100000.0f] forKey:@"lat3"];
        [dic setObject:[NSNumber numberWithFloat:lng3/100000.0f] forKey:@"lng3"];
        [dic setObject:[NSNumber numberWithInt:zid] forKey:@"zid"];
        [resultArray addObject:dic];
    }];
    
    return resultArray;
}


- (NSMutableArray *)searchStationWithText:(NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
    [self czw_searchValues:nil fromTable:@"station" where:condition groupBy:@"code" orderBy:nil limit:nil handler:^(sqlite3_stmt *stmt) {
        int stationId = sqlite3_column_int(stmt, 0);
        const char *name = sqlite3_column_blob(stmt, 1);
        const char *pinyin = sqlite3_column_blob(stmt, 2);
        const char *code = sqlite3_column_blob(stmt, 3);
        int type = sqlite3_column_int(stmt, 4);
        int lat = sqlite3_column_int(stmt, 6);
        int lng = sqlite3_column_int(stmt, 5);
        int zid = sqlite3_column_int(stmt, 7);//查询站点有多少路线经过用
        //const char *zhan = sqlite3_column_blob(stmt, 8);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSNumber numberWithInt:stationId] forKey:@"identification"];
        [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:pinyin] forKey:@"pinyin"];
        [dic setObject:[NSString stringWithUTF8String:code] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:type] forKey:@"type"];//1为地铁
        [dic setObject:[NSNumber numberWithFloat:lat/100000.0] forKey:@"lat"];
        [dic setObject:[NSNumber numberWithFloat:lng/100000.0] forKey:@"lng"];
        [dic setObject:[NSNumber numberWithInt:zid] forKey:@"zid"];
        //[dic setObject:[NSString stringWithUTF8String:zhan] forKey:@"zhan"];
        if ([NSString stringWithUTF8String:name]) {
            [resultArray addObject:dic];
        }
    }];
#warning todo :排序
    return resultArray;
}

- (NSMutableArray *)searchStationWithPinyin:(NSString *)pinyin{
    NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *condition = [NSString stringWithFormat:@"pinyin like '%%%@%%'",pinyin];
    [self czw_searchValues:nil fromTable:@"station" where:condition groupBy:nil orderBy:nil limit:@"10" handler:^(sqlite3_stmt *stmt) {
        int stationId = sqlite3_column_int(stmt, 0);
        const char *name = sqlite3_column_blob(stmt, 1);
        const char *pinyin = sqlite3_column_blob(stmt, 2);
        const char *code = sqlite3_column_blob(stmt, 3);
        int type = sqlite3_column_int(stmt, 4);
        int lat = sqlite3_column_int(stmt, 6);
        int lng = sqlite3_column_int(stmt, 5);
        int zid = sqlite3_column_int(stmt, 7);//查询站点有多少路线经过用
        //const char *zhan = sqlite3_column_blob(stmt, 8);
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSNumber numberWithInt:stationId] forKey:@"identification"];
        [dic setObject:[NSString stringWithUTF8String:name] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:pinyin] forKey:@"pinyin"];
        [dic setObject:[NSString stringWithUTF8String:code] forKey:@"code"];
        [dic setObject:[NSNumber numberWithInt:type] forKey:@"type"];//1为地铁
        [dic setObject:[NSNumber numberWithFloat:lat/100000.0] forKey:@"lat"];
        [dic setObject:[NSNumber numberWithFloat:lng/100000.0] forKey:@"lng"];
        [dic setObject:[NSNumber numberWithInt:zid] forKey:@"zid"];
        //[dic setObject:[NSString stringWithUTF8String:zhan] forKey:@"zhan"];
        if ([NSString stringWithUTF8String:name]) {
            [resultArray addObject:dic];
        }
    }];
    return resultArray;
}

- (NSMutableArray *)searchLineViaStationWithZid:(NSNumber *)zid{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if (!zid) {
        return nil;
    }
    
    NSString *values = @"distinct l.id as id,l.number as number,l.name as name,l.code as code,c.name as categoryname,l.type as type,o.time as time,o.fare as fare,o.note as note,o.lastupdate as lastupdate,cp.name as companyname,o.start as start,o.end as end";
    NSString *tables = @"station as s,stations as ss,lines as l,category as c,linesothers as o,company as cp";
    NSString *condition = [NSString stringWithFormat:@"s.id=ss.stationid and ss.lineid=l.id and l.categoryid=c.id and l.id=o.lineid and o.companyid=cp.id and s.zid=%d",[zid intValue]];
    
    [self czw_searchValues:values fromTable:tables where:condition groupBy:nil orderBy:@"l.number" handler:^(sqlite3_stmt *stmt) {
        int lineId = sqlite3_column_int(stmt, 0);
        int lineNumber = sqlite3_column_int(stmt, 1);
        const char *lineName = sqlite3_column_blob(stmt, 2);
        const char *lineCode = sqlite3_column_blob(stmt, 3);
        const char *lineCategoryName = sqlite3_column_blob(stmt, 4);
        int lineType = sqlite3_column_int(stmt, 5);//1为地铁
        const char *time = sqlite3_column_blob(stmt, 6);//运营时间
        const char *fare = sqlite3_column_blob(stmt, 7);
        const char *note = sqlite3_column_blob(stmt, 8);
        const char *lastUpDate = sqlite3_column_blob(stmt, 9);
        const char *companyname = sqlite3_column_blob(stmt, 10);
        const char *start = sqlite3_column_blob(stmt, 11);//起始站
        const char *end = sqlite3_column_blob(stmt, 12);//终点站
        
        
        const char *clonme = sqlite3_column_decltype(stmt,2);
        NSString *coll = [NSString stringWithUTF8String:clonme];

        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[NSNumber numberWithInt:lineId] forKey:@"identification"];
        [dic setObject:[NSNumber numberWithInt:lineNumber] forKey:@"number"];
        [dic setObject:[NSString stringWithUTF8String:lineName] forKey:@"name"];
        [dic setObject:[NSString stringWithUTF8String:lineCode] forKey:@"code"];
        [dic setObject:[NSString stringWithUTF8String:lineCategoryName] forKey:@"categoryName"];
        [dic setObject:[NSNumber numberWithInt:lineType] forKey:@"type"];
        [dic setObject:[NSString stringWithUTF8String:time] forKey:@"serviceTime"];
        if (fare != NULL) {
            [dic setObject:[NSString stringWithUTF8String:fare] forKey:@"fare"];
        } else {
            [dic setObject:@"" forKey:@"fare"];
        }
        if (note != NULL) {
            [dic setObject:[NSString stringWithUTF8String:note] forKey:@"note"];
        } else {
            [dic setObject:@"" forKey:@"note"];
        }
        [dic setObject:[NSString stringWithUTF8String:lastUpDate] forKey:@"lastUpDate"];
        [dic setObject:[NSString stringWithUTF8String:companyname] forKey:@"companyName"];
        [dic setObject:[NSString stringWithUTF8String:start] forKey:@"starting"];
        [dic setObject:[NSString stringWithUTF8String:end] forKey:@"terminal"];
        [resultArray addObject:dic];
    }];
    return resultArray;
}

@end




