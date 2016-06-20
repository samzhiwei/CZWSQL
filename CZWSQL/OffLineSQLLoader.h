//
//  OffLineSQLLoader.h
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "CZWSqlite.h"
#define OffLineLoader [OffLineSQLLoader shareLoader]
@interface OffLineSQLLoader : CZWSqlite
+ (instancetype)shareLoader;
- (void)configureDataBasePathWithCityPinyin:(NSString *)pinyin;


#pragma mark - 查询操作
/**
 *  输出路线分类
 */
- (NSMutableArray *)searchAllLineCategory;

/**
 *  根据分类id查询属下线路
 */
- (NSMutableArray *)searchLineWithCategoryId:(NSNumber *)categoryId;

/**
 *  根据line.code搜索线路详情
 */
- (NSMutableArray *)searchLineWithLineCode:(NSString *)lineCode;

/**
 *  根据lineId搜索经过该站的线路
 */
- (NSMutableArray *)searchStationInLineWithLineId:(NSNumber *)lineId;

/**
 *  根据字符搜索线路
 */
- (NSMutableArray *)searchLineWithText:(NSString *)searchText;


/**
 *  根据字符搜索站点
 */
- (NSMutableArray *)searchStationWithText:(NSString *)searchText;
/**
 *  根据拼音搜索站点(只返前10个)
 */
- (NSMutableArray *)searchStationWithPinyin:(NSString *)pinyin;

/**
 *  根据zid搜索经过该站的线路
 */
- (NSMutableArray *)searchLineViaStationWithZid:(NSNumber *)zid;



@end


