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
- (NSArray *)czw_searchLineWithText:(NSString *)searchText;
@end
