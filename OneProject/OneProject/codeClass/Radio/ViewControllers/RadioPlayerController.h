//
//  RadioPlayerController.h
//  OneProject
//
//  Created by lanouhn on 16/5/3.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioDetailModel.h"
@interface RadioPlayerController : UIViewController
@property (nonatomic, strong)RadioDetailModel *tempModel;
@property (nonatomic, strong)NSMutableArray *musicArray;
@property (nonatomic, assign)NSInteger index;
@end
