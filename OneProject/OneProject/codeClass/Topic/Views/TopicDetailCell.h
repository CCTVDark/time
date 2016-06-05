//
//  TopicDetailCell.h
//  OneProject
//
//  Created by lanouhn on 16/4/28.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicDetailModel.h"
@interface TopicDetailCell : UITableViewCell
@property (strong, nonatomic)TopicDetailModel *model;
@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *contectLabel;

@end
