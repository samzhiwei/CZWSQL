//
//  ViewController.m
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "ViewController.h"
#import "OffLineSQLLoader.h"
@interface ViewController () <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OffLineSQLLoader *loader = OffLineLoader;
    [loader configureDataBasePathWithCityPinyin:@"guangzhou"];
    self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
////    NSMutableArray *arr = [loader czw_searchAllLineCategory];
////    NSMutableArray *arr2 = [loader czw_searchLineWithCategoryId:[NSNumber numberWithInt:3]];
//    NSMutableArray *array = [loader czw_searchLineWithText:@"d"];
//    //NSMutableArray *array1 = [loader czw_searchStationWithText:@"海珠"];
////    NSMutableArray *ar = [loader czw_searchStationInLineWithLineId:[NSNumber numberWithInt:15]];
//  NSMutableArray  *ar2 = [loader czw_searchLineViaStationWithZid:[NSNumber numberWithInt:3587]];
    self.data = [loader czw_searchStationWithText:@"海珠"];
    for (NSDictionary *dic1 in _data) {
        NSNumber *zid = [dic1 objectForKey:@"zid"];
        NSMutableArray *list = [OffLineLoader czw_searchLineViaStationWithZid:zid];
        NSString *allLine = [[NSString alloc]init];
        for (NSDictionary *dic2 in list) {
            allLine = [allLine stringByAppendingString:[[dic2 objectForKey:@"name"] stringByAppendingString:@"/"] ];
        }
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    NSDictionary *dic = self.data[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"name"];
    cell.detailTextLabel.text = allLine;
    return cell;
}

@end
