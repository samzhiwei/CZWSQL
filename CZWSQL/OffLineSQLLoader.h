//
//  OffLineSQLLoader.h
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define OffLineLoader [OffLineSQLLoader shareLoader]


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



@interface OffLineSQLLoader : NSObject
+ (instancetype)shareLoader;
- (void)configureDataBasePathWithCityPinyin:(NSString *)pinyin;


#pragma mark - 查询操作
/**
 *  输出路线分类
 */
- (NSMutableArray *)czw_searchAllLineCategory;

/**
 *  根据分类id查询属下线路
 */
- (NSMutableArray *)czw_searchLineWithCategoryId:(NSNumber *)categoryId;

/**
 *  根据line.code搜索线路详情
 */
- (NSMutableArray *)czw_searchLineWithLineCode:(NSString *)lineCode;

/**
 *  根据lineId搜索经过该站的线路
 */
- (NSMutableArray *)czw_searchStationInLineWithLineId:(NSNumber *)lineId;

/**
 *  根据字符搜索线路
 */
- (NSMutableArray *)czw_searchLineWithText:(NSString *)searchText;


/**
 *  根据字符搜索站点
 */
- (NSMutableArray *)czw_searchStationWithText:(NSString *)searchText;
/**
 *  根据拼音搜索站点(只返前10个)
 */
- (NSMutableArray *)czw_searchStationWithPinyin:(NSString *)pinyin;

/**
 *  根据zid搜索经过该站的线路
 */
- (NSMutableArray *)czw_searchLineViaStationWithZid:(NSNumber *)zid;



@end


