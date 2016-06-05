//
//  ReadDetailVC.h
//  OneProject
//
//  Created by lanouhn on 16/4/26.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import "BaseViewController.h"
#import "ReadListModel.h"//cell上的model
#import "ReadCircleModel.h"
@interface ReadDetailVC : BaseViewController
//用于传值
@property (nonatomic, strong) ReadListModel *tempModel;


@end
