//
//  MainViewCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/25.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "MainViewCell.h"
#import "NetworkRequest.h"
#import "PHDeviceHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "LSApplicationWorkspace.h"
#import "UIView+CornerMode.h"

@implementation MainViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _iconImgView.layer.cornerRadius=10;
    _iconImgView.layer.masksToBounds=YES;
    _iconImgView.layer.shouldRasterize=YES;
    _iconImgView.layer.rasterizationScale=_iconImgView.layer.contentsScale;
    _iconImgView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _iconImgView.layer.borderWidth=0.5;
    
    _actBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    _actBtn.layer.borderWidth=0.4;
    _actBtn.layer.cornerRadius=5;
    _actBtn.layer.masksToBounds=YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setAppContent:(NSDictionary *)appContent
{
    if (_appContent != appContent) {
        _appContent=appContent;
    }
    
    _titleLabel.text=_appContent[@"app_name"];
    _typeLabel.text=_appContent[@"company"];
    
    NSInteger status=[_appContent[@"task_type"] integerValue];
    NSArray *colorArr=@[[UIColor greenColor],[UIColor orangeColor],[UIColor brownColor]];
    NSArray *strArr=@[@"",@"连续签到",@"注册截图"];
    
    if (status>0 && status<=colorArr.count) {
        _statusLabel.textColor=colorArr[status-1];
        _statusLabel.text=strArr[status-1];
    }
    
    if ([[_appContent allKeys] containsObject:@"is_signed"]) {
        BOOL isSigned=[_appContent[@"is_signed"] boolValue];
        _statusLabel.textColor=isSigned?[UIColor colorWithRed:0 green:0.8 blue:0 alpha:1]:[UIColor orangeColor];
        _statusLabel.text=isSigned?@"今日已签":@"今日未签";
    }
    else if ([[_appContent allKeys] containsObject:@"is_upload"]) {
        NSInteger isUpload=[_appContent[@"is_upload"] integerValue];
        if (isUpload==1) {
            _statusLabel.textColor=[UIColor orangeColor];
            _statusLabel.text=@"截图审核中";
        }
        else if (isUpload==-1){
            _statusLabel.textColor=[UIColor redColor];
            _statusLabel.text=@"审核失败";
        }
        else{
            _statusLabel.textColor=[UIColor brownColor];
            _statusLabel.text=@"请上传截图";
        }
        
    }
    
    
    NSString *imgUrl=_appContent[@"app_logo"];
    
    if (imgUrl) {
        [_iconImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"empty"]];
    }
    else{
        _iconImgView.image=[UIImage imageNamed:@"empty"];
    }
    
    NSString *bundleID=_appContent[@"bundle_id"];
    if (![[LSApplicationWorkspace defaultWorkspace] applicationIsInstalled:bundleID]) {
        [_actBtn setTitle:@"安装" forState:UIControlStateNormal];
    }
    else{
        [_actBtn setTitle:@"打开" forState:UIControlStateNormal];
    }
    
    BOOL isValid=[_appContent[@"isvalid"] boolValue];
    
    if (isValid) {
        [_actBtn setEnabled:YES];
        _actBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    }
    else{
        [_actBtn setTitle:@"已结束" forState:UIControlStateNormal];
        _actBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
        [_actBtn setEnabled:NO];
    }
    
    
    [self checkFinished];
}

- (void)checkFinished
{
    NSInteger finishIndex=[_appContent[@"status"] integerValue];
    BOOL isFinished=finishIndex==1;
    
    _finishedView.hidden=!isFinished;
    _statusLabel.hidden=isFinished;
    
    if (isFinished) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
}

- (IBAction)onClick:(UIButton *)sender
{
    if (![[PHDeviceHelper sharedHelper] checkVarify]) {
        return;
    }
    
    NSString *bundleID=_appContent[@"bundle_id"];
    NSInteger status=[_appContent[@"status"] integerValue];
    if ([[LSApplicationWorkspace defaultWorkspace] applicationIsInstalled:bundleID]) {
        if([[LSApplicationWorkspace defaultWorkspace] openApplicationWithBundleID:bundleID]){
            if (status!=1) {
                NSString *appId=_appContent[@"app_id"];
                NSInteger taskType=[_appContent[@"task_type"] integerValue];
                [self.delegate saveTaskStateWithID:appId andType:[NSNumber numberWithInteger:taskType] andDateStr:_appContent[@"app_open_date"]];
            }
        }
    }
    else{
        //跳转到app store
        NSLog(@"跳转到 app store");
        NSString *appUrl=_appContent[@"ios_url"];
        if (appUrl && appUrl.length!=0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
        }
    }
}
@end
