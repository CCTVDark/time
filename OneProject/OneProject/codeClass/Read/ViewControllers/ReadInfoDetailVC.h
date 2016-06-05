//
//  ReadInfoDetailVC.h
//  OneProject
//
//  Created by lanouhn on 16/4/26.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"
#import "ReadDetailModel.h"
#import "ReadCircleModel.h"
@interface ReadInfoDetailVC : BaseViewController
@property (nonatomic, strong) ReadDetailModel *tempModel;
@property (nonatomic, strong) ReadCircleModel *circleModel;
@property (nonatomic, strong) NSString *typeID;
@end
