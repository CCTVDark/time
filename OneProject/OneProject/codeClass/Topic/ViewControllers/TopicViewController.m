//
//  TopicViewController.m
//  OneProject
//
//  Created by lanouhn on 16/4/22.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicListCell.h"
#import "TopicListCellTwo.h"
#import "TopicModel.h"
#import "TopicViewDetailVC.h"
@interface TopicViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *tableView;
@end
NSInteger isRefresh = 1;
NSInteger isPage = 0;
@implementation TopicViewController
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"viewImage.jpeg"]];
    [self.view addSubview:backImageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor yellowColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"TopicListCell" bundle:nil] forCellReuseIdentifier:@"oneCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TopicListCellTwo" bundle:nil] forCellReuseIdentifier:@"twoCell"];
    [self.view addSubview:self.tableView];
    [self setHttp];
    [self setWithCallBack];
        
}

- (void)setHttp {
    [NetworkingManager requestGETWithUrlString:kTopicListURL parDic:nil finish:^(id responseObject) {
        [self handleDataWithData:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}
//封装解析
- (void)handleDataWithData:(id)data {
    NSArray *tempArray = [[data objectForKey:@"data"] objectForKey:@"list"];
    
    if (isRefresh == 1) {
        [self.dataArray removeAllObjects];
    }
    
    for (NSDictionary *dic in tempArray) {
        TopicModel *model = [[TopicModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if (isRefresh == 1) {
            [self.tableView headerEndRefreshing];
        }else {
            [self.tableView footerEndRefreshing];
        }
        [self.tableView reloadData];
    });
    

    
    
}
                  
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    
    if (model.coverimg.length == 0) {
        return 230;
    }
    return 250;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    if (model.coverimg.length == 0) {
        TopicListCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"twoCell" forIndexPath:indexPath];
        cell.model = model;
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    TopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"oneCell" forIndexPath:indexPath];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)setWithCallBack {
    __weak TopicViewController *vc = self;
    [self.tableView addHeaderWithCallback:^{
        isRefresh = 1;
        [vc setHttp];
    }];
    [self.tableView addFooterWithCallback:^{
        isPage ++;
        isRefresh = 0;
        [NetworkingManager requestPOSTWithUrlString:kTopicListURL parDic:@{@"deviceid":@"63A94D37-33F9-40FF-9EBB-481182338873",@"client":@"1",@"sort":@"addtime",@"limit":@10,@"version":@"3.0.2",@"start":@(isPage),@"auth":@"Wc06FCrkoq1DCMVzGMTikDJxQ8bm3Mrm2NpT9qWjwzcWP23tBKQx1c4P0"} finish:^(id responseObject) {
            [vc handleDataWithData:responseObject];
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicModel *model = self.dataArray[indexPath.row];
    TopicViewDetailVC *detailVC = [[TopicViewDetailVC alloc]init];
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
