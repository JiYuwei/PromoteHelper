//
//  DetailImageCell.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/2/18.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "DetailImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation DetailImageCell

- (void)awakeFromNib
{
    _uploadBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    _uploadBtn.layer.borderWidth=1;
    _uploadBtn.layer.cornerRadius=5;
    _uploadBtn.layer.masksToBounds=YES;
    [_uploadBtn setTitle:@"上传截图" forState:UIControlStateNormal];
    
    _submitBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    _submitBtn.layer.borderWidth=1;
    _submitBtn.layer.cornerRadius=5;
    _submitBtn.layer.masksToBounds=YES;
    [_submitBtn setTitle:@"提交任务" forState:UIControlStateNormal];
}


-(void)setAppContent:(NSDictionary *)appContent
{
    if (_appContent!=appContent) {
        _appContent=appContent;
    }
    
    NSInteger isUpload=[_appContent[@"is_upload"] integerValue];
    
    NSString *imgUrl=isUpload?_appContent[@"up_img"]:_appContent[@"example_img"];
    
    if (imgUrl && imgUrl.length!=0) {
        [_expImgView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
    }
    
    if (isUpload==1) {
        [_uploadBtn setEnabled:NO];
        _uploadBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
        
        [_submitBtn setTitle:@"审核中..." forState:UIControlStateNormal];
        [_submitBtn setEnabled:NO];
        _submitBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    }
    else if (isUpload==-1){
        [_uploadBtn setEnabled:YES];
        _uploadBtn.layer.borderColor=BUTTON_COLOR.CGColor;
        
        [_submitBtn setTitle:@"重新提交" forState:UIControlStateNormal];
        [_submitBtn setEnabled:YES];
        _submitBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    }
    else{
        [_uploadBtn setEnabled:YES];
        _uploadBtn.layer.borderColor=BUTTON_COLOR.CGColor;
        
        [_submitBtn setTitle:@"提交任务" forState:UIControlStateNormal];
        [_submitBtn setEnabled:YES];
        _submitBtn.layer.borderColor=BUTTON_COLOR.CGColor;
    }
}

-(void)setIsOpenBtn:(BOOL)isOpenBtn
{
    if (_isOpenBtn!=isOpenBtn) {
        _isOpenBtn=isOpenBtn;
    }
    
    _uploadBtn.hidden=!_isOpenBtn;
    _submitBtn.hidden=!_isOpenBtn;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)uploadAction:(UIButton *)sender
{
    [self.delegate openPhotoAlbum];
}

- (IBAction)submitAction:(UIButton *)sender
{
    if (_targetImage) {
        [self.delegate submitPhotoWithImage:_targetImage];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请先选择需要上传的截图！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


@end
