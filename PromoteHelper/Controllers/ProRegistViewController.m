//
//  ProRegistViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/7.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "ProRegistViewController.h"
#import "PHDeviceHelper.h"
#import "NetworkRequest.h"
#import "RuleViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImage+ColorImage.h"

@interface ProRegistViewController () <UITextFieldDelegate,UIAlertViewDelegate,UITextViewDelegate>

@property(nonatomic,strong)UIAlertView *cancelAlert;

@end

@implementation ProRegistViewController
{
    dispatch_source_t _timer;
    UIButton *_pointBtn;
}

#pragma mark - 监听相应通知
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
    
    //注销通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)backAction
{
    if (_cancelAlert) {
        _cancelAlert=nil;
    }
    _cancelAlert=[[UIAlertView alloc] initWithTitle:@"注意" message:@"确定放弃注册吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [_cancelAlert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=_confirmStatus?@"完善个人信息":@"用户注册";
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:0.17f green:0.62f blue:0.86f alpha:1.00f];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(backAction)];
    
    _phoneField.delegate=self;
    _vcodeField.delegate=self;
    _pwdField.delegate=self;
    _nicknameField.delegate=self;
    _realnameField.delegate=self;
    _idcodeField.delegate=self;
    _schoolField.delegate=self;
    _procodeField.delegate=self;
    _ruleView.delegate=self;
    _ruleView.textColor=[UIColor lightGrayColor];
    
    [_idcodeField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    
    [self customListLabel];
    [self customUserInfo:_confirmStatus];
}


#pragma mark - 处理TextField响应事件
- (void)editingDidBegin:(UITextField *)textF
{
    [self configPointInKeyBoardButton];
}

#pragma mark - 自定义"点"按钮
- (void)configPointInKeyBoardButton
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if (_pointBtn == nil) {
        _pointBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pointBtn.frame = CGRectMake(0, screenHeight, screenWidth/3-2, 53);
        _pointBtn.backgroundColor = [UIColor clearColor];
        [_pointBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_pointBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        [_pointBtn setTitle:@" X" forState:UIControlStateNormal];
        _pointBtn.titleLabel.font=[UIFont systemFontOfSize:25];
        [_pointBtn addTarget:self action:@selector(pointAction) forControlEvents:UIControlEventTouchUpInside];
    }
    [self performSelector:@selector(addPointButton) withObject:nil afterDelay:0.0f];
}

- (void)addPointButton
{
    UIWindow *tempWindow = [[[UIApplication sharedApplication] windows] lastObject];
    [tempWindow addSubview:_pointBtn];
}

#pragma mark - 处理"点"按钮响应事件
- (void)pointAction
{
    [_idcodeField insertText:@"X"];
}

#pragma mark - 处理键盘响应事件
- (void)handleKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    if (_pointBtn && _pointBtn.frame.origin.y>self.view.bounds.size.height+53.5) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        _pointBtn.transform = CGAffineTransformTranslate(_pointBtn.transform, 0, -53.5);
        [UIView commitAnimations];
    }
    
}

- (void)handleKeyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (_pointBtn.superview) {
        [UIView animateWithDuration:animationDuration animations:^{
            _pointBtn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [_pointBtn removeFromSuperview];
            _pointBtn = nil;
        }];
    }
}


//区分注册or完善信息
-(void)customUserInfo:(NSInteger)index
{
    if (index) {
        if (index==1) {
            _schoolField.placeholder=@"学校";
            _procodeField.placeholder=@"推广码";
        }
        
        _phoneField.text=_wxUserContent[@"phone"];
        _nicknameField.text=_wxUserContent[@"nickname"];
        _realnameField.text=_wxUserContent[@"name"];
        _schoolField.text=_wxUserContent[@"school"];
        _pwdField.secureTextEntry=NO;
        NSArray *typeArr=@[@"",@"校负责人",@"普通用户"];
        _pwdField.placeholder=typeArr[index];
        [_pwdField setEnabled:NO];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _mainView.contentSize=CGSizeMake([[UIScreen mainScreen] bounds].size.width, 504);
}

- (void)didReceiveMemoryWarning
{
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
                                         _pwdField.text,PASSWORD,
                                         _nicknameField.text,NICKNAME,
                                         _realnameField.text,REALNAME,
                                         _idcodeField.text,IDCODE,
                                         _schoolField.text.length==0?@"0":_schoolField.text,SCHOOL,
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
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithString:_pwdField.text] forKey:PASSWORD];
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



-(BOOL)checkUserInfo
{
    NSArray *userInfoArr=@[_phoneField.text,_vcodeField.text,_pwdField.text,_realnameField.text,_idcodeField.text,_nicknameField.text];
    if (_confirmStatus==1) {
        userInfoArr=@[_phoneField.text,_vcodeField.text,_realnameField.text,_idcodeField.text,_nicknameField.text,_schoolField.text,_procodeField.text];
    }
    else if (_confirmStatus==2){
        userInfoArr=@[_phoneField.text,_vcodeField.text,_realnameField.text,_idcodeField.text,_nicknameField.text];
    }
    
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
    
    if (!_confirmStatus && ([userInfoArr[2] length]<6 || [userInfoArr[2] length]>16)) {
        [PHDeviceHelper alert:@"密码长度不符合要求！"];
        return NO;
    }
    
    if (![PHDeviceHelper validateIDCardNumber:_idcodeField.text]) {
        [PHDeviceHelper alert:@"身份证格式不正确！"];
        return NO;
    }
    
    return YES;
}


#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField!=_idcodeField) {
        _pointBtn.hidden=YES;
    }
    else{
        _pointBtn.hidden=NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==_phoneField) {
        [_vcodeField becomeFirstResponder];
    }
    else if (textField==_vcodeField){
        [_pwdField becomeFirstResponder];
    }
    else if (textField==_pwdField){
        [_nicknameField becomeFirstResponder];
    }
    else if (textField==_nicknameField){
        [_realnameField becomeFirstResponder];
    }
    else if (textField==_realnameField){
        [_idcodeField becomeFirstResponder];
    }
    else if (textField==_idcodeField){
        [_schoolField becomeFirstResponder];
    }
    else if (textField==_schoolField){
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
    [_pwdField resignFirstResponder];
    [_nicknameField resignFirstResponder];
    [_realnameField resignFirstResponder];
    [_idcodeField resignFirstResponder];
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

-(void)customListLabel
{
    NSString *ruleStr=@"推广司令";
    NSMutableAttributedString *listStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"注册即视为同意%@条款并将遵守该条款",ruleStr]];
    [listStr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                             NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, listStr.length)];
    [listStr addAttributes:@{NSForegroundColorAttributeName:BASE_COLOR,
                             NSUnderlineStyleAttributeName:@1,
                             NSLinkAttributeName:@""} range:NSMakeRange(7, ruleStr.length)];
    
    _ruleView.attributedText=listStr;
}

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    RuleViewController *ruleVC=[[RuleViewController alloc] init];
    [self.navigationController pushViewController:ruleVC animated:YES];
    return YES;
}

@end
