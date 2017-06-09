//
//  NetworkImage.h
//  Campus Life
//
//  Created by xy on 14-7-4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSInteger, HTTPRequestType) {
    HTTPRequestTypePost,
    HTTPRequestTypeGet,
    HTTPRequestTypePut,
};

typedef void(^prepareBlock)();
typedef void(^finishBlock)();
typedef void(^requestSuccessBlock) (NSDictionary *json);
typedef void(^requestFailureBlock) (NSError *error);


@interface NetworkRequest : NSObject

@property(nonatomic,copy) void(^progressCB)(NSNumber *);

+(NetworkRequest *)sharedNetWorkRequest;

//- (BOOL)saveImageToCacheDir:(NSString *)urlString image:(UIImage *)image;
//-(NSData*) loadImageData:(NSString *)urlString;
//
//-(void)retrieveImageWithURLRequest:(NSString *)urlString
//                           success:(void (^)(UIImage *image))success
//                           failure:(void (^)(NSError *error))failure;
//
//-(void)retrieveImageWithURLRequest:(NSString *)urlString
//                       scaleToSize:(CGSize)size
//                           success:(void (^)(UIImage *image))success
//                           failure:(void (^)(NSError *error))failure;
//
//-(void)uploadMutableImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(NSArray *)images isOriginal:(BOOL)original success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure;
//
//-(void)uploadMutableImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters banner:(UIImage *)banner image:(NSArray *)images success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError * error))failure;
//
- (void)uploadImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure;
//
//- (void)uploadFile:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image voice:(NSURL *)voiceUrl success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure;
//
//- (void)uploadFile:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image backImage:(UIImage *)backImage voice:(NSURL *)voiceUrl success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure;

- (id)retrieveJsonWithURLRequest:(NSString *)urlString parameters:(NSMutableDictionary *)parameters
                         success:(requestSuccessBlock)success
                         failure:(requestFailureBlock)failure;


- (void)requestAppToken:(void (^)(NSString *json))success
                failure:(void (^)(NSError *error))failure;

//- (void)requestUserToken:(NSString *)userName password:(NSString*)password success:(void (^)(NSDictionary *json))success
//                 failure:(void (^)(NSError *error))failure;

- (long long)removeCacheFile:(NSString *)fileName;
- (float)getCacheDirSize;
- (BOOL) deleteDirInCache;
/**
 改版新加方法 获取json类型数据
 @param prepare 网络数据交互前的准备工作回调
 @param finish 网络数据交互结束回调 成功或者失败都会执行
 @param type 请求类型 POST GET 等
 @param url  接口路径
 @param parmeters 请求上传参数
 @param success failure 请求成功失败回调
 @return 返回请求到的数据 或者缓存数据
 */

- (NSMutableDictionary *)retrieveJsonWithPrepare:(prepareBlock)prepare finish:(finishBlock)finish needCache:(BOOL)needCache requestType:(HTTPRequestType)type fromURL:(NSString *)url parmeters:(NSMutableDictionary *)parmeters success:(requestSuccessBlock)success failure:(requestFailureBlock)failure;


/**
 @method MD5Parameters:
 @param  OldParamters
 @return md5(PARAS+签名+时间戳)
 */
-(NSMutableDictionary *)MD5Parameters:(NSMutableDictionary *)paramters;

@end

@interface NSString (md5)
- (NSString *) md5;
@end

#import<CommonCrypto/CommonDigest.h>
@implementation NSString (md5)
- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr),result );
    NSMutableString *hash =[NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash uppercaseString];
}
@end

@interface UIImage (scale)
-(UIImage*)scaleToSize:(CGSize)size;
@end

@implementation UIImage (scale)
-(UIImage*)scaleToSize:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end
