//
//  PlayerManager.m
//  OneProject
//
//  Created by lanouhn on 16/5/3.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "PlayerManager.h"
#import "MusicModel.h"
#import "RadioDetailModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
@implementation PlayerManager
//实现单例
+ (PlayerManager *)sharedPlayerManager {
    static PlayerManager *manager = nil;
    //GCD
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[PlayerManager alloc]init];
        manager.avPlayer = [[AVPlayer alloc]init];
   
    });
    return manager;
}
//重写单例对象的初始化方法（单例对象只会创建一次，所以初始化方法也只走一次）
- (instancetype)init {
    self = [super init];
    if (self) {
        //创建播放器对象
        //默认配置
        self.playType = PlayerTypeList;
        //播放状态
        self.playStatus = PlayerStatusPause;
    }
    return self;
}




#pragma mark -- 数据源（重写赋值方法）
- (void)setMusicArray:(NSMutableArray *)musicArray index:(NSInteger)index{
    //先清空之前的数据
    [_musicArray removeAllObjects];
    //把最新传进来的数据
    _musicArray = [musicArray mutableCopy];
    
    
    //判断，如果当前播放的是上一次播放的，就直接return
    if (index == self.index && self.currentTime != 0) {
        return;
    }
    self.index = index;
    //根据对应下标来获取对应的url
    MusicModel *tempModel = [[MusicModel alloc]init];
    tempModel.musicUrl = [[_musicArray objectAtIndex:self.index] musicUrl];
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:tempModel.musicUrl]];
    //将item信息给播放器对象，为了保证其唯一性，判断对象是否存在，如果存在，直接使用
    if (_avPlayer) {
        //存在
        [self.avPlayer replaceCurrentItemWithPlayerItem:item];//相当于更换了播放数据
    }
}
#pragma mark -- 播放总时长(getter)
- (float)totalTime {
    //通过avPlayer 能获取当前的播放比例
    //安全判断 比例不能为0
    if (self.avPlayer.currentItem.duration.timescale == 0) {
        return 0;
    }
    return _avPlayer.currentItem.duration.value / self.avPlayer.currentItem.duration.timescale;
}
//当前时长
- (float)currentTime {
    if (self.avPlayer.currentTime.timescale == 0) {
        return 0;
    }
    return _avPlayer.currentTime.value / _avPlayer.currentTime.timescale;
}

//停止
- (void)stop {
    [self pause];//暂停
    [self seekTime:0];//进度清0
    
}

//播放
- (void)play {
    [self.avPlayer play];
    //改变状态
    self.playStatus = PlayerStatusPlay;
    //顺便配置后台播放时的信息，比如歌手名、歌曲名、背影图、专辑名等信息（封装）
    [self configLockScreen];
    //添加定时器
    if (self.myTimer) {
        return;
    }
   self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
}

#pragma mark -- 定时器方法

- (void)timeAction {
    float value = self.currentTime / self.totalTime;
    self.myBlock(value);
    
}



#pragma mark -- 配置后台播放的信息
- (void)configLockScreen {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
    //这个字典中收进来的都是后台播放界面的配置信息
    //需要引入MPMedial框架
    //专辑名
    RadioDetailModel *model = self.musicArray[self.index];
    //[dic setObject:model.title forKey:MPMediaItemPropertyAlbumTitle];
    //歌曲名
    NSDictionary *tempDic = model.playInfo[@"authorinfo"];
    [dic setObject:model.title forKey:MPMediaItemPropertyTitle];
    //歌手名
    [dic setObject:tempDic[@"uname"] forKey:MPMediaItemPropertyArtist];
    //封面图片（一般图片都是接口链接，所以需要请求数据）
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.coverimg]];
    UIImage *image = [UIImage imageWithData:data];
    MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc]initWithImage:image];
    [dic setObject:artWork forKey:MPMediaItemPropertyArtwork];
    
    
    //播放时长
    [dic setObject:[NSNumber numberWithDouble:CMTimeGetSeconds(self.avPlayer.currentItem.duration)] forKey:MPMediaItemPropertyPlaybackDuration];
    //当前播放的信息中心
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = dic;//赋值操作 给后台配置
}

//暂停
- (void)pause {
    [self.avPlayer pause];
    self.playStatus = PlayerStatusPause;
}
//上一首
- (void)lastMusic {
    if (self.playType == PlayerTypeRandom) {
        //随机模式
        self.index = arc4random() % self.musicArray.count;
    }else if(self.playType == PlayerTypeSingle) {
        
    }
    else{
        if (self.index == 0) {
            self.index = self.musicArray.count - 1;
        }else {
            self.index--;
        }
        
    }
    [self changeMusicWithIndex:self.index];
}
//指定下标播放
- (void)changeMusicWithIndex:(NSInteger)index {
    //进行传值
    self.index = index;
    MusicModel *model = self.musicArray[index];
    //更换item的数据
    AVPlayerItem *item = [[AVPlayerItem alloc]initWithURL:[NSURL URLWithString:model.musicUrl]];
    [_avPlayer replaceCurrentItemWithPlayerItem:item];
    //进行播放
    [self play];
    
}
//下一首
- (void)nextMusic {
    if (self.playType == PlayerTypeRandom) {
        self.index = arc4random() % self.musicArray.count;
    }else if(self.playType == PlayerTypeSingle) {
        
    }
    else {
        self.index++;
        if (self.index == self.musicArray.count) {
            self.index = 0;
        }
    }
    [self changeMusicWithIndex:self.index];
}
//播放进度
- (void)seekTime:(float)time {
    //获取当前时间
    CMTime newTime = self.avPlayer.currentTime;
    //重新设置时间
    newTime.value = newTime.timescale * time;
    //给播放器跳转到   新的时间
    [self.avPlayer seekToTime:newTime];
}
//播放完成后的操作
- (void)playDidFinish {
    //此首完成 继续下一首
    [self nextMusic];
}
@end
