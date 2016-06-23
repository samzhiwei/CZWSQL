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
    
    [self czw_searchValues:@"id as identification,name" fromTable:@"category" where:nil handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    
    return resultArray;
}

- (NSMutableArray *)searchLineWithCategoryId:(NSNumber *)categoryId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *condition = [NSString stringWithFormat:@"categoryid = %d",[categoryId intValue]];
    [self czw_searchValues:@"name ,code ,id as identification" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchLineWithLineCode:(NSString *)lineCode{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *values = [NSString makeSqlQueryString_value:^(SqlQueryStringValueMaker *make) {
        make.value(@"l.id").as(@"identification").
        value(@"l.name").as(@"name").
        value(@"l.code").as(@"code").
        value(@"l.number").as(@"number").
        value(@"l.type").as(@"type").
        value(@"lo.time").as(@"serviceTime").
        value(@"lo.lastupdate").as(@"lastUpdate").
        value(@"lo.start").as(@"starting").
        value(@"lo.end").as(@"terminal").
        value(@"c.name").as(@"companyName").
        value(@"lo.note").as(@"note").
        value(@"lo.fare").as(@"fare");
    }];
    NSString *tables = [NSString makeSqlQueryString_table:^(SqlQueryStringTableMaker *make) {
        make.table(@"lines").as(@"l").
        table(@"linesothers").as(@"lo").
        table(@"company").as(@"c");
    }];
    NSString *conditions = [NSString makeSqlQueryString_condition:^(SqlQueryStringConditionMaker *make) {
        NSString *code = [NSString stringWithFormat:@"'%@'",lineCode];
        NSLog(@"code = %p",code);
        make.value(@"lo.companyid").equalTo(@"c.id").also.
        value(@"l.id").equalTo(@"lo.lineid").also.
        value(@"l.code").equalTo(code);
    }];
    
    [self czw_searchValues:values fromTable:tables where:conditions handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}


- (NSMutableArray *)searchLineWithText:( NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
    [self czw_searchValues:@"name,code,id as identification" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchStationInLineWithLineId:(NSNumber *)lineId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *values = [NSString makeSqlQueryString_value:^(SqlQueryStringValueMaker *m) {
        m.value(@"s.id").as(@"identification").
        value(@"s.name").as(@"name").
        value(@"s.code").as(@"code").
        value(@"s.type").as(@"type").
        value(@"ss.pm1").as(@"pm1").
        value(@"ss.pm2").as(@"pm2").
        value(@"ss.pm3").as(@"pm3").
        value(@"c.longitude1").as(@"longitude1").
        value(@"c.latitude1").as(@"latitude1").
        value(@"c.longitude2").as(@"longitude2").
        value(@"c.latitude2").as(@"latitude2").
        value(@"c.longitude3").as(@"longitude3").
        value(@"c.latitude3").as(@"latitude3").
        value(@"s.zid").as(@"zid");
    }];
    NSString *tables = [NSString makeSqlQueryString_table:^(SqlQueryStringTableMaker *make) {
        make.table(@"station").as(@"s").
        table(@"stations").as(@"ss").
        table(@"coordinate").as(@"c");
    }];
    NSString *conditions = [NSString makeSqlQueryString_condition:^(SqlQueryStringConditionMaker *make) {
        NSString *sslineId = [NSString stringWithFormat:@"%d",[lineId intValue]];
        NSLog(@"sslineId = %p",sslineId);
        make.value(@"s.id").equalTo(@"ss.stationid").also.
        value(@"ss.id").equalTo(@"c.stationsid").also.
        value(@"ss.lineid").equalTo(sslineId);
    }];
    [self czw_searchValues:values fromTable:tables where:conditions handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}


- (NSMutableArray *)searchStationWithText:(NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
#warning todo:改id名
    [self czw_searchValues:nil fromTable:@"station" where:condition groupBy:@"code" orderBy:nil limit:nil handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchStationWithPinyin:(NSString *)pinyin{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *condition = [NSString stringWithFormat:@"pinyin like '%%%@%%'",pinyin];
    [self czw_searchValues:nil fromTable:@"station" where:condition groupBy:nil orderBy:nil limit:@"10" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchLineViaStationWithZid:(NSNumber *)zid{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    if (!zid) {
        return nil;
    }
    NSString *values = [NSString makeSqlQueryString_value:^(SqlQueryStringValueMaker *make) {
        make.value(@"distinct l.id").as(@"identification").
        value(@"l.number").as(@"number").
        value(@"l.name").as(@"name").
        value(@"l.code").as(@"code").
   /*     value(@"c.name").as(@"categoryName").    */
        value(@"l.type").as(@"type").
        value(@"o.time").as(@"serviceTime").
        value(@"o.fare").as(@"fare").
        value(@"o.note").as(@"note").
        value(@"o.lastupdate").as(@"lastUpDate").
        value(@"cp.name").as(@"companyName").
        value(@"o.start").as(@"starting").
        value(@"o.end").as(@"terminal");
    }];
    NSString *tables = [NSString makeSqlQueryString_table:^(SqlQueryStringTableMaker *make) {
        make.table(@"station").as(@"s").
        table(@"stations").as(@"ss").
        table(@"lines").as(@"l").
        table(@"category").as(@"c").
        table(@"linesothers").as(@"o").
        table(@"company").as(@"cp");
    }];
    NSString *conditions = [NSString makeSqlQueryString_condition:^(SqlQueryStringConditionMaker *make) {
        NSString *szid = [NSString stringWithFormat:@"%d",[zid intValue]];
        NSLog(@"sizd = %p",szid);
        make.value(@"s.id").equalTo(@"ss.stationid").also.
        value(@"ss.lineid").equalTo(@"l.id").also.
        value(@"l.categoryid").equalTo(@"c.id").also.
        value(@"l.id").equalTo(@"o.lineid").also.
        value(@"o.companyid").equalTo(@"cp.id").also.
        value(@"s.zid").equalTo(szid);
    }];
    
    [self czw_searchValues:values fromTable:tables where:conditions groupBy:nil orderBy:@"l.number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

/**
 *  繁体转简体;
 */

- (NSString *)textToSimplified:(NSString *)text{
    convertGB_BIG *convertGbToBig = [[convertGB_BIG alloc] init];
    return [convertGbToBig big5ToGb:[text uppercaseString]];
}

@end




