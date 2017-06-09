//
//  PHDeviceHelper.m
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/24.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PHDeviceHelper.h"
#import <objc/runtime.h>
#import "LSApplicationWorkspace.h"
#import "LSApplicationProxy.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <sys/sysctl.h>
#import "NSObject+PropertyListing.h"
#import "AppDelegate.h"
#import "WarningItem.h"
#import "NetworkRequest.h"

@interface PHDeviceHelper () <UIAlertViewDelegate>

@property(nonatomic,strong)WarningItem *alertWindow;
@property(nonatomic,strong)UIAlertView *updateAlert;

@end


@implementation PHDeviceHelper

static PHDeviceHelper* _helper = nil;

+(instancetype) sharedHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[self alloc] init];
    });
    
    return _helper;
}

- (NSMutableArray *) getAllApps
{
    NSDictionary *dic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *userId=dic[@"id"];
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray *allApps = [workspace performSelector:@selector(allApplications)];
    NSMutableArray *allAppNames = [[NSMutableArray alloc] init];
    //    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    for (LSApplicationProxy *app in allApps) {
        if ([app.applicationType isEqualToString:@"System"]) {
            continue;
        }
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:
                           userId,@"uid",
                           app.localizedName,@"app_name",
                           app.bundleIdentifier,@"bundle_id",
                           @"0",@"package_name",
                           nil];
        
        [allAppNames addObject:dic];
    }
    return allAppNames;
}

-(NSMutableArray *)getAppsInfo
{
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
    NSArray *allApps = [workspace performSelector:@selector(allApplications)];

    NSMutableArray *appInfoArr=[[NSMutableArray alloc] init];
    //    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    for (LSApplicationProxy *app in allApps) {
        if ([app.applicationType isEqualToString:@"System"] || [app.bundleIdentifier isEqualToString:BUNDLE_ID]) {
            continue;
        }

//        NSLog(@"%@",[app properties_aps]);
        NSDictionary *boundIconsDictionary = [app performSelector:@selector(boundIconsDictionary)];
        
        NSString *iconPath = [NSString stringWithFormat:@"%@/%@.png", [[app performSelector:@selector(resourcesDirectoryURL)] path], [[[boundIconsDictionary objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"]lastObject]];
        
        NSDictionary *appDic=[NSDictionary dictionaryWithObjectsAndKeys:
                              iconPath,@"app_logo",
                              app.bundleIdentifier,@"bundle_id",
                              app.localizedName,@"app_name",
                              app.itemID,@"appItemID",
                              app.shortVersionString,@"version",
                              app.vendorName,@"company",
                              nil];
        
        [appInfoArr addObject:appDic];
    }
    
    return appInfoArr;
}

-(NSMutableDictionary *)getDeviceInfo
{
    NSString *devName=[[UIDevice currentDevice] name];
    NSString *devModel=[[UIDevice currentDevice] model];
    NSString *sysName=[[UIDevice currentDevice] systemName];
    NSString *sysVer=[[UIDevice currentDevice] systemVersion];
    NSString *devLocalModel=[[UIDevice currentDevice] localizedModel];
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *devPlatform=[self doDevicePlatform];
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSString *mCarrier = [NSString stringWithFormat:@"%@",[carrier carrierName]];
    NSString *mConnectType = [[NSString alloc] initWithFormat:@"%@",info.currentRadioAccessTechnology];
    
    NSMutableDictionary *devDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 devName,@"devName",
                                 devModel,@"devModel",
                                 sysName,@"sysName",
                                 sysVer,@"sysVer",
                                 devLocalModel,@"devLocalModel",
                                 uuid,@"uuid",
                                 devPlatform,@"devPlatform",
                                 mCarrier,@"mCarrier",
                                 mConnectType,@"mConnectType",
                                 nil];
    return devDic;
}

- (NSString*) doDevicePlatform
{
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return platform;
}

- (UIViewController *)viewControllerWithView:(UIView *)view {
    /// Finds the view's view controller.
    
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    // If the view controller isn't found, return nil.
    return nil;
}


//提示框
+ (void)alert:(NSString *)message
{
    [[PHDeviceHelper sharedHelper] showErrorMessage:message];
}

-(void)showErrorMessage:(NSString *)message
{
    CGFloat alertHeight = 64;
    
    if (_alertWindow) {
        [_alertWindow removeFromSuperview];
        _alertWindow=nil;
    }
    _alertWindow = [[WarningItem alloc] initWithFrame:CGRectMake(0, -alertHeight, [[UIScreen mainScreen] bounds].size.width, alertHeight) message:message];
    _alertWindow.hidden = YES;
    [((AppDelegate *)[UIApplication sharedApplication].delegate).window addSubview:_alertWindow];
    
    [UIView animateWithDuration:.2 animations:^{
        _alertWindow.hidden = NO;
        _alertWindow.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, alertHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 delay:1.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _alertWindow.frame = CGRectMake(0, -alertHeight, [[UIScreen mainScreen] bounds].size.width, alertHeight);
        } completion:^(BOOL finished){
            _alertWindow.hidden = YES;
            [_alertWindow removeFromSuperview];
            _alertWindow = nil;
        }];
    }];
}


//身份证校验
+ (BOOL)validateIDCardNumber:(NSString *)value {
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSUInteger length =0;
    
    if (!value) {
        return NO;
    }else {
        length = value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41",@"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    
    BOOL areaFlag =NO;
    
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        return NO;
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;

    switch (length) {
            
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;

            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
                
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
                
            }
            
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
        
            if(numberofMatch >0) {
                return YES;
            }else {
                return NO;
            }
            
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
        
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
                
            }else {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$" options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
                
            }

            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                              options:NSMatchingReportProgress
                                                                range:NSMakeRange(0, value.length)];
            if(numberofMatch >0) {
                
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                int Y = S %11;
                
                NSString *M =@"F";
                
                NSString *JYM =@"10X98765432";
                
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    
                    return YES;// 检测ID的校验位
                    
                }else {
                    return NO;
                }
            }else {
                return NO;
            }
        default:
            return NO;
    }
}


//检查更新
+(void)checkUpdateFinished:(void (^)())finishedcb isDirectly:(BOOL)isDirect
{
    [[PHDeviceHelper sharedHelper] checkUpdateFinished:finishedcb isDirectly:isDirect];
}

#pragma mark - Fake data

+(NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

-(void)saveTaskDataWithID:(NSString *)appId andType:(NSNumber *)taskType succeed:(void(^)(NSString *dateStr,NSString *signNum, NSInteger status))succeedcb
{
    NSDictionary *userDic=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *uid=userDic[@"id"];
    
    NSString *taskUrl=UPLOAD_TASK_URL;
    NSMutableDictionary *parameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     uid,@"uid",
                                     appId,@"app_id",
                                     [NSNumber numberWithInt:2],@"type",
                                     taskType,@"task_type",
                                     nil];
    
    [[NetworkRequest sharedNetWorkRequest] retrieveJsonWithURLRequest:taskUrl parameters:parameters success:^(NSDictionary *json) {
        NSLog(@"%@",json);
        if ([json[@"errcode"] integerValue]==0 && succeedcb) {
            NSDictionary *dic=json[@"data"];
            NSString *date=dic[@"app_open_date"];
            NSString *num=dic[@"sign_num"];
            NSInteger status=[dic[@"state"] integerValue];
            succeedcb(date,num,status);
        }
        else{
            [PHDeviceHelper alert:@"数据更新失败,请稍后再试!"];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        [PHDeviceHelper alert:@"数据更新失败,请稍后再试!"];
    }];
}

-(void)checkUpdateFinished:(void (^)())finishedcb isDirectly:(BOOL)isDirect
{
    __block NSDictionary* dict;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dict = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:UPDATE_URL]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dict) {
                if (finishedcb) {
                    finishedcb();
                }
                NSArray* list = [dict objectForKey:@"items"];
                NSDictionary* dict2 = [list objectAtIndex:0];
                
                NSDictionary* dict3 = [dict2 objectForKey:@"metadata"];
                NSString* newVersion = [dict3 objectForKey:@"bundle-version"];
                
                NSString *myVersion = LOCVERSION;
                
                if (![newVersion isEqualToString:myVersion]) {
                    _updateAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到新版本，请前往更新。" delegate:self cancelButtonTitle:@"更新" otherButtonTitles:nil, nil];
                    [_updateAlert show];
                }
                else{
                    if (!isDirect) {
                        UIAlertView * aler = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前已是最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [aler show];
                    }
                }
                
            }
            else{
                if (finishedcb) {
                    finishedcb();
                }
                if (!isDirect) {
                    [PHDeviceHelper alert:@"网络不给力，请稍后再试"];
                }
            }
        });
    });
}


-(BOOL)checkVarify
{
    NSDictionary *userDict=[[NSUserDefaults standardUserDefaults] objectForKey:USER_DATA];
    NSString *verify=userDict[@"verify_state"];
    if ([verify integerValue]==1) {
        return YES;
    }
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"您的帐号正在审核中，请等待审核通过后再执行任务。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
    return NO;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView==_updateAlert) {
        if (buttonIndex==0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:DOWN_URL]];
        }
    }
}

@end
