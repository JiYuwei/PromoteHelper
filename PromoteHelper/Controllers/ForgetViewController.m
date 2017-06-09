//
//  ForgetViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/2/23.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "ForgetViewController.h"
#import "PHDeviceHelper.h"
#import "NetworkRequest.h"

@interface ForgetViewController () <UITextFieldDelegate,UIAlertViewDelegate>

@end

@implementation ForgetViewController
{
    dispatch_source_t _timer;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"重置密码";
    
    _phoneField.delegate=self;
    _vcodeField.delegate=self;
    _pwdField.delegate=self;
    _confirmField.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getVcodeAction:(UIButton *)sender
{
    if (_phoneField.text.length<11 || _phoneField.text.length>11) {
        [PHDeviceHelper alert:@"请输入正确的手机号!"];
        return;
    }
    
    [self startTime];
    
    NSString *getVcodeUrl=GETVCODE_URL;
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     _phoneField.text,MOBILE,
                                     nil];
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:getVcodeUrl parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        if ([json[ERROR_CODE] integerValue]!=0) {
            [PHDeviceHelper alert:json[ERROR_MSG]];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [PHDeviceHelper alert:@"网络不给力，请稍后再试。"];
    }];
}

//重置密码
- (IBAction)doneAction:(UIButton *)sender
{
    if ([self checkUserInfo]) {
        [self changeLoadingStatus:YES];
        
        NSString *forgetUrl=FORGET_PWD_URL;
        
        NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         _phoneField.text,MOBILE,
                                         _vcodeField.text,VCODE,
                                         _pwdField.text,PASSWORD,
                                         _confirmField.text,REPASSWORD,
                                         nil];
        
        [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:forgetUrl parameters:parameters success:^(NSDictionary *json) {
            [self changeLoadingStatus:NO];
            NSLog(@"%@",json);
            
            if ([json[ERROR_CODE] integerValue]==0) {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"密码重置成功！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                [PHDeviceHelper alert:json[ERROR_MSG]];
            }
            
        } failure:^(NSError *error) {
            [self changeLoadingStatus:NO];
            NSLog(@"%@",error);
            [PHDeviceHelper alert:@"网络不给力，请稍后再试！"];
        }];
        
    }
}


-(void)startTime{
    [_getVcodeBtn setEnabled:NO];
    _getVcodeBtn.alpha=0.5;
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){
            //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 根据自己需求设置倒计时结束的情况
                [_getVcodeBtn setEnabled:YES];
                _getVcodeBtn.alpha=1;
                [_getVcodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _getVcodeBtn.titleLabel.text=[NSString stringWithFormat:@"%d s",timeout];
                [_getVcodeBtn setTitle:[NSString stringWithFormat:@"%d s",timeout] forState:UIControlStateDisabled];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
}

-(BOOL)checkUserInfo
{
    NSArray *userInfoArr=@[_phoneField.text,_vcodeField.text,_pwdField.text,_confirmField.text];
    
    for (NSString *value in userInfoArr) {
        if (value.length==0) {
            [PHDeviceHelper alert:@"请将信息填写完整！"];
            return NO;
        }
    }
    
    if ([userInfoArr[0] length]!=11) {
        [PHDeviceHelper alert:@"手机号格式不正确！"];
        return NO;
    }
    
    if ([userInfoArr[2] length]<6 || [userInfoArr[2] length]>16) {
        [PHDeviceHelper alert:@"密码长度不符合要求！"];
        return NO;
    }
    
    if (![userInfoArr[2] isEqualToString:userInfoArr[3]]) {
        [PHDeviceHelper alert:@"两次输入密码不同！"];
        return NO;
    }
    
    return YES;
}


-(void)changeLoadingStatus:(BOOL)status
{
    if (status) {
        [_doneBtn setTitle:@"" forState:UIControlStateNormal];
        [_doneBtn setEnabled:NO];
        [_loadingView startAnimating];
    }
    else{
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setEnabled:YES];
        [_loadingView stopAnimating];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_phoneField) {
        [_vcodeField becomeFirstResponder];
    }
    else if (textField==_vcodeField){
        [_pwdField becomeFirstResponder];
    }
    else if (textField==_pwdField){
        [_confirmField becomeFirstResponder];
    }
    else if (textField==_confirmField){
        [_confirmField resignFirstResponder];
    }
   
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_phoneField resignFirstResponder];
    [_vcodeField resignFirstResponder];
    [_pwdField resignFirstResponder];
    [_confirmField resignFirstResponder];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
