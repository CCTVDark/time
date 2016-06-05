//
//  RadioDetailModel.m
//  OneProject
//
//  Created by lanouhn on 16/4/27.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioDetailModel.h"

@implementation RadioDetailModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"出错了%@", key);
}
@end
