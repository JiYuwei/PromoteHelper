//
//  LoginViewController.m
//  剑灵帮帮
//
//  Created by qianfeng on 14-11-13.
//  Copyright (c) 2014年 jyw. All rights reserved.
//

#import "LoginViewController.h"
#import "FastRegistViewController.h"
#import "ProRegistViewController.h"
#import "NetworkRequest.h"
#import "PHDeviceHelper.h"
#import <ShareSDK/ShareSDK.h>
#import "ForgetViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"登录";
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:0.17f green:0.62f blue:0.86f alpha:1.00f];
    // Do any additional setup after loading the view from its nib.
    _userField.delegate=self;
    _pwdField.delegate=self;
}

//- (void)createBarBtnItems
//{
//    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancelAction)];
//}

- (void)cancelAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)wxLoginAction:(UIButton *)sender
{
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        if (state==SSDKResponseStateSuccess) {
//            NSLog(@"\n\nuid=%@\n\n%@\n\ntoken=%@\n\nnickname=%@",user.uid,user.credential,user.credential.token,user.nickname);
            NSDictionary *rawData=user.rawData;
            NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             rawData[@"unionid"],@"unionid",
                                             rawData[@"openid"],@"openid",
                                             rawData[@"nickname"],@"nickname",
                                             rawData[@"sex"],@"sex",
                                             rawData[@"language"],@"language",
                                             rawData[@"city"],@"city",
                                             rawData[@"province"],@"province",
                                             rawData[@"country"],@"country",
                                             rawData[@"headimgurl"],@"headimgurl",
                                             nil];
            NSString *wxUrl=WX_LOGIN_URL;
            
            [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:wxUrl parameters:parameters success:^(NSDictionary *json) {
                NSLog(@"%@",json);
                if ([json[ERROR_CODE] integerValue]==0) {
                    NSInteger status=[json[@"data"][@"status"] integerValue];
                    if (status==0) {
                        [[NSUserDefaults standardUserDefaults] setObject:json[@"data"][@"user_info"] forKey:USER_DATA];
                        
                        [[NSUserDefaults standardUserDefaults] setObject:parameters forKey:WX_LOGIN_DATA];
                        
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_WX_BOOL];
                        
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else{
                        
                        FastRegistViewController *fastConfirmVC=[[FastRegistViewController alloc] initWithNibName:@"FastRegistViewController" bundle:nil];
                        fastConfirmVC.confirmStatus=status;
                        fastConfirmVC.wxLoginData=parameters;
                        fastConfirmVC.wxUserContent=json[@"data"][@"user_info"];
                        [self.navigationController pushViewController:fastConfirmVC animated:YES];
                        
//                        ProRegistViewController *confirmVC=[[ProRegistViewController alloc] initWithNibName:@"ProRegistViewController" bundle:nil];
//                        confirmVC.confirmStatus=status;
//                        confirmVC.wxLoginData=parameters;
//                        confirmVC.wxUserContent=json[@"data"][@"user_info"];
//                        [self.navigationController pushViewController:confirmVC animated:YES];
                    }
                }
                else{
                    [PHDeviceHelper alert:@"登录失败。"];
                    if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
                        [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
                    }
                }
                
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
                [PHDeviceHelper alert:@"网络不给力，请稍后再试。"];
                if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
                    [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
                }
            }];
        }
        else{
            NSLog(@"%@",error);
            [PHDeviceHelper alert:@"登录失败。"];
            if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
                [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
            }
        }
    }];
}

- (IBAction)loginAction:(UIButton *)sender
{
    if (_userField.text.length==0 || _pwdField.text.length==0) {
        [PHDeviceHelper alert:@"用户名或密码不能为空!"];
    }
    else if (_userField.text.length<11 || _userField.text.length>11){
        [PHDeviceHelper alert:@"手机号格式不正确!"];
    }
    else{
        [_userField resignFirstResponder];
        [_pwdField resignFirstResponder];
        
        [self changeLoadingStatus:YES];

        NSString *loginUrl=LOGIN_URL;
        NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         _userField.text,MOBILE,
                                         _pwdField.text,PASSWORD,
                                         nil];
        
        [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:loginUrl parameters:parameters success:^(NSDictionary *json) {
            [self changeLoadingStatus:NO];
            NSLog(@"%@",json);
            if (json && [json[ERROR_CODE] integerValue]==0) {
                NSLog(@"登录成功");
                [[NSUserDefaults standardUserDefaults] setObject:json[@"data"] forKey:USER_DATA];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:_userField.text] forKey:MOBILE];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:_pwdField.text] forKey:PASSWORD];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULT_BOOL];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)registerAction:(UIButton *)sender
{
    ProRegistViewController *regVC=[[ProRegistViewController alloc] initWithNibName:@"ProRegistViewController" bundle:nil];
    [self.navigationController pushViewController:regVC animated:YES];
}

//- (IBAction)proRegistAction:(UIButton *)sender
//{
//    ProRegistViewController *regVC=[[ProRegistViewController alloc] initWithNibName:@"ProRegistViewController" bundle:nil];
//    [self.navigationController pushViewController:regVC animated:YES];
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_userField resignFirstResponder];
    [_pwdField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_userField) {
        [_pwdField becomeFirstResponder];
    }
    else if (textField==_pwdField){
        [_pwdField resignFirstResponder];
    }
    return YES;
}

-(void)changeLoadingStatus:(BOOL)status
{
    if (status) {
        [_loginButton setTitle:@"" forState:UIControlStateNormal];
        [_loginButton setEnabled:NO];
        [_registerButton setEnabled:NO];
        [_forgetBtn setEnabled:NO];
        [_wxLoginButton setEnabled:NO];
        [_loadingView startAnimating];
    }
    else{
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setEnabled:YES];
        [_registerButton setEnabled:YES];
        [_forgetBtn setEnabled:YES];
        [_wxLoginButton setEnabled:YES];
        [_loadingView stopAnimating];
    }
}

- (IBAction)forgetAction:(UIButton *)sender
{
    ForgetViewController *forgetVC=[[ForgetViewController alloc] initWithNibName:@"ForgetViewController" bundle:nil];
    [self.navigationController pushViewController:forgetVC animated:YES];
}

@end
