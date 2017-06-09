//
//  ForgetViewController.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/2/23.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *vcodeField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UITextField *confirmField;

@property (weak, nonatomic) IBOutlet UIButton *getVcodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

- (IBAction)getVcodeAction:(UIButton *)sender;
- (IBAction)doneAction:(UIButton *)sender;

@end
