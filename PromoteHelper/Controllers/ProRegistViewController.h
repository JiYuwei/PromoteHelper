//
//  ProRegistViewController.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/7.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProRegistViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *mainView;

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *vcodeField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *realnameField;
@property (weak, nonatomic) IBOutlet UITextField *idcodeField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UITextField *schoolField;
@property (weak, nonatomic) IBOutlet UITextField *procodeField;
@property (weak, nonatomic) IBOutlet UIButton *getVcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UITextView *ruleView;

@property (nonatomic) NSInteger confirmStatus;
@property (nonatomic,strong) NSDictionary *wxLoginData;
@property (nonatomic,strong) NSDictionary *wxUserContent;

- (IBAction)getVcode:(UIButton *)sender;

- (IBAction)registerAction:(UIButton *)sender;

@end
