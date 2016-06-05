//
//  RadioPlayerController.m
//  OneProject
//
//  Created by lanouhn on 16/5/3.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioPlayerController.h"
#import "PlayerManager.h"
#import "DownLoadManager.h"
#import "RadioPlayListCell.h"
@interface RadioPlayerController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong)PlayerManager *manager;
@property (nonatomic, strong)UILabel *currentLabel;
@property (nonatomic, strong)UILabel *totalLabel;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIView *MusicListView;
@property (nonatomic, assign)NSInteger isList;
@end
NSInteger isRadioPPDown = 0;
@implementation RadioPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isList = 0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //返回上一界面
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 32, 32);
    [button setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleBackView:) forControlEvents:UIControlEventTouchUpInside];
    //button.imageEdgeInsets = UIEdgeInsetsMake(0, -18, 0, 18);
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItems = @[item];
    
    
    //下载
//    UIButton *downButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    downButton.frame = CGRectMake(0, 0, 32, 32);
//    [downButton  setImage:[UIImage imageNamed:@"downLoad.png"] forState:UIControlStateNormal];
//    //downButton.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -30);
//    [downButton addTarget:self action:@selector(handleDownView:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *downLoaditem = [[UIBarButtonItem alloc]initWithCustomView:downButton];
    
    //列表
    UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
    listButton.frame = CGRectMake(0, 0, 32, 32);
    [listButton  setImage:[UIImage imageNamed:@"listThree.png"] forState:UIControlStateNormal];
    listButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [listButton addTarget:self action:@selector(handleListView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *listitem = [[UIBarButtonItem alloc]initWithCustomView:listButton];
    
    self.navigationItem.rightBarButtonItems = @[listitem];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.manager = [PlayerManager sharedPlayerManager];
    
    //记录当前播放时长
    [self setupUI];
    //判断：如果是回到上一个播放界面，就回到之前的播放时长
    [self.manager setMusicArray:self.musicArray index:self.index];
    [self.manager play];
    
    
    //封装后台播放
    [self RequiredBackground];
    
}


//封装界面
- (void)setupUI {
   
    //背景图片
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    [backImageView setImage:[UIImage imageNamed:@"timg.jpg"]];
    [self.view addSubview:backImageView];
    
    //播放界面
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
    //歌名
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 100, 100, 200, 40)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = self.tempModel.title;
    titleLabel.tag = 300;
    [view addSubview:titleLabel];
    //歌手名
    UILabel *singerLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 100, 140, 200, 40)];
    singerLabel.textAlignment = NSTextAlignmentCenter;
    NSDictionary *tempDic = self.tempModel.playInfo[@"authorinfo"];
    singerLabel.text = tempDic[@"uname"];
    singerLabel.tag = 301;
    [view addSubview:singerLabel];
    
    //背景图
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 90, 200, 180, 180)];
    RadioDetailModel *tempModel = self.musicArray[self.index];
    [imageView setImageWithURL:[NSURL URLWithString:tempModel.coverimg]];
    imageView.layer.cornerRadius = 90;
    imageView.layer.masksToBounds = YES;
    imageView.tag = 555;
    [self handleBasicAnimation:imageView];
    
    [view addSubview:imageView];
    
    //进度条
    UISlider *slider = [[UISlider alloc]initWithFrame:CGRectMake(20, 400, kDeviceWidth - 40, 50)];
    [view addSubview:slider];
    [slider addTarget:self action:@selector(handleSliderAction:) forControlEvents:UIControlEventValueChanged];
    //block回调给进度条赋值
    __weak RadioPlayerController *weakSelf = self;
    self.manager.myBlock = ^void(float value) {
        slider.value = value;
        if (value == 1) {
            [weakSelf.manager nextMusic];
        }
        NSInteger a = (NSInteger)weakSelf.manager.currentTime % 60;
        NSInteger b = (NSInteger)weakSelf.manager.currentTime / 60;
        weakSelf.currentLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", b, a];
        NSInteger c = (NSInteger)weakSelf.manager.totalTime % 60;
        NSInteger d = (NSInteger)weakSelf.manager.totalTime / 60;
        weakSelf.totalLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", d, c];
        
    };
    //播放与暂停
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.frame = CGRectMake(kDeviceWidth / 2 - 30, kDeviceHeight - 80, 64, 64);
    [playButton addTarget:self action:@selector(handlePlay:) forControlEvents:UIControlEventTouchUpInside];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    playButton.tag  =  666;
    //上一首
    UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lastButton.frame = CGRectMake(kDeviceWidth / 4 - 64, kDeviceHeight - 80, 64, 64);
    [lastButton setImage:[UIImage imageNamed:@"last.png"] forState:UIControlStateNormal];
    [lastButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    lastButton.tag = 667;
    [lastButton addTarget:self action:@selector(handleLast:) forControlEvents:UIControlEventTouchUpInside];
    //下一首
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(kDeviceWidth / 4 * 3, kDeviceHeight - 80, 64, 64);
    [nextButton setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    nextButton.tag = 668;
    [nextButton addTarget:self action:@selector(handleNext:) forControlEvents:UIControlEventTouchUpInside];
    
    //当前播放时长
    self.currentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(slider.frame), 50, 30)];
    
    [view addSubview:self.currentLabel];
    //总播放时长
    self.totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth - 20 - 30, CGRectGetMaxY(slider.frame), 50, 30)];
    
    [view addSubview:self.totalLabel];
    //加进view
    [view addSubview:playButton];
    [view addSubview:lastButton];
    [view addSubview:nextButton];
    [self.view addSubview:view];
    [self setMusicListView];
}

- (void)handleSliderAction:(UISlider *)sender {
    
    [self.manager seekTime:[PlayerManager sharedPlayerManager].totalTime * sender.value];
    [self.manager play];
}



//动画
- (void)handleBasicAnimation:(UIImageView *)sender {
    //开始动画(图片360度旋转)
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.0 ];
        rotationAnimation.duration = 5.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = CGFLOAT_MAX;
        [sender.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}





- (void)handlePlay:(UIButton *)sender {
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:555];
    if (self.manager.playStatus == PlayerStatusPause) {
        [self.manager play];
        [sender setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [self handleBasicAnimation:imageView];
    }else{
        [self.manager pause];
        [sender setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [imageView.layer removeAnimationForKey:@"rotationAnimation"];
    }
}
- (void)handleLast:(UIButton *)sender {
    [self.manager lastMusic];
    [self setbackground];
    
}
- (void)handleNext:(UIButton *)sender {
    [self.manager nextMusic];
    [self setbackground];
    
}
#pragma mark -- 封装改动背景图、title、singer方法

- (void)setbackground {
    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
    [playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:555];
    RadioDetailModel *tempModel = self.musicArray[self.manager.index];
    UILabel *titleLabel = (UILabel *)[self.view viewWithTag:300];
    titleLabel.text = tempModel.title;
    UILabel *singerLabel = (UILabel *)[self.view viewWithTag:301];
    NSDictionary *tempDic = tempModel.playInfo[@"authorinfo"];
    singerLabel.text = tempDic[@"uname"];
    [imageView setImageWithURL:[NSURL URLWithString:tempModel.coverimg]];
    [self handleBasicAnimation:imageView];

}



//返回上一界面
- (void)handleBackView:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    }
#pragma mark -- 下载
//- (void)handleDownView:(UIButton *)sender {
//    
//    RadioDetailModel *tempModel = self.musicArray[self.manager.index];
//   
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(kDeviceWidth / 2 - 40, kDeviceHeight / 2 - 20, 80, 40)];
//    label.layer.cornerRadius = 5;
//    label.layer.masksToBounds = YES;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"开始下载";
//    for (RadioDetailModel *model in [DownLoadManager sharedDownLoadManager].dataArray) {
//        //遍历，查看传进来的model是否已经在下载的任务中
//        if ([model.tingid isEqualToString:tempModel.tingid]) {
//            label.text = @"已经下载";
//        }
//        
//    }
//    label.backgroundColor = [UIColor whiteColor];
//    label.textColor = [UIColor blackColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:label];
//    [UIView animateWithDuration:0.8 animations:^{
//        label.alpha = 0;
//    } completion:^(BOOL finished) {
//        [label removeFromSuperview];
//    }];
//     [[DownLoadManager sharedDownLoadManager] downLoadWithModel:tempModel];
//}




//列表
- (void)handleListView:(UIButton *)sender {
    
    if (self.isList == 0) {
        [UIView animateWithDuration:0.2 animations:^{
//       self.MusicListView.frame = CGRectMake(2, kDeviceHeight - 256, kDeviceWidth - 4, 256);
            self.MusicListView.transform = CGAffineTransformMakeTranslation(0, -280);

        }];
        self.isList = 1;
    }else {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.MusicListView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
       self.isList = 0;
    }
    
    
}
//封装列表视图
- (void)setMusicListView {
    self.MusicListView = [[UIView alloc]initWithFrame:CGRectMake(2, kDeviceHeight, kDeviceWidth - 4, 280)];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth - 4, 280) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithRed:234 / 255.0 green:226 / 255.0 blue:246 / 255.0 alpha:1];
    [self.MusicListView addSubview:self.tableView];
    self.MusicListView.layer.cornerRadius = 3;
    self.MusicListView.layer.masksToBounds = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 40;
    [self.tableView registerNib:[UINib nibWithNibName:@"RadioPlayListCell" bundle:nil] forCellReuseIdentifier:@"radioPlayListCell"];
    [self.view addSubview:self.MusicListView];
    
}

#pragma mark -- 列表视图tableView设置
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RadioPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"radioPlayListCell" forIndexPath:indexPath];
    RadioDetailModel *tempModel = self.musicArray[indexPath.row];
    cell.titleLabel.text = tempModel.title;
    NSDictionary *tempDic = tempModel.playInfo[@"authorinfo"];
    cell.singerLabel.text = tempDic[@"uname"];
    cell.backgroundColor = [UIColor colorWithRed:234 / 255.0 green:226 / 255.0 blue:246 / 255.0 alpha:1];
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.model = tempModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.index = indexPath.row;
    [self.manager setMusicArray:self.musicArray index:self.index];
    [self.manager play];
    [self setbackground];
}
//点击视图收回musicListView
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:0.2 animations:^{
        self.MusicListView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    self.isList = 0;
}


#pragma mark -- 后台播放
- (void)RequiredBackground {
    AppDelegate *myApp = [UIApplication sharedApplication].delegate;
    UIButton *playButton = (UIButton *)[self.view viewWithTag:666];
    UIButton *lastButton = (UIButton *)[self.view viewWithTag:667];
    UIButton *nextButton = (UIButton *)[self.view viewWithTag:668];
    [myApp setBlock:^(UIEvent *event) {
        //如果接收到远程事件，判断后，对应调用方法
        if (event.type == UIEventTypeRemoteControl) {
            //判断事件的类型
            switch (event.subtype) {
                case UIEventSubtypeRemoteControlNextTrack:
                    //下一首
                    [self handleNext:nextButton];
                    break;
                case UIEventSubtypeRemoteControlPreviousTrack:
                    //上一首
                    [self handleLast:lastButton];
                    break;
                case UIEventSubtypeRemoteControlPause:
                    //暂停或者开始
                    [self handlePlay:playButton];
                    break;
                case UIEventSubtypeRemoteControlPlay:
                    //暂停或者开始
                    [self handlePlay:playButton];
                    break;
                    //耳机暂停或者开始
                case UIEventSubtypeRemoteControlTogglePlayPause:
                    [self handlePlay:playButton];
                default:
                    break;
                    
            }
        }
    }];
}


- (void)dealloc {
//    [self.manager.myTimer invalidate];
//    self.manager.myTimer = nil;
}
- (void)viewDidDisappear:(BOOL)animated {
    
//    self.manager.backCurrentTime = self.manager.currentTime;
//    [self.manager stop];
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
