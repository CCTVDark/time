//
//  RadioViewController.m
//  OneProject
//
//  Created by lanouhn on 16/4/22.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioViewController.h"
#import "RadioListModel.h"
#import "RadioCircleModel.h"
#import "RadioListCell.h"
#import "RadioDetailVC.h"
@interface RadioViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)NSMutableArray *imageArray;
@property (nonatomic, strong)CircleView *cricleView;
@end
NSInteger isRadioDown = 1;
NSInteger isRadioPage = 9;
@implementation RadioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];

    
    self.dataArray = [NSMutableArray array];
    self.imageArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor grayColor];
    [self setupView];
    [self setupHttp];
    __weak RadioViewController *weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        isRadioDown = 1;
        isRadioPage = 9;
        [weakSelf setupHttp];
    }];
   
    [self.tableView addFooterWithCallback:^{
        isRadioDown = 0;
        isRadioPage += 10;
        [weakSelf setupHttp];
    }];
}

- (void)handleBackView:(UIButton *)sender {
    
}



//封装请求数据方法
- (void)setupHttp {
    if (isRadioDown == 1) {
        
        [NetworkingManager requestPOSTWithUrlString:kRadioListURL parDic:nil finish:^(id responseObject) {
            [self handleDataInHttp:responseObject];
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }else {
        
        [NetworkingManager requestPOSTWithUrlString:kRadioListNEXT parDic:@{@"start":@(isRadioPage)} finish:^(id responseObject) {
            [self handleDataHttpNext:responseObject];
           
        } error:^(NSError *error) {
            NSLog(@"%@", error);
        }];
    }
    
   
}
//封装数据请求
- (void)handleDataInHttp:(id)responseObject {
    if (isRadioDown == 1) {
        [self.dataArray removeAllObjects];
        [self.imageArray removeAllObjects];
    }
    
    NSDictionary *dic = responseObject;
    NSDictionary *dataDic = dic[@"data"];
    NSArray *listArray = dataDic[@"alllist"];
    NSArray *carouselArray = dataDic[@"carousel"];
    for (NSDictionary *dic in listArray) {
        RadioListModel *model = [[RadioListModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    for (NSDictionary *dic in carouselArray) {
        RadioCircleModel *model = [[RadioCircleModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.imageArray addObject:model];
    }
    [self tableViewSetHeaderView:self.tableView];
    [self.tableView headerEndRefreshing];

    
    [self.tableView reloadData];
}

//封装上拉加载解析
- (void)handleDataHttpNext:(id)responseObject {
    NSDictionary *dic = responseObject;
    NSDictionary *dataDic = dic[@"data"];
    NSArray *listArray = dataDic[@"list"];
    for (NSDictionary *dic in listArray) {
        RadioListModel *model = [[RadioListModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];
    }

    [self.tableView footerEndRefreshing];
    
    [self.tableView reloadData];
}


//封装界面
- (void)setupView {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioListCell" bundle:nil] forCellReuseIdentifier:@"radioCell"];
    [self.view addSubview:self.tableView];
    
}
//封装头部视图
- (void)tableViewSetHeaderView:(UITableView *)tableView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    NSMutableArray *imageArray = [NSMutableArray array];
    for (RadioCircleModel *model in self.imageArray) {
        NSString *url = model.img;
        [imageArray addObject:url];
    }
    self.cricleView = [[CircleView alloc]initWithImageURLArray:imageArray changeTime:2.0 withFrame:CGRectMake(0, 0, kDeviceWidth, 200)];
    __weak RadioViewController *weakSelf = self;
    [self.cricleView setTapActionBlock:^(NSInteger page) {
        RadioDetailVC *detailVC = [[RadioDetailVC alloc]init];
        RadioCircleModel *model = weakSelf.imageArray[page];
        detailVC.circleModel = model;
        NSArray *radioid = [model.url componentsSeparatedByString:@"/"];
        detailVC.radioid = [radioid lastObject];
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    }];
    [view addSubview:self.cricleView];
    tableView.tableHeaderView = view;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioCell" forIndexPath:indexPath];
    RadioListModel *model = self.dataArray[indexPath.row];
    [cell.coverimg setImageWithURL:[NSURL URLWithString:model.coverimg]];
    cell.titleLabel.text = model.title;
    cell.unameLabel.text = model.uname;
    cell.descLabel.text = model.desc;
    
    CGFloat b = [model.count floatValue];
    if (b > 999) {
        CGFloat c = b / 1000;
        cell.countLabel.text = [NSString stringWithFormat:@"%.2lfk", c];
    }else {
        cell.countLabel.text = [NSString stringWithFormat:@"%@", model.count];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioListModel *model = self.dataArray[indexPath.row];
    RadioDetailVC *detailVC = [[RadioDetailVC alloc]init];
    detailVC.model = model;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}



@end
