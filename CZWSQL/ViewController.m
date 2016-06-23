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
//    NSMutableArray *da = [loader searchStationInLineWithLineId:@15];
    
   // NSMutableArray *arr = [loader searchLineViaStationWithZid:@59];
//NSMutableArray *arr = [loader searchLineWithLineCode:@"88200d0a"];
//    NSMutableArray *arr2 = [loader searchStationWithPinyin:@"dongxiaonan"];
//    NSLog(@"%p",arr);
    NSMutableArray *Category = [loader searchAllLineCategory];
    NSMutableArray *CategoryId = [loader searchLineWithCategoryId:@11];
    NSMutableArray *LineCode = [loader searchLineWithLineCode:@"88200d0a"];
    NSMutableArray *linetext = [loader searchLineWithText:@"2"];
    NSMutableArray *lineid = [loader searchStationInLineWithLineId:@31];
    NSMutableArray *stationtext = [loader searchStationWithText:@"公园前"];
    NSMutableArray *stationpinyin = [loader searchStationWithPinyin:@"gongyuan"];
    NSMutableArray *stationid = [loader searchLineViaStationWithZid:@17505];
    
//    self.tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.backgroundColor = [UIColor yellowColor];
//    [self.view addSubview:self.tableView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(did:) name:@"did" object:nil];
////    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
////    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
//        self.data = [loader searchStationWithText:@"海珠"];
//        for (NSMutableDictionary *dic1 in _data) {
//            NSNumber *zid = [dic1 objectForKey:@"zid"];
//            NSMutableArray *list = [OffLineLoader czw_searchLineViaStationWithZid:zid];
//            NSString *allLine = [[NSString alloc]init];
//            for (NSDictionary *dic2 in list) {
//                allLine = [allLine stringByAppendingString:[[dic2 objectForKey:@"name"] stringByAppendingString:@"/"]];
//            }
//            [dic1 setObject:allLine forKey:@"lineName"];
//        }
        
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"did" object:nil];
//    }];
//    [queue addOperation:blockOp];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"did" object:nil];
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
    cell.detailTextLabel.text = [dic objectForKey:@"lineName"];
    return cell;
}

- (void)did:(NSNotification *)noti{
    NSLog(@"当前线程:%@,当前方法:%s",[NSThread currentThread], __FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"当前线程:%@,当前方法:%s",[NSThread currentThread], __FUNCTION__);
        [self.tableView reloadData];
    });
    
}
@end
