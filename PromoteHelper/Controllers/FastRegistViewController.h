//
//  FastRegistViewController.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 16/3/7.
//  Copyright © 2016年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FastRegistViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *vcodeField;
@property (weak, nonatomic) IBOutlet UITextField *procodeField;
@property (weak, nonatomic) IBOutlet UIButton *getVcodeButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@property (nonatomic) NSInteger confirmStatus;
@property (nonatomic,strong) NSDictionary *wxLoginData;
@property (nonatomic,strong) NSDictionary *wxUserContent;

- (IBAction)getVcode:(UIButton *)sender;
- (IBAction)registerAction:(UIButton *)sender;

@end
