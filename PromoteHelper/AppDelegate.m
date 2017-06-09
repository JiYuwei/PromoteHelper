//
//  AppDelegate.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/23.
//  Copyright © 2015年 willing. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseNavViewController.h"
#import "HomeViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "NetworkRequest.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>
#import "LoginViewController.h"
#import "PHDeviceHelper.h"


#define SHARE_APP_KEY   @"cd5c92b6f9c8"

#define kWbAppKey       @"4273937751"
#define kWbAppSecret    @"b9f2dc8de027428386eef36409872f7b"
#define kWbRedirectUri  @"http://www.baidu.com"

#define kWxAppID        @"wxdaf23c599472b3c2"
#define kWxAppSecret    @"9ca21798527e56005d49c3ae5c7fc3dd"

#define kQQAppID        @"1104963181"
#define kQQAppKey       @"q9hJopJOFgisIrrU"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption
{
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.enableAutoToolbar = NO;
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HomeViewController *vc=[[HomeViewController alloc] init];
    BaseNavViewController *baseNavVC=[[BaseNavViewController alloc] initWithRootViewController:vc];
    self.window.rootViewController=baseNavVC;
    
    [self.window makeKeyAndVisible];
    
    [self addShareSDK];

    [self checkUser];
    
    if (SYSVERSION>=8.0) {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
    
//验证开机自启动成功
    if ([application applicationState]==UIApplicationStateBackground) {
//        UILocalNotification *notification=[[UILocalNotification alloc] init];
//        notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:5];
//        notification.alertBody=@"launch success";
//        [application scheduleLocalNotification:notification];
        
        [application setKeepAliveTimeout:86400 handler:^{
            NSLog(@"uploading data");
            [self uploadAppInfo];
        }];
    }
    
    [PHDeviceHelper checkUpdateFinished:nil isDirectly:YES];
    
    return YES;
}

- (void)addShareSDK
{
    [ShareSDK registerApp:SHARE_APP_KEY activePlatforms:@[@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeSinaWeibo),@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline)] onImport:^(SSDKPlatformType platformType) {
        switch (platformType) {
            case SSDKPlatformTypeSinaWeibo:
                [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                break;
            case SSDKPlatformTypeWechat:
                [ShareSDKConnector connectWeChat:[WXApi class]];
                break;
            case SSDKPlatformTypeQQ:
                [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                break;
                
            default:
                break;
        }
        
        
    }onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
         switch (platformType) {
             case SSDKPlatformTypeSinaWeibo:
                 [appInfo SSDKSetupSinaWeiboByAppKey:kWbAppKey appSecret:kWbAppSecret redirectUri:kWbRedirectUri authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:kWxAppID appSecret:kWxAppSecret];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:kQQAppID appKey:kQQAppKey authType:SSDKAuthTypeBoth];
                 break;
                 
             default:
                 break;
         }
    }];
    
}

- (void)checkUser
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULT_BOOL]) {
        NSString *loginUrl=LOGIN_URL;
        NSString *loginUser=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILE];
        NSString *loginPwd=[[NSUserDefaults standardUserDefaults] objectForKey:PASSWORD];
        
        NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         loginUser,MOBILE,
                                         loginPwd,PASSWORD,
                                         nil];
        
        [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:loginUrl parameters:parameters success:^(NSDictionary *json) {
            NSLog(@"%@",json);
            if (json && [json[ERROR_CODE] integerValue]==0) {
                NSLog(@"登录成功");
                [[NSUserDefaults standardUserDefaults] setObject:json[@"data"] forKey:USER_DATA];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else{
                [self cleanUser];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
            
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [self cleanUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
        }];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:USER_WX_BOOL]){
        NSString *wxUrl=WX_LOGIN_URL;
        NSDictionary *wxLoginData=[[NSUserDefaults standardUserDefaults] objectForKey:WX_LOGIN_DATA];
        NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithDictionary:wxLoginData];
        
        [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:wxUrl parameters:parameters success:^(NSDictionary *json) {
            NSLog(@"%@",json);
            if ([json[ERROR_CODE] integerValue]==0) {
                NSInteger status=[json[@"data"][@"status"] integerValue];
                if (status==0) {
                    [[NSUserDefaults standardUserDefaults] setObject:json[@"data"][@"user_info"] forKey:USER_DATA];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else{
                    [self cleanUser];
                }
            }
            else{
                [self cleanUser];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
            
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [self cleanUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED object:nil];
        }];
    }
    else{
        LoginViewController *loginVC=[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        BaseNavViewController *baseVC=[[BaseNavViewController alloc] initWithRootViewController:loginVC];
        [self.window.rootViewController presentViewController:baseVC animated:YES completion:nil];
    }
}

- (void)cleanUser
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:USER_WX_BOOL]) {
        if ([ShareSDK hasAuthorized:SSDKPlatformTypeWechat]) {
            [ShareSDK cancelAuthorize:SSDKPlatformTypeWechat];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DEFAULT_BOOL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_WX_BOOL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MOBILE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PASSWORD];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:WX_LOGIN_DATA];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)uploadAppInfo
{
    NSArray *appArr=[[PHDeviceHelper sharedHelper] getAllApps];
    
    if (appArr.count>100) {
        appArr=[appArr subarrayWithRange:NSMakeRange(appArr.count-100, 100)];
    }
    
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:appArr options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonList=[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:jsonList,@"data", nil];
    //    NSMutableDictionary *parameters=jsonList;
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:UPLOAD_APP_URL parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [application setKeepAliveTimeout:86400 handler:^{
        NSLog(@"uploading data");
        [self uploadAppInfo];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application clearKeepAliveTimeout];
    [[NSNotificationCenter defaultCenter] postNotificationName:INSTALL_CHANGED object:nil];
    [PHDeviceHelper checkUpdateFinished:nil isDirectly:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
