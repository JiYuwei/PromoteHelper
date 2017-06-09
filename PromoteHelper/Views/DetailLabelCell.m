//
//  DetailLabelCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/24.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "DetailLabelCell.h"

@implementation DetailLabelCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setAppContent:(NSDictionary *)appContent
{
    if (_appContent!=appContent) {
        _appContent=appContent;
    }
//    NSInteger taskType=[_appContent[@"task_type"] integerValue];
//    NSInteger maxDay=[_appContent[@"task_day"] integerValue];
    
    NSString *taskStr=_appContent[@"task_require"];
    if (taskStr && taskStr.length!=0) {
        _taskLabel.text=taskStr;
    }
    else{
        _taskLabel.text=@"安装完成启动app并进行注册登录即可。(需要在本app中打开才可完成任务)";
    }
    
//    if (taskType==1) {
//        _taskLabel.text=@"安装完成启动app并进行注册登录即可。(需要在本app中打开才可完成任务)";
//    }
//    else if (taskType==2){
//        _taskLabel.text=[NSString stringWithFormat:@"安装完成启动app并进行注册登录，保持%ld天连续打开app即可。(需要在本app中打开才可计算天数)",maxDay];
//    }
//    else{
    
//    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
