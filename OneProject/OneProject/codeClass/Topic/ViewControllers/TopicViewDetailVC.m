//
//  TopicViewDetailVC.m
//  OneProject
//
//  Created by lanouhn on 16/4/26.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "TopicViewDetailVC.h"
#import "TopicDetailCell.h"
@interface TopicViewDetailVC ()<UIWebViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)UIWebView *myWebView;
@property (nonatomic, strong)UITableView *tableView;
//tableView数据源
@property (nonatomic, strong)NSMutableArray *dataArray;
@end
NSInteger isTopicDetailDown = 1;
NSInteger isTopicDetailPage = 0;
@implementation TopicViewDetailVC




- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"viewImage.jpeg"]];
    [self.view addSubview:backImageView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.dataArray = [NSMutableArray array];
    [self setTableviewON];
    [self requestData];
    [self requestCommentData];
}
//webView加载完成会走的方法
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *str=[NSString stringWithFormat:@"var script = document.createElement('script');"
                   "script.type = 'text/javascript';"
                   "script.text = \"function ResizeImages() { "
                   "var myimg,oldwidth;"
                   "var maxwidth =%f;"// UIWebView中显示的图片宽度
                   "for(i=0;i <document.images.length;i++){"
                   "myimg = document.images[i];"
                   "if(myimg.width > maxwidth){"
                   "oldwidth = myimg.width;"
                   "myimg.width = maxwidth;"
                   "}"
                   "}"
                   "}\";"
                   "document.getElementsByTagName('head')[0].appendChild(script);",self.view.frame.size.width-15];
    [webView stringByEvaluatingJavaScriptFromString:str];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}
//封装加载tableView的方法
- (void)setTableviewON {
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, kDeviceWidth, kDeviceHeight - 64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.myWebView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    self.myWebView.delegate = self;
    [self.myWebView sizeToFit];
    self.tableView.tableHeaderView = self.myWebView;
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"TopicDetailCell" bundle:nil] forCellReuseIdentifier:@"TopicDetailCella"];
    self.tableView.rowHeight = 100;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    __weak TopicViewDetailVC *weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        isTopicDetailDown = 1;
        isTopicDetailPage = 0;
        [weakSelf requestCommentData];
    }];
    [self.tableView addFooterWithCallback:^{
        isTopicDetailDown = 0;
        isTopicDetailPage += 10;
        [weakSelf requestCommentData];
    }];
    
}
- (void)requestData {
    [NetworkingManager requestPOSTWithUrlString:kReadInfURL parDic:@{@"contentid":self.model.contentid} finish:^(id responseObject) {
         [self.myWebView loadHTMLString:[[responseObject objectForKey:@"data"] objectForKey:@"html"] baseURL:nil];
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}
- (void)requestCommentData {
    [NetworkingManager requestPOSTWithUrlString:KConmentListUrl parDic:@{@"contentid":self.model.contentid, @"start":@(isTopicDetailPage)} finish:^(id responseObject) {
        [self handleData:responseObject];
        
    } error:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

//解析数据
- (void)handleData:(id)responseObject {
    if (isTopicDetailDown == 1) {
        [self.dataArray removeAllObjects];
       
        [self.tableView headerEndRefreshing];
    }else {
        [self.tableView footerEndRefreshing];
    }
    NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"list"];
    for (NSDictionary *dic in tempArray) {
        TopicDetailModel *model = [[TopicDetailModel alloc]init];
        [model setValuesForKeysWithDictionary:dic];
        [self.dataArray addObject:model];

    }
    
   [self.tableView reloadData];
        
   

}


//配置cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TopicDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicDetailCella" forIndexPath:indexPath];
    TopicDetailModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
