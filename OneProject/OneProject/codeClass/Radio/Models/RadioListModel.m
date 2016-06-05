//
//  RadioListModel.m
//  OneProject
//
//  Created by lanouhn on 16/4/25.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "RadioListModel.h"

@implementation RadioListModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"userinfo"]) {
        self.uname = value[@"uname"];
    }
    }



@end
