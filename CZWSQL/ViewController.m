//
//  ViewController.m
//  CZWSQL
//
//  Created by tianqu on 16/6/12.
//  Copyright © 2016年 Tianqu. All rights reserved.
//

#import "ViewController.h"
#import "OffLineSQLLoader.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OffLineSQLLoader *loader = OffLineLoader;
    [loader configureDataBasePathWithCityPinyin:@"guangzhou"];
    [loader czw_searchLineWithText:@"增城"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
