//
//  ReadListCell.h
//  OneProject
//
//  Created by lanouhn on 16/4/25.
//  Copyright © 2016年 LiuGouDong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadListCell : UICollectionViewCell
//图片
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
//标题
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
