//
//  GoodProductViewController.m
//  OneProject
//
//  Created by lanouhn on 16/4/22.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "GoodProductViewController.h"
#import "GoodDetailVC.h"
@interface GoodProductViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@end
NSInteger isPageP = 0;
NSInteger isDownN = 1;
@implementation GoodProductViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"GoodListCell" bundle:nil] forCellReuseIdentifier:@"goodCell"];
    [self requestHttp];
    __weak GoodProductViewController *weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        isPageP = 0;
        isDownN = 1;
        [weakSelf requestHttp];
    }];
    [self.tableView addFooterWithCallback:^{
        isPageP += 10;
        isDownN = 0;
        [weakSelf requestHttp];
    }];
}
//封装请求数据
- (void)requestHttp {
    [NetworkingManager requestPOSTWithUrlString:KGoodProdductURL parDic:@{@"deviceid":@"63A94D37-33F9-40FF-9EBB-481182338873",@"client":@"1",@"sort":@"addtime",@"limit":@10,@"version":@"3.0.2",@"start":@(isPageP),@"auth":@"Wc06FCrkoq1DCMVzGMTikDJxQ8bm3Mrm2NpT9qWjwzcWP23tBKQx1c4P0"} finish:^(id responseObject) {
        [self handleDataWithData:responseObject];
    } error:^(NSError *error) {
        
    }];
}
//封装解析数据
- (void)handleDataWithData:(id)data {
    
    NSArray *tempArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    if (isDownN == 1) {
         [self.dataArray removeAllObjects];
         [self.tableView headerEndRefreshing];
    }else {
         [self.tableView footerEndRefreshing];
    }
    for (NSDictionary *tempDic in tempArray) {
        GoodListModel *model = [[GoodListModel alloc]init];
        [model setValuesForKeysWithDictionary:tempDic];
        [self.dataArray addObject:model];
     
    }
    
   
   
    
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 303;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodCell" forIndexPath:indexPath];
    GoodListModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodListModel *model = self.dataArray[indexPath.row];
    GoodDetailVC *detailVC = [[GoodDetailVC alloc]init];
    detailVC.model = model;
    [self.navigationController pushViewController:detailVC animated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
