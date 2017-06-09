//
//  GroupViewCell.m
//  Campus Life
//
//  Created by 纪宇伟 on 14/12/4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import "GroupViewCell.h"

@implementation GroupViewCell

- (void)awakeFromNib {
    // Initialization code
    CALayer * layer = [_posterImgView layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 1.5f;
    
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    _shadowView.layer.shadowOffset = CGSizeMake(1, 1);
    _shadowView.layer.shadowOpacity = 0.5;
    _shadowView.layer.shadowRadius = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
