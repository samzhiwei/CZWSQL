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
    
    [self czw_searchValues:@"id,name" fromTable:@"category" where:nil handler:^(NSMutableDictionary *mDic) {

        [resultArray addObject:mDic];
    }];
    
    return resultArray;
}

- (NSMutableArray *)searchLineWithCategoryId:(NSNumber *)categoryId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *condition = [NSString stringWithFormat:@"categoryid = %d",[categoryId intValue]];
    [self czw_searchValues:@"name ,code ,id" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

- (NSMutableArray *)searchLineWithLineCode:(NSString *)lineCode{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *values = [NSString stringWithFormat:@"l.name ,l.code ,l.number ,lo.time,lo.lastupdate,lo.start,lo.end ,c.name ,lo.note ,lo.fare"];
    NSString *tables = [NSString stringWithFormat:@"lines as l ,linesothers as lo,company as c"];
    NSString *condition = [NSString stringWithFormat:@"lo.companyid = c.id AND l.id = lo.lineid AND l.code = '%@'",lineCode];
    [self czw_searchValues:values fromTable:tables where:condition handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}


- (NSMutableArray *)searchLineWithText:( NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
    [self czw_searchValues:@"name,code,id" fromTable:@"lines" where:condition groupBy:nil orderBy:@"number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    
#warning todo:排序
    return resultArray;
}

- (NSMutableArray *)searchStationInLineWithLineId:(NSNumber *)lineId{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *str = [NSString makeSqlQueryString_value:^(SqlQueryStringMaker *m) {
        m.value(@"s.id").as(@"id").
        value(@"s.name").as(@"name").
        value(@"s.code").as(@"code").
        value(@"s.type").as(@"type").
        value(@"ss.pm1").as(@"pm1");
    }];
    NSString *values = @"s.id as id, s.name as name, s.code as code, s.type as type, ss.pm1 as pm1, ss.pm2 as pm2, ss.pm3 as pm3, c.longitude1 as longitude1, c.latitude1 as latitude1, c.longitude2 as longitude2, c.latitude2 as latitude2, c.longitude3 as longitude3, c.latitude3 as latitude3 ,s.zid as zid";
    NSString *tables = @"station as s,stations as ss,coordinate as c";
    NSString *condition = [NSString stringWithFormat:@"s.id=ss.stationid and ss.id=c.stationsid and ss.lineid=%d",[lineId intValue]];
    [self czw_searchValues:values fromTable:tables where:condition handler:^(NSMutableDictionary *mDic) {
        
        [resultArray addObject:mDic];
    }];
    
    return resultArray;
}


- (NSMutableArray *)searchStationWithText:(NSString *)searchText{
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];
    NSString *uSearchText = [self textToSimplified:searchText];
    NSString *condition = [NSString stringWithFormat:@"name like '%%%@%%'",uSearchText];
    [self czw_searchValues:nil fromTable:@"station" where:condition groupBy:@"code" orderBy:nil limit:nil handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
        
    }];
#warning todo :排序
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
    NSString *values = @"distinct l.id as identification,l.number as number,l.name as name,l.code as code,c.name as categoryName,l.type as type,o.time as serviceTime,o.fare as fare,o.note as note,o.lastupdate as lastUpDate,cp.name as companyName,o.start as starting,o.end as terminal";
    NSString *tables = @"station as s,stations as ss,lines as l,category as c,linesothers as o,company as cp";
    NSString *condition = [NSString stringWithFormat:@"s.id=ss.stationid and ss.lineid=l.id and l.categoryid=c.id and l.id=o.lineid and o.companyid=cp.id and s.zid=%d",[zid intValue]];
    
    [self czw_searchValues:values fromTable:tables where:condition groupBy:nil orderBy:@"l.number" handler:^(NSMutableDictionary *mDic) {
        [resultArray addObject:mDic];
    }];
    return resultArray;
}

@end




