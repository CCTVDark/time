//
//  RadioDetailVC.m
//  OneProject
//
//  Created by lanouhn on 16/4/27.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioDetailVC.h"

#import "RadioDetailCell.h"
#import "RadioPlayerController.h"
#import "MusicModel.h"
@interface RadioDetailVC ()<UITableViewDataSource,UITableViewDelegate>
//表视图
@property (nonatomic, strong)UITableView *tableView;
//表视图的头部视图
@property (nonatomic, strong)UIImageView *imageView;
//数据源
@property (nonatomic, strong)NSMutableArray *dataArray;
@end
NSInteger isRadioDetailDown = 1;
NSInteger isRadioDetailPage = 0;
@implementation RadioDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //返回上一界面
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleBackView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItems = @[item];
    
    
    
    //背景图片
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    
    self.dataArray = [NSMutableArray array];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioDetailCell" bundle:nil] forCellReuseIdentifier:@"radioDetailCell"];
    [self.view addSubview:self.tableView];
    [self setHeaderView];
    if (self.circleModel) {
        [self requestCircleHttpWithModel:self.circleModel url:kRadioDetailURL];

    }else{
        [self requestHttp:kRadioDetailURL];
    }
   
    __weak RadioDetailVC *weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        isRadioDetailDown = 1;
        isRadioDetailPage = 0;
        if (weakSelf.circleModel) {
            [weakSelf requestCircleHttpWithModel:weakSelf.circleModel url:kRadioDetailURL];
        }else {
            [weakSelf requestHttp:kRadioDetailURL];
        }
        
    }];
    [self.tableView addFooterWithCallback:^{
        isRadioDetailDown = 0;
        isRadioDetailPage += 10;
        if (weakSelf.circleModel) {
            [weakSelf requestCircleHttpWithModel:weakSelf.circleModel url:kRadioDetailLoadURL];
        }else {
            [weakSelf requestHttp:kRadioDetailLoadURL];
        }
    }];
}
//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


//封装头部视图
- (void)setHeaderView {
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    self.imageView.userInteractionEnabled = YES;
    self.tableView.tableHeaderView = self.imageView;
}


//请求数据
- (void)requestHttp:(NSString *)url {
    NSString *page = [NSString stringWithFormat:@"%ld", isRadioDetailPage];
    [NetworkingManager requestPOSTWithUrlString:url parDic:@{@"radioid":self.model.radioid, @"start": page} finish:^(id responseObject) {
        [self handleData:responseObject];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
//轮播图请求数据
- (void)requestCircleHttpWithModel:(RadioCircleModel *)model url:(NSString *)url {
    NSString *page = [NSString stringWithFormat:@"%ld", isRadioDetailPage];
    [NetworkingManager requestPOSTWithUrlString:url parDic:@{@"radioid":self.radioid, @"start": page} finish:^(id responseObject) {
        [self handleData:responseObject];
        
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//解析数据
- (void)handleData:(id)responseObject {
    if (isRadioDetailDown == 1) {
        [self.dataArray removeAllObjects];
        [self.tableView headerEndRefreshing];
        //头部大图
        NSString *coverimg = [[[responseObject objectForKey:@"data"] objectForKey:@"radioInfo"] objectForKey:@"coverimg"];
        [self.imageView setImageWithURL:[NSURL URLWithString:coverimg]];
    }else {
        [self.tableView footerEndRefreshing];
    }
    
    
    //表CELL
    NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
    for (NSDictionary *dic in tempArray) {
        RadioDetailModel *model = [[RadioDetailModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
   //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioDetailCell" forIndexPath:indexPath];
    RadioDetailModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:252 / 255.0 green:229 / 255.0 blue:212 / 255.0 alpha:1];
    }else {
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioDetailModel *model = self.dataArray[indexPath.row];
    RadioPlayerController *playController = [[RadioPlayerController alloc]init];
    playController.tempModel = model;
    
    playController.musicArray = [self.dataArray mutableCopy];
    playController.index = indexPath.row;
    
    [self.navigationController pushViewController:playController animated:YES];
    
}
@end
