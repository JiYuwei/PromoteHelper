//
//  LoginViewController.h
//  剑灵帮帮
//
//  Created by qianfeng on 14-11-13.
//  Copyright (c) 2014年 jyw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *wxLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgetBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;


- (IBAction)wxLoginAction:(UIButton *)sender;
- (IBAction)loginAction:(UIButton *)sender;
- (IBAction)registerAction:(UIButton *)sender;
- (IBAction)forgetAction:(UIButton *)sender;

@end
