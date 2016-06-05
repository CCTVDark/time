//
//  RadioDetailVC.h
//  OneProject
//
//  Created by lanouhn on 16/4/27.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"
#import "RadioListModel.h"
#import "RadioCircleModel.h"
@interface RadioDetailVC : BaseViewController
@property (nonatomic, strong)RadioListModel *model;
@property (nonatomic, strong)RadioCircleModel *circleModel;
@property (nonatomic, strong)NSString *radioid;
@end
