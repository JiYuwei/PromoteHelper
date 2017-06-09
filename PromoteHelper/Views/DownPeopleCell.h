//
//  DownPeopleCell.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/26.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DownViewType){
    DownViewTypePeople,
    DownViewTypeTask,
    DownViewTypeTaskDetail
};

@interface DownPeopleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *careerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property(nonatomic)DownViewType downViewType;
@property(nonatomic,strong)NSArray *careerArray;
@property(nonatomic,strong)NSDictionary *dataContent;

@end
