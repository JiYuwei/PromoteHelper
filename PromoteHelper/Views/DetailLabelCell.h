//
//  DetailLabelCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/24.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailLabelCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *taskLabel;

@property(nonatomic,strong) NSDictionary *appContent;

@end
