//
//  GroupViewCell.h
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@end
