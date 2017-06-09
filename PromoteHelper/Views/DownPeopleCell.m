//
//  DownPeopleCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/1/26.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DownPeopleCell.h"

@implementation DownPeopleCell

- (void)awakeFromNib {
    _careerArray=@[@"",@"区负责人",@"省负责人",@"校负责人"];
}


-(void)setDownViewType:(DownViewType)downViewType
{
    if (_downViewType!=downViewType) {
        _downViewType=downViewType;
    }
    
    BOOL isNoSchool=[_dataContent[@"school"] isEqualToString:@""] || [_dataContent[@"school"] isEqualToString:@"0"];
    
    switch (_downViewType) {
        case DownViewTypePeople:{
            
            self.selectionStyle=UITableViewCellSelectionStyleNone;
            
            NSInteger userType=[_dataContent[@"user_type"] integerValue];
            
            BOOL hasName=_dataContent[@"name"] && [_dataContent[@"name"] length]!=0;
            
            _nameLabel.text=hasName?_dataContent[@"name"]:_dataContent[@"nickname"];
            _schoolLabel.text=isNoSchool?@"微令大学":_dataContent[@"school"];
            _careerLabel.text=userType<_careerArray.count?_careerArray[userType]:@"";
            _timeLabel.text=_dataContent[@"register_time"];
            
            break;
        }
        case DownViewTypeTask:{
            
            self.selectionStyle=UITableViewCellSelectionStyleDefault;
            
            _nameLabel.text=_dataContent[@"app_name"];
            _schoolLabel.text=@"";
            _careerLabel.text=@"";
            _timeLabel.text=[NSString stringWithFormat:@"已完成：%@",_dataContent[@"number"]];
            
            break;
        }
        case DownViewTypeTaskDetail:{
            
            self.selectionStyle=UITableViewCellSelectionStyleNone;
            
            NSInteger userType=[_dataContent[@"user_type"] integerValue];
            
            BOOL hasName=_dataContent[@"name"] && [_dataContent[@"name"] length]!=0;
            
            _nameLabel.text=hasName?_dataContent[@"name"]:_dataContent[@"nickname"];
            _schoolLabel.text=isNoSchool?@"微令大学":_dataContent[@"school"];
            _careerLabel.text=userType<_careerArray.count?_careerArray[userType]:@"";
            _timeLabel.text=[NSString stringWithFormat:@"%@个任务",_dataContent[@"number"]];
            
            break;
        }
        default:
            break;
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
