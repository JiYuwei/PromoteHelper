//
//  FastRegistViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/3/7.
//  Copyright © 2016年 willing. All rights reserved.
//

#import "FastRegistViewController.h"
#import "PHDeviceHelper.h"
#import "NetworkRequest.h"

#import <ShareSDK/ShareSDK.h>

@interface FastRegistViewController () <UITextFieldDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)UIAlertView *cancelAlert;

@end

@implementation FastRegistViewController
{
    dispatch_source_t _timer;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_timer) {
        dispatch_source_cancel(_timer);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 根据自己需求设置倒计时结束的情况
            [_getVcodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_getVcodeButton setEnabled:YES];
            
        });
    }
}

-(void)backAction
{
    if (_cancelAlert) {
        _cancelAlert=nil;
    }
    _cancelAlert=[[UIAlertView alloc] initWithTitle:@"注意" message:@"确定放弃注册吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [_cancelAlert show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"完善个人信息";
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:0.17f green:0.62f blue:0.86f alpha:1.00f];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backAction)];
    
    _phoneField.delegate=self;
    _vcodeField.delegate=self;
    _procodeField.delegate=self;
}




-(BOOL)checkUserInfo
{
    NSArray *userInfoArr=@[_phoneField.text,_vcodeField.text,_procodeField.text];
    
    for (NSString *value in userInfoArr) {
        if (value.length==0) {
            [PHDeviceHelper alert:@"请填写完整的注册信息！"];
            return NO;
        }
    }
    
    if ([userInfoArr[0] length]!=11) {
        [PHDeviceHelper alert:@"手机号格式不正确！"];
        return NO;
    }
    
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==_cancelAlert) {
        if (buttonIndex==1) {
            if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
                [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_phoneField) {
        [_vcodeField becomeFirstResponder];
    }
    else if (textField==_vcodeField){
        [_procodeField becomeFirstResponder];
    }
    else if (textField==_procodeField){
        [_procodeField resignFirstResponder];
    }
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_phoneField resignFirstResponder];
    [_vcodeField resignFirstResponder];
    [_procodeField resignFirstResponder];
}

-(void)startTime{
    [_getVcodeButton setEnabled:NO];
    _getVcodeButton.alpha=0.5;
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
                [_getVcodeButton setEnabled:YES];
                _getVcodeButton.alpha=1;
                [_getVcodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                _getVcodeButton.titleLabel.text=[NSString stringWithFormat:@"%d s",timeout];
                [_getVcodeButton setTitle:[NSString stringWithFormat:@"%d s",timeout] forState:UIControlStateDisabled];
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

-(void)changeLoadingStatus:(BOOL)status
{
    if (status) {
        [_registerButton setTitle:@"" forState:UIControlStateNormal];
        [_registerButton setEnabled:NO];
        [_loadingView startAnimating];
    }
    else{
        [_registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [_registerButton setEnabled:YES];
        [_loadingView stopAnimating];
    }
}

- (IBAction)getVcode:(UIButton *)sender
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

- (IBAction)registerAction:(UIButton *)sender
{
    if ([self checkUserInfo]) {
        [self changeLoadingStatus:YES];
        
        NSString *registerUrl;
        
        switch (_confirmStatus) {
            case 0:
                registerUrl=REGISTER_URL;
                break;
            case 1:
                registerUrl=SCHOOLER_REG_URL;
                break;
            case 2:
                registerUrl=OTHER_REG_URL;
                break;
                
            default:
                break;
        }
        
        NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         _phoneField.text,MOBILE,
                                         _vcodeField.text,VCODE,
                                         _wxUserContent[@"nickname"],NICKNAME,
                                         _procodeField.text.length==0?@"8888":_procodeField.text,UPPCODE,
                                         nil];
        
        if (_confirmStatus) {
            [parameters removeObjectForKey:PASSWORD];
            [parameters setObject:_wxUserContent[@"id"] forKey:@"id"];
            [parameters setObject:_wxUserContent[@"headimgurl"] forKey:@"headimgurl"];
        }
        
        [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:registerUrl parameters:parameters success:^(NSDictionary *json) {
            [self changeLoadingStatus:NO];
            NSLog(@"%@",json);
            if (json && [json[ERROR_CODE] integerValue]==0) {
                [[NSUserDefaults standardUserDefaults] setObject:json[@"data"] forKey:USER_DATA];
                
                if (!_confirmStatus) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:_phoneField.text] forKey:MOBILE];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULT_BOOL];
                }
                else{
                    [[NSUserDefaults standardUserDefaults] setObject:_wxLoginData forKey:WX_LOGIN_DATA];
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_WX_BOOL];
                }
                
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
                
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"消息" message:@"注册成功！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }
            else{
                [PHDeviceHelper alert:json[ERROR_MSG]];
            }
        } failure:^(NSError *error) {
            [self changeLoadingStatus:NO];
            NSLog(@"%@",error);
            [PHDeviceHelper alert:@"网络不给力，请稍后再试。"];
        }];
    }
}


@end
