//
//  PlayerManager.h
//  OneProject
//
//  Created by lanouhn on 16/5/3.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <Foundation/Foundation.h>
//
typedef void(^Block)(float);
//将播放模式设置 随机、单曲、列表
typedef NS_ENUM(NSInteger, PlayType) {
    PlayerTypeRandom,//随机
    PlayerTypeSingle,//单曲
    PlayerTypeList//列表
};
//播放状态 播放以及暂停
typedef NS_ENUM(NSInteger, PlayStatus) {
    PlayerStatusPlay,//播放
    PlayerStatusPause//暂停
};

@interface PlayerManager : NSObject
//声明一些辅助属性
//block传值
@property (nonatomic, copy)Block myBlock;

//歌曲的下标
@property (nonatomic, assign)NSInteger index;
//歌曲的数据源
@property (nonatomic, strong)NSMutableArray *musicArray;
//播放模式
@property (nonatomic, assign)PlayType playType;
//播放器状态
@property (nonatomic, assign)PlayStatus playStatus;
//播放器总时长
@property (nonatomic, assign)float totalTime;
//当前时长
@property (nonatomic, assign)float currentTime;
//播放器
@property (nonatomic, strong)AVPlayer *avPlayer;
//定时器
@property (nonatomic, strong)NSTimer *myTimer;


//开始声明方法
//单例方法
+ (PlayerManager *)sharedPlayerManager;
//停止
- (void)stop;//用于手动点击下一曲时，将正在播放的歌曲信息清除
//播放
- (void)play;
//暂停
- (void)pause;
//上一首
- (void)lastMusic;
//下一首
- (void)nextMusic;
//指定下标的位置进行播放（选取数组中某个对象进行播放）
- (void)changeMusicWithIndex:(NSInteger)index;
//指定位置进行播放（进度条更改后进行播放）
- (void)seekTime:(float)time;
//播放完成后的操作
- (void)playDidFinish;
- (void)setMusicArray:(NSMutableArray *)musicArray index:(NSInteger)index;

@end
