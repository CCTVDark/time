//
//  MusicModel.m
//  OneProject
//
//  Created by lanouhn on 16/5/3.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "MusicModel.h"

@implementation MusicModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"失败:%@",key);
}
@end
