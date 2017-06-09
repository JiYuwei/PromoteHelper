//
//  UserHeaderView.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/26.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "UserHeaderView.h"
#import "CodeViewController.h"
#import "PHDeviceHelper.h"
#import "DownPeoViewController.h"
#import "DownTaskViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ChangeHeaderController.h"
#import "BaseNavViewController.h"

@implementation UserHeaderView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor=[UIColor colorWithRed:69/255.f green:175/255.f blue:223/255.f alpha:1];
        [self createUI];
    }
    return self;
}

-(void)openPhotoAlbum
{
    ChangeHeaderController *changeVC=[[ChangeHeaderController alloc] init];
    changeVC.title=@"选择图片";
    changeVC.cropSize=[[UIScreen mainScreen] bounds].size;
    BaseNavViewController *baseNavVC=[[BaseNavViewController alloc] initWithRootViewController:changeVC];
    [[[PHDeviceHelper sharedHelper] viewControllerWithView:self] presentViewController:baseNavVC animated:YES completion:nil];
}

-(void)createUI
{
    _userView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _userView.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/5*1.5);
    _userView.layer.cornerRadius=_userView.frame.size.width/2;
    _userView.layer.masksToBounds=YES;
    _userView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _userView.layer.borderWidth=0.5;
    _userView.backgroundColor=[UIColor whiteColor];
    _userView.image=[UIImage imageNamed:@"head"];
    _userView.userInteractionEnabled=YES;
//    [_userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoAlbum)]];
    [self addSubview:_userView];
    
    _userLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 35)];
    _userLabel.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/5*3);
    _userLabel.textAlignment=NSTextAlignmentCenter;
    _userLabel.textColor=[UIColor whiteColor];
    
    [self addSubview:_userLabel];
    
    _proLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 35)];
    _proLabel.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/5*3.5);
    _proLabel.textAlignment=NSTextAlignmentCenter;
    _proLabel.textColor=[UIColor whiteColor];
    _proLabel.font=[UIFont systemFontOfSize:14];
    [self addSubview:_proLabel];

    _codeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _codeBtn.frame=CGRectMake(self.bounds.size.width-50, 0, 50, 50);
    [_codeBtn setImage:[UIImage imageNamed:@"code"] forState:UIControlStateNormal];
    [_codeBtn addTarget:self action:@selector(showCodeImg) forControlEvents:UIControlEventTouchUpInside];
    _codeBtn.hidden=YES;
    [self addSubview:_codeBtn];
    
    _downPeoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _downPeoBtn.frame=CGRectMake(0.5, self.bounds.size.height-40.5, self.bounds.size.width/2, 40);
    _downPeoBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    _downPeoBtn.layer.borderWidth=1;
    _downPeoBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [_downPeoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_downPeoBtn addTarget:self action:@selector(openDownPeoVC) forControlEvents:UIControlEventTouchUpInside];
//    _downPeoBtn.backgroundColor=[UIColor redColor];
    [self addSubview:_downPeoBtn];
    
    _finishBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    _finishBtn.frame=CGRectMake(self.bounds.size.width/2-0.5, self.bounds.size.height-40.5, self.bounds.size.width/2, 40);
    _finishBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    _finishBtn.layer.borderWidth=1;
    _finishBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [_finishBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_finishBtn addTarget:self action:@selector(openFinishedVC) forControlEvents:UIControlEventTouchUpInside];
//    _finishBtn.backgroundColor=[UIColor blueColor];
    [self addSubview:_finishBtn];
    
}

-(void)setUserContent:(NSDictionary *)userContent
{
    if (_userContent!=userContent) {
        _userContent=userContent;
    }

    BOOL isPassed=[_userContent[@"verify_state"] integerValue];
    NSArray *careerArr=@[@"",@"区负责人：",@"省负责人：",@"校负责人："];
    NSInteger userType=[_userContent[@"user_type"] integerValue];
    _userLabel.text=[NSString stringWithFormat:@"%@%@",userType<careerArr.count?careerArr[userType]:@"",_userContent[@"nickname"]];
    _proLabel.text=isPassed?[NSString stringWithFormat:@"推广码：%@",_userContent[@"promoter_code"]]:@"(审核中)";
    _codeBtn.hidden=isPassed?NO:YES;
    
    if (_userContent[@"headimgurl"] && [_userContent[@"headimgurl"] length]!=0) {
        [_userView sd_setImageWithURL:_userContent[@"headimgurl"] placeholderImage:[UIImage imageNamed:@"head"]];
    }
    else{
        _userView.image=[UIImage imageNamed:@"head"];
    }
    
    
}

-(void)setDataContent:(NSDictionary *)dataContent
{
    if (_dataContent!=dataContent) {
        _dataContent=dataContent;
    }
    
    [_downPeoBtn setTitle:[NSString stringWithFormat:@"下线人数：%@人",_dataContent[@"people_number"]?_dataContent[@"people_number"]:@"0"] forState:UIControlStateNormal];
    [_finishBtn setTitle:[NSString stringWithFormat:@"已完成任务：%@",_dataContent[@"total_task_number"]?_dataContent[@"total_task_number"]:@"0"] forState:UIControlStateNormal];
}

-(void)showCodeImg
{
    CodeViewController *codeVC=[[CodeViewController alloc] init];
    [[[PHDeviceHelper sharedHelper] viewControllerWithView:self].navigationController pushViewController:codeVC animated:YES];
}

//下线人数
-(void)openDownPeoVC
{
    DownPeoViewController *downPeoVC=[[DownPeoViewController alloc] init];
    [[[PHDeviceHelper sharedHelper] viewControllerWithView:self].navigationController pushViewController:downPeoVC animated:YES];
}

//已完成任务
-(void)openFinishedVC
{
    DownTaskViewController *downTaskVC=[[DownTaskViewController alloc] init];
    [[[PHDeviceHelper sharedHelper] viewControllerWithView:self].navigationController pushViewController:downTaskVC animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
