//
//  OffLineSQLLoader.h
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define OffLineLoader [OffLineSQLLoader shareLoader]
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
- (NSMutableArray *)czw_searchLineWithCategoryId:( NSNumber * )categoryId;


/**
 *  根据字符搜索线路
 */
- (NSMutableArray *)czw_searchLineWithText:(NSString *)searchText;
/**
 *  根据字符搜索站点
 */
- (NSMutableArray *)czw_searchStationWithText:(NSString *)searchText;
@end
