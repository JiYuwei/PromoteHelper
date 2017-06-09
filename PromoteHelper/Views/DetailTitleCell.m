//
//  DetailTitleCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/1.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "DetailTitleCell.h"
#import "LSApplicationWorkspace.h"
#import "PHDeviceHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DetailTitleCell

- (void)awakeFromNib {
    
    self.backgroundColor=BASE_COLOR;
    
    _appImgView.layer.cornerRadius=10;
    _appImgView.layer.masksToBounds=YES;
    _appImgView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _appImgView.layer.borderWidth=0.5;
    
    _actBtn.layer.borderColor=[UIColor whiteColor].CGColor;
    _actBtn.layer.borderWidth=0.4;
    _actBtn.layer.cornerRadius=5;
    _actBtn.layer.masksToBounds=YES;
}


-(void)setAppContent:(NSDictionary *)appContent
{
    if (_appContent!=appContent) {
        _appContent=appContent;
    }
    
    _titleLabel.text=_appContent[@"app_name"];
    _comLabel.text=_appContent[@"company"];
    _otherLabel.text=[NSString stringWithFormat:@"%@     %@",_appContent[@"version"],appContent[@"size"]];
    NSString *imgUrl=_appContent[@"app_logo"];
    if (imgUrl) {
        [_appImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"empty"]];
    }
    else{
        _appImgView.image=[UIImage imageNamed:@"empty"];
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
    }
    else{
        [_actBtn setTitle:@"已结束" forState:UIControlStateNormal];
        [_actBtn setEnabled:NO];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
                [self.delegate saveTaskState];
            }
        }
    }
    else{
        NSLog(@"跳转 app stroe");
        NSString *appUrl=_appContent[@"ios_url"];
        if (appUrl && appUrl.length!=0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appUrl]];
        }
    }
}

@end
