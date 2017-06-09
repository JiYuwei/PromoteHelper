//
//  CodeViewController.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/12/4.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "CodeViewController.h"
#import "QRCodeGenerator.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface CodeViewController ()

@property(nonatomic,strong)UIView *baseView;
@property(nonatomic,strong)UIImageView *codeView;
@property(nonatomic,strong)UIImageView *iconView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *typeLabel;
@property(nonatomic,strong)UILabel *proLabel;
@property(nonatomic,strong)UILabel *bottomLabel;

@end

@implementation CodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"二维码";
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.view.backgroundColor=[UIColor darkGrayColor];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    
    [self createUI];
}

//分享
-(void)share
{
    
//创建分享参数
    NSDictionary *userDic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *proCode=userDic[@"promoter_code"];
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"推广司令，躺着赚钱的司令！\n推广码：%@\n%@\n",proCode,DOWN_URL]
                                     images:@[[UIImage imageNamed:@"icon180"]]
                                        url:[NSURL URLWithString:DOWN_URL]
                                      title:@"推广司令，躺着赚钱的司令！"
                                       type:SSDKContentTypeAuto];
//微信朋友圈定制
    [shareParams SSDKSetupWeChatParamsByText:nil
                                       title:[NSString stringWithFormat:@"推广司令，躺着赚钱的司令！\n推广码：%@",proCode]
                                         url:[NSURL URLWithString:DOWN_URL]
                                  thumbImage:nil
                                       image:[UIImage imageNamed:@"icon180"]
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeAuto
                          forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];

//微信好友定制
    [shareParams SSDKSetupWeChatParamsByText:[NSString stringWithFormat:@"推广码：%@\n%@",proCode,DOWN_URL]
                                       title:@"推广司令，躺着赚钱的司令！"
                                         url:[NSURL URLWithString:DOWN_URL]
                                  thumbImage:nil
                                       image:[UIImage imageNamed:@"icon180"]
                                musicFileURL:nil
                                     extInfo:nil
                                    fileData:nil
                                emoticonData:nil
                                        type:SSDKContentTypeAuto
                          forPlatformSubType:SSDKPlatformSubTypeWechatSession];
//QQ定制
    [shareParams SSDKSetupQQParamsByText:[NSString stringWithFormat:@"推广码：%@\n%@",proCode,DOWN_URL]
                                   title:@"推广司令，躺着赚钱的司令！"
                                     url:[NSURL URLWithString:DOWN_URL]
                              thumbImage:nil
                                   image:[UIImage imageNamed:@"icon180"]
                                    type:SSDKContentTypeAuto
                      forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
    [shareParams SSDKSetupQQParamsByText:[NSString stringWithFormat:@"推广码：%@\n%@",proCode,DOWN_URL]
                                   title:@"推广司令，躺着赚钱的司令！"
                                     url:[NSURL URLWithString:DOWN_URL]
                              thumbImage:nil
                                   image:[UIImage imageNamed:@"icon180"]
                                    type:SSDKContentTypeAuto
                      forPlatformSubType:SSDKPlatformSubTypeQZone];
    
//弹出分享菜单
    [ShareSDK showShareActionSheet:nil
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
     {
        switch (state) {
            case SSDKResponseStateSuccess:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                    message:nil
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
            case SSDKResponseStateFail:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                    message:[NSString stringWithFormat:@"%@", error]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
                [alertView show];
                break;
            }
                
            default:
                break;
        }
        
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }];
}


-(void)createUI
{
    _baseView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-40, (self.view.bounds.size.height-64)/9*8)];
    _baseView.center=CGPointMake(self.view.bounds.size.width/2, (self.view.bounds.size.height-64)/2);
    _baseView.backgroundColor=[UIColor whiteColor];
    _baseView.layer.cornerRadius=3;
    _baseView.layer.masksToBounds=YES;
    [self.view addSubview:_baseView];
    
    CGSize size=_baseView.bounds.size;
    
    _iconView=[[UIImageView alloc] initWithFrame:CGRectMake(size.width/2-80, size.height/12, 60, 60)];
    _iconView.layer.cornerRadius=10;
    _iconView.layer.masksToBounds=YES;
    _iconView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _iconView.layer.borderWidth=0.5;
    _iconView.image=[UIImage imageNamed:@"icon180"];
    [_baseView addSubview:_iconView];
    
    _titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(size.width/2-10, _iconView.frame.origin.y, 100, 20)];
    _titleLabel.text=@"推广司令";
//    _titleLabel.backgroundColor=[UIColor yellowColor];
    [_baseView addSubview:_titleLabel];
    
    _typeLabel=[[UILabel alloc] initWithFrame:CGRectMake(size.width/2-10, _iconView.frame.origin.y+20, 100, 20)];
    _typeLabel.font=[UIFont systemFontOfSize:14];
    _typeLabel.textColor=[UIColor grayColor];
    NSString *version=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *appSize=@"3.3MB";
    _typeLabel.text=[NSString stringWithFormat:@"%@   %@",version,appSize];
//    _typeLabel.backgroundColor=[UIColor redColor];
    [_baseView addSubview:_typeLabel];
    
//    NSDictionary *dicInfo = [[NSBundle mainBundle] infoDictionary];
//    NSLog(@"App Info: %@", [dicInfo debugDescription]);
    
    _proLabel=[[UILabel alloc] initWithFrame:CGRectMake(size.width/2-10, _iconView.frame.origin.y+40, 100, 20)];
    _proLabel.font=[UIFont systemFontOfSize:14];
    _proLabel.textColor=[UIColor darkGrayColor];
    NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *proCode=userDict[@"promoter_code"];
    if (proCode && proCode.length!=0) {
        _proLabel.text=[NSString stringWithFormat:@"推广码：%@",proCode];
    }
//    _proLabel.backgroundColor=[UIColor blackColor];
    [_baseView addSubview:_proLabel];
    
    _codeView=[[UIImageView alloc] initWithFrame:CGRectMake((size.width-size.height/6*5+150)/2, size.height/6+70, size.height/6*5-150, size.height/6*5-150)];
    _codeView.backgroundColor=[UIColor whiteColor];
    _codeView.contentMode=UIViewContentModeScaleAspectFit;
    _codeView.image=[QRCodeGenerator qrImageForString:DOWN_URL imageSize:(NSUInteger)_codeView.frame.size.width+1];
    [_baseView addSubview:_codeView];
    
    
    _bottomLabel=[[UILabel alloc] initWithFrame:CGRectMake(20, size.height-30, size.width-40, 20)];
    _bottomLabel.font=[UIFont systemFontOfSize:13];
    _bottomLabel.textColor=[UIColor lightGrayColor];
    _bottomLabel.textAlignment=NSTextAlignmentCenter;
    _bottomLabel.text=@"扫一扫上面的二维码，即刻下载";
    [_baseView addSubview:_bottomLabel];
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

@end
