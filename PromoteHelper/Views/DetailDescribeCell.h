//
//  DetailDescribeCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/1.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailDescribeCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *describeView;

@property(nonatomic,strong)NSDictionary *appContent;

@end
