//
//  UIButton+Action.m
//  LessonNavigation_07
//
//  Created by lanouhn on 16/3/2.
//  Copyright © 2016年 LiuGuoDong. All rights reserved.
//

#import "UIButton+Action.h"

@implementation UIButton (Action)
+ (UIButton *)setButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font =  [UIFont boldSystemFontOfSize:20];
    button.titleLabel.font = [UIFont systemFontOfSize:20];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //添加事件
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}



@end
