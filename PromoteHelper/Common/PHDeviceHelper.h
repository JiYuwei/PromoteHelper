//
//  PHDeviceHelper.h
//  PromoteHelper
//
//  Created by 纪宇伟 on 15/11/24.
//  Copyright © 2015年 willing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHDeviceHelper : NSObject

+(instancetype)sharedHelper;
+(void)alert:(NSString *)message;
+(BOOL)validateIDCardNumber:(NSString *)value;
+(NSDateFormatter *)dateFormatter;
+(void)checkUpdateFinished:(void(^)())finishedcb isDirectly:(BOOL)isDirect;

-(BOOL)checkVarify;
-(NSMutableArray *)getAllApps;
-(NSMutableDictionary *)getDeviceInfo;
-(NSMutableArray *)getAppsInfo;
-(UIViewController *)viewControllerWithView:(UIView *)view;
-(void)saveTaskDataWithID:(NSString *)appId andType:(NSNumber *)taskType succeed:(void(^)(NSString *dateStr,NSString *signNum, NSInteger status))succeedcb;

@end
