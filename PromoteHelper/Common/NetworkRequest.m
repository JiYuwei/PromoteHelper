//
//  NetworkImage.m
//  Campus Life
//
//  Created by xy on 14-7-4.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <objc/runtime.h>
#import "NetworkRequest.h"
//#import "AFNetworking.h"
//#import "CampusLifeHelper.h"
//#import "Reachability.h"
#import "DataBase.h"
//#import "WXLoginHelper.h"
//#import "AESenAndDe.h"
static NetworkRequest *sharedNetwork;
static BOOL networkReachable = YES;
static char kAFImageRequestOperationObjectKey;

@interface NetworkRequest()
@property (readwrite, nonatomic, strong, setter = af_setImageRequestOperation:) AFHTTPRequestOperation *af_imageRequestOperation;
//@property (strong, nonatomic) AFHTTPClient *httpClient;
@property(nonatomic, strong)AFHTTPRequestOperationManager *manager;

@end

@implementation NetworkRequest
//@dynamic af_imageRequestOperation;
+(NetworkRequest *)sharedNetWorkRequest
{
    if (sharedNetwork) {
        return sharedNetwork;
    }
    else
    {
        static dispatch_once_t p;
        dispatch_once(&p, ^{
            sharedNetwork = [[self alloc] init];
        });
        return sharedNetwork;
    }
    
}
-(instancetype)init
{
    if (self = [super init]) {
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        security.allowInvalidCertificates = YES;
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"shwilling" ofType:@"cer"];
        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        [security setValidatesDomainName:YES];
        [security setValidatesCertificateChain:NO];
        [security setPinnedCertificates:@[certData]];
        
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.requestSerializer.timeoutInterval = 60;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        _manager.securityPolicy = security;
    }
    return self;
}

- (AFHTTPRequestOperation *)af_imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFImageRequestOperationObjectKey);
}

- (void)af_setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelImageRequestOperation {
    [self.af_imageRequestOperation cancel];
    self.af_imageRequestOperation = nil;
}

+ (NSOperationQueue *)af_sharedImageRequestOperationQueue {
    static NSOperationQueue *_af_imageRequestOperationQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _af_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_af_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });
    
    return _af_imageRequestOperationQueue;
}

//- (UIImage *) scaledImage:(UIImage *)image scaleToSize:(CGSize)size
//{
//    CGSize imageSize = image.size;
//    
//    if (CGSizeEqualToSize(size, CGSizeZero) ||
//        CGSizeEqualToSize(size, imageSize))
//        return image;
//    
//    if (size.height == 0)
//        size.height =  size.width/ image.size.width * image.size.height;
//    
//    float scale = 1.0f;
//    if (size.width / size.height < imageSize.width / imageSize.height)
//        scale = size.height / imageSize.height;
//    else
//        scale = size.width / imageSize.width;
//    
//    imageSize.width *= scale;
//    imageSize.height *= scale;
//    
//    CGRect scaleRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
//    UIImage *scaledImage = [CampusLifeHelper scaleImage:image scaleRect:scaleRect];
//    
//    CGRect clipRect = CGRectMake(0, 0, size.width, size.height);
//    UIImage *clipImage = [CampusLifeHelper clipImage:scaledImage clipRect:clipRect];
//    
//    return clipImage;
//}
//
//-(void)retrieveImageWithURLRequest:(NSString *)urlString
//                       scaleToSize:(CGSize)size
//                           success:(void (^)(UIImage *image))success
//                           failure:(void (^)(NSError *error))failure
//{
//    if ([CampusLifeHelper isNull:urlString])
//        return;
//    
//    [self cancelImageRequestOperation];
//    
//    if (![[urlString lowercaseString] hasPrefix:@"http://"]&&![urlString hasPrefix:@"https://"])
//        urlString = [SERVER_IMG_URL stringByAppendingPathComponent:urlString];
//    
//    NSData *data = [self loadImageData:urlString];
//    if (data)
//    {
//        UIImage *image = [UIImage imageWithData:data];
//        
//        if (success)
//        {
//            success([self scaledImage:image scaleToSize:size]);
//        }
//        
//        return;
//    }
//    
//    NSURL *url = [NSURL URLWithString:urlString];
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
//    
//    NSLog(@"Retrieve Image from %@", urlString);
//    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc]initWithRequest:urlRequest];
//    [requestOperation setCompletionBlockWithSuccess:
//     ^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]])
//             self.af_imageRequestOperation = nil;
//         
//         //图片本地缓存
//         UIImage *saveImg = [UIImage imageWithData:responseObject];
//         [self saveImageToCacheDir:urlString image:saveImg];
//         
//         if (success)
//         {
//             success([self scaledImage:saveImg scaleToSize:size]);
//         }
//     }
//     
//                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
//     {
//         if ([[urlRequest URL] isEqual:[[self.af_imageRequestOperation request] URL]])
//             self.af_imageRequestOperation = nil;
//         
//         NSLog(@"ERROR: Retrieve from %@", urlString);
//         if (failure)
//             failure(error);
//     }
//     ];
//    
//    self.af_imageRequestOperation = requestOperation;
//    
//    [[[self class] af_sharedImageRequestOperationQueue] addOperation:self.af_imageRequestOperation];
//}
//
//-(void)retrieveImageWithURLRequest:(NSString *)urlString
//                           success:(void (^)(UIImage *image))success
//                           failure:(void (^)(NSError *error))failure
//{
//    [self retrieveImageWithURLRequest:urlString scaleToSize:CGSizeZero success:success failure:failure];
//}
//
//-(NSString* )pathInCacheDirectory
//{
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [cachePaths objectAtIndex:0];
//    
//    return [cachePath stringByAppendingPathComponent:CACHE_FILE_PATH];
//}
////创建缓存文件夹
//-(BOOL) createDirInCache
//{
//    NSString *cacheDir = [self pathInCacheDirectory];
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:cacheDir isDirectory:&isDir];
//    BOOL isCreated = NO;
//    if (!(isDir == YES && existed == YES))
//        isCreated = [fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
//    if (existed)
//        isCreated = YES;
//    
//    return isCreated;
//}
//
//// 删除图片缓存
//- (BOOL) deleteDirInCache
//{
//    NSString *imageDir = [self pathInCacheDirectory];
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
//    bool isDeleted = false;
//    if (isDir == YES && existed == YES)
//        isDeleted = [fileManager removeItemAtPath:imageDir error:nil];
//    
//    return isDeleted;
//}
//
//- (BOOL)saveImageToCacheDir:(NSString *)urlString image:(UIImage *)image
//{
//    if ([self createDirInCache])
//    {
//        return [self saveImageToCacheDir:[self pathInCacheDirectory] image: image imageName:[urlString md5]];
//    }
//    
//    return false;
//}
//
//// 图片本地缓存
//- (BOOL) saveImageToCacheDir:(NSString *)directoryPath  image:(UIImage *)image imageName:(NSString *)imageName
//{
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
//    bool isSaved = false;
//    if (isDir == YES && existed == YES)
//    {
//        NSString *fileName = [directoryPath stringByAppendingPathComponent:imageName];
//        
//        isSaved = [UIImagePNGRepresentation(image) writeToFile:fileName options:NSAtomicWrite error:nil];
//        
//        if (isSaved)
//            [[DataBase getDatabase] putToCache:imageName cacheStr:imageName cacheType:CACHE_IMAGE_TYPE];
//    }
//    
//    return isSaved;
//}
//
//// 获取缓存图片
//-(NSData*) loadImageData:(NSString *)urlString
//{
//    NSString *directoryPath = [self pathInCacheDirectory];
//    NSString *imageName = [urlString md5];
//    
//    BOOL isDir = NO;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
//    if (isDir == YES && dirExisted == YES)
//    {
//        
//        NSString *fileName = [directoryPath stringByAppendingPathComponent:imageName];
//        
//        BOOL fileExisted = [fileManager fileExistsAtPath:fileName];
//        if (!fileExisted)
//            return NULL;
//        
//        //NSLog(@"Cache Read File :%@", fileName);
//        
//        NSData *imageData = [NSData dataWithContentsOfFile : fileName];
//        
//        [[DataBase getDatabase] refreshLastUseTime:imageName];
//        
//        return imageData;
//    }
//    else
//    {
//        return NULL;
//    }
//}
//
//- (long long) fileSizeAtPath:(NSString *)filePath
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    if ([fileManager fileExistsAtPath:filePath])
//        return [[fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
//    
//    return 0;
//}
//
//- (float)folderSizeAtPath:(NSString *)folderPath
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    if (![fileManager fileExistsAtPath:folderPath])
//        return 0;
//    
//    NSEnumerator *files = [[fileManager subpathsAtPath:folderPath] objectEnumerator];
//    NSString *fileName;
//    long long folderSize = 0;
//    
//    while ((fileName = [files nextObject]) != nil)
//    {
//        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//    }
//    
//    return folderSize / (1024.0 * 1024.0);
//}
//
//- (float)getCacheDirSize
//{
//    NSString *cacheDir = [self pathInCacheDirectory];
//    
//    return [self folderSizeAtPath:cacheDir];
//}
//
//- (long long)removeCacheFile:(NSString *)fileName
//{
//    NSString *cacheDir = [self pathInCacheDirectory];
//    NSString *fileAbsolutePath = [cacheDir stringByAppendingPathComponent:fileName];
//    
//    long long fileSize = [self fileSizeAtPath:fileAbsolutePath];
//    
//    if (fileSize > 0)
//    {
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        
//        [fileManager removeItemAtPath:fileAbsolutePath error:nil];
//    }
//    
//    return fileSize;
//}
//
//- (BOOL)checkNetworkReachability
//{
//    Reachability *reachability = [Reachability reachabilityWithHostName:NETWORK_CONNECT_TEST_URL];
//    
//    if ([reachability currentReachabilityStatus] == NotReachable)
//    {
//        if (networkReachable)
//            [CampusLifeHelper alert:[[PlistManger instanceManger].theamPlist objectForKey:@"CheckNetconnect"]];
//        
//        return false;
//    }
//    
//    return true;
//}
//
+ (NSString *)generateRequestKey:(NSString *)requestUrl parameters:(NSDictionary *)parameters
{
    NSArray *paramNames = [parameters allKeys];
    NSArray *sortedParamNames = [paramNames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                 {
                                     return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
                                 }];
    
    requestUrl = [requestUrl stringByAppendingString:@"="];
    for (NSString *paramName in sortedParamNames)
    {
        requestUrl = [requestUrl stringByAppendingFormat:@"%@=%@", paramName, [parameters objectForKey:paramName]];
    }
    
    return [requestUrl md5];
}

-(id)retrieveJsonWithURLRequest:(NSString *)urlString parameters:(NSMutableDictionary *)parameters success:(requestSuccessBlock)success failure:(requestFailureBlock)failure
{
    if (!urlString)
        return nil;
//    NSArray *noCacheURLs = [CampusLifeHelper getNoCacheURLs];
//    BOOL needCache = ![noCacheURLs containsObject:urlString];
    BOOL needCache=YES;
    
    return [self retrieveJsonWithPrepare:nil finish:nil needCache:needCache requestType:HTTPRequestTypePost fromURL:urlString parmeters:parameters success:success failure:failure];
    //    return [self retrieveJsonWithURLRequest:urlString parameters:parameters needCache:needCache success:success failure:failure];
}

//-(void)uploadMutableImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(NSArray *)images isOriginal:(BOOL)original success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
//{
//    [self appendParameters:parameters withSchoolCode:YES];
//    
//    if (![[urlString lowercaseString] hasPrefix:@"http://"]&&![urlString hasPrefix:@"https://"])
//        urlString = [SERVER_URL_HTTP stringByAppendingPathComponent:urlString];
//    NSMutableDictionary *Md5Param = [self MD5Parameters:parameters];
//
//    NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:Md5Param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        if (images.count>0) {
//            int i = 0;
//            for(UIImage *image in images)
//            {
//                NSData *imageData = UIImageJPEGRepresentation(image, original?1.0:0.1);
//                //                                            NSString *name = [NSString stringWithFormat:@"im%d.jpg",i];
//                NSString *name = [NSString stringWithFormat:@"%d",i];
//                NSString *fileName = [NSString stringWithFormat:@"my%d.jpg",i];
//                
//                [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
//                i++;
//            }
//        }
//        
//    } error:nil];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Upload %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//        NSNumber *number=[NSNumber numberWithFloat:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
//        _progressCB(number);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
//        if (success)
//        {
//            success(json);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (failure)
//            failure(error);
//    }];
//    
//    [operation start];
//    
//}
//
//-(void)uploadMutableImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters banner:(UIImage *)banner image:(NSArray *)images success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
//{
//    [self appendParameters:parameters withSchoolCode:YES];
//    
//    if (![[urlString lowercaseString] hasPrefix:@"http://"]&&![urlString hasPrefix:@"https://"])
//        urlString = [SERVER_URL_HTTP stringByAppendingPathComponent:urlString];
//    
//    NSMutableDictionary *Md5Param = [self MD5Parameters:parameters];
//
//    NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:Md5Param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSData *imageData = UIImageJPEGRepresentation(banner, 0.8);
//        NSString *name = @"banner";
//        NSString *fileName = @"banner.jpg";
//        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpg"];
//        if (images.count>0) {
//            int i = 0;
//            for(UIImage *image in images)
//            {
//                NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
//                //NSString *name = [NSString stringWithFormat:@"im%d.jpg",i];
//                NSString *name = [NSString stringWithFormat:@"%d",i];
//                NSString *fileName = [NSString stringWithFormat:@"%d.jpg",i];
//                
//                [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpg"];
//                i++;
//            }
//        }
//        
//    } error:nil];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Upload %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
//        if (success)
//        {
//            success(json);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (failure)
//            failure(error);
//    }];
//    
//    [operation start];
//    
//}
//
- (void)uploadImage:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure
{
//    [self appendParameters:parameters withSchoolCode:YES];
    if (![[urlString lowercaseString] hasPrefix:@"http://"]&&![urlString hasPrefix:@"https://"])
        urlString = [BASE_URL stringByAppendingPathComponent:urlString];
    
//    NSMutableDictionary *Md5Param = [self MD5Parameters:parameters];
    NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
        NSString *name = parameters[@"name"];
        NSString *fileName = parameters[@"fileName"];
        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
    } error:nil];
        
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Upload %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        if (_progressCB) {
            NSNumber *number=[NSNumber numberWithFloat:(float)totalBytesWritten/(float)totalBytesExpectedToWrite];
            _progressCB(number);
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success)
        {
            NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
            success(json);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
            failure(error);
    }];
    
    [operation start];
}

#pragma mark - Testing

//-(void)uploadFile:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image voice:(NSURL *)voiceUrl success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure
//{
//    [self uploadFile:urlString parameters:parameters image:image backImage:nil voice:voiceUrl success:^(NSDictionary *json) {
//        success(json);
//    } failure:^(NSError *error) {
//        failure(error);
//    }];
//}
//
//- (void)uploadFile:(NSString *)urlString parameters:(NSMutableDictionary *)parameters image:(UIImage *)image backImage:(UIImage *)backImage voice:(NSURL *)voiceUrl success:(void (^)(NSDictionary *json))success failure:(void (^)(NSError *error))failure
//{
//    [self appendParameters:parameters withSchoolCode:YES];
//    if (![[urlString lowercaseString] hasPrefix:@"http://"]&&![urlString hasPrefix:@"https://"])
//        urlString = [SERVER_URL_HTTP stringByAppendingPathComponent:urlString];
//    NSMutableDictionary *Md5Param = [self MD5Parameters:parameters];
//
//    NSMutableURLRequest *request = [_manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:Md5Param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        NSData *imageData = UIImageJPEGRepresentation(image, 1);
//        NSString *name = @"pic";
//        NSString *fileName = @"image.jpg";
//        [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
//        
//        if (backImage) {
//            NSData *imageData=UIImageJPEGRepresentation(backImage, 1);
//            NSString *name=@"back_pic";
//            NSString *fileName=@"backImage.jpg";
//            [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"image/jpeg"];
//        }
//        
//        if (![CampusLifeHelper isNull:[voiceUrl description]]) {
//            [formData appendPartWithFileURL:voiceUrl name:@"voice" error:nil];
//        }
//        
//    } error:nil];
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        NSLog(@"Upload %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
//    }];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
//        if (success)
//        {
//            success(json);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        if (failure)
//            failure(error);
//    }];
//    
//    [operation start];
//}
//
//- (void)appendParameters:(NSMutableDictionary *)parameters withSchoolCode:(BOOL)schoolCode
//{
//    CampusLifeHelper *campusLifeHelper = [CampusLifeHelper getInstance];
//    
//    [parameters setObject:[CampusLifeHelper getDeviceId] forKey:@"deviceid"];
//    
//    if (campusLifeHelper.schoolCode != -1 && schoolCode)
//        [parameters setObject:[NSString stringWithFormat:@"%u", campusLifeHelper.schoolCode] forKey:JSON_SCHOOL_CODE];
//    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:JSON_DEVICE_TOKEN] != nil) {
//        NSData *device_token = [[NSUserDefaults standardUserDefaults] objectForKey:JSON_DEVICE_TOKEN];
//        NSString *devicetoken = [NSString stringWithFormat:@"%@",device_token];
//        [parameters setObject:devicetoken forKey:JSON_DEVICE_TOKEN];
//    }
//    else
//        [parameters setObject:@"0" forKey:JSON_DEVICE_TOKEN];
//
//    if (campusLifeHelper.appToken)
//    {
//        [parameters setObject:campusLifeHelper.appToken forKey:JSON_APP_TOKEN];
//        if (campusLifeHelper.userToken)
//            [parameters setObject:campusLifeHelper.userToken forKey:JSON_USER_TOKEN];
//    }
//    else
//    {
//        [self requestAppToken:^(NSString *json)
//         {
//             NSString * userName = [[NSUserDefaults standardUserDefaults] stringForKey:JSON_USER_NAME];
//             NSString * passwd = [[NSUserDefaults standardUserDefaults] stringForKey:JSON_USER_PASSWORD];
//             
//             if (userName == nil || passwd == nil)
//                 return;
//             
//             [self requestUserToken:userName password:passwd success:nil failure:nil];
//         } failure:nil];
//    }
//}
//
//- (void)requestAppToken:(void (^)(NSString *json))success
//                failure:(void (^)(NSError *error))failure
//{
//    CampusLifeHelper *instance = [CampusLifeHelper getInstance];
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    instance.appToken = [defaults stringForKey:JSON_APP_TOKEN];
//#ifdef ENGLISH
//    NSString *user = @"ios_en";
//#else
//    NSString *user = @"ios";
//#endif
//    
//    user = [AESenAndDe En_AESandBase64EnToString:user];
//    NSString *pwd = [AESenAndDe En_AESandBase64EnToString:@"123"];
//    
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:user, @"user", pwd, @"pwd", [CampusLifeHelper getDeviceId], @"deviceid", nil];
//    [self retrieveJsonWithURLRequest:API_TOKEN_URL parameters:parameters
//                             success:^(NSDictionary *json) {
//                                 if (json && [json[ERROR_CODE] integerValue] == 0) {
//                                     instance.appToken = [AESenAndDe De_Base64andAESDeToString:json[@"data"][@"token"]];
//                                     [defaults setObject:instance.appToken forKey:JSON_APP_TOKEN];
//#ifdef ENGLISH
//                                     [defaults setObject:json[JSON_JUMP] forKey:JSON_JUMP];
//                                     if ([json[JSON_JUMP] isEqualToString:@"1"]) {
//                                         [defaults setObject:json[UNIQUE_SCHOOL_INFO][JSON_SCHOOL_NAME] forKey:JSON_SCHOOL_NAME];
//                                         [defaults setObject:json[UNIQUE_SCHOOL_INFO][JSON_SCHOOL_NAME_EN] forKey:JSON_SCHOOL_NAME_EN];
//                                         [defaults setObject:json[UNIQUE_SCHOOL_INFO][@"school_id"] forKey:JSON_SCHOOL_CODE];
//                                     }
//#endif
//                                     [defaults synchronize];
//                                     
//                                     if (success)
//                                         success(instance.appToken);
//                                 }
//                                 
//                             } failure:^(NSError *error) {
//                                 if (failure)
//                                     failure(error);
//                             }];
//}

//-(void)requestUserToken:(NSString *)userName password:(NSString *)password success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure
//{
////    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:instance.appToken,JSON_APP_TOKEN, userName, JSON_USER_NAME, password, JSON_USER_PASSWORD,[[NSUserDefaults standardUserDefaults] objectForKey:JSON_DEVICE_TOKEN],JSON_DEVICE_TOKEN, nil];
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters setObject:@"1" forKey:@"type"];
//    NSString *user = [AESenAndDe En_AESandBase64EnToString:userName];
//    NSString *pwd = [AESenAndDe En_AESandBase64EnToString:password];
//    [parameters setObject:user forKey:JSON_USER_NAME];
//    [parameters setObject:pwd forKey:JSON_USER_PASSWORD];
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:JSON_DEVICE_TOKEN] != nil) {
//        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:JSON_DEVICE_TOKEN] forKey:JSON_DEVICE_TOKEN];
//    }
//    else
//        [parameters setObject:@"0" forKey:JSON_DEVICE_TOKEN];
//
//    if ([CampusLifeHelper getInstance].appToken) {
//        [parameters setObject:[CampusLifeHelper getInstance].appToken forKey:JSON_APP_TOKEN];
//    }
//    
//    [self retrieveJsonWithURLRequest:USER_LOGIN_URL parameters:parameters
//                             success:^(NSDictionary *json) {
//                                 if (success)
//                                     success(json);
//                                 if ([json[ERROR_CODE] integerValue] == 0) {
//                                     NSDictionary *data = json[@"data"];
//                                     
//                                     if ([data[@"status"] integerValue]==1) {
//                                         return;
//                                     }
//                                     
//                                     NSString *token = [AESenAndDe De_Base64andAESDeToString:data[JSON_USER_LOIN_RET]];
//                                     [[NSUserDefaults standardUserDefaults] setObject:token forKey:JSON_USER_TOKEN];
//                                     if (token&&![token isEqualToString:@"fail"])
//                                     {
//                                         [CampusLifeHelper getInstance].userToken = token;
//                                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                                         [defaults setObject:[[data objectForKey:@"profile"]objectForKey:JSON_SCHOOL_NAME] forKey:JSON_SCHOOL_NAME];
//                                         if (![CampusLifeHelper isNull:[[data objectForKey:@"profile"]objectForKey:JSON_AUTHOR_GENDER]]) {
//                                             [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_AUTHOR_GENDER] forKey:JSON_AUTHOR_GENDER];
//                                         }
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_USER_CONSTELLATION] forKey:JSON_USER_CONSTELLATION];
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_SCHOOL_CODE] forKey:JSON_SCHOOL_CODE];
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_SCHOOL_ABBR] forKey:JSON_SCHOOL_ABBR];
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_AUTHOR_IMG_URL] forKey:JSON_AUTHOR_IMG_URL];
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_NICK_NAME] forKey:JSON_NICK_NAME];
//                                         [defaults setObject:[[data objectForKey:@"profile"] objectForKey:JSON_USER_CONSTELLATION] forKey:JSON_USER_CONSTELLATION];
//                                         
//                                         [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED_NOTIFICATION object:self userInfo:nil];
//                                     }
//                                 }
//
//                                
//                             } failure:^(NSError *error) {
//                                 if (failure)
//                                 {
//                                     NSLog(@"ERROR: retreive userToken");
//                                     failure(error);
//                                 }
//                                 
//                             }];
//}

- (NSMutableDictionary *)retrieveJsonWithPrepare:(prepareBlock)prepare finish:(finishBlock)finish needCache:(BOOL)needCache requestType:(HTTPRequestType)type fromURL:(NSString *)url parmeters:(NSMutableDictionary *)parmeters success:(requestSuccessBlock)success failure:(requestFailureBlock)failure
{
    if (prepare) {
        prepare();
    }
    if (!url)
        return nil;
//    NSString *requestKey = nil;
    NSMutableDictionary *json = nil;
    
//    if (needCache)
//    {
//        requestKey = [NetworkRequest generateRequestKey:url parameters:parmeters];
//        json = [[DataBase getDatabase] getFromCache:requestKey];
//    }
    
//    if (![url isEqualToString:API_TOKEN_URL])
//        [self appendParameters:parmeters withSchoolCode:YES];
    
    if (![url hasPrefix:@"http://"]&&![url hasPrefix:@"https://"])
    {
//        if ([[CampusLifeHelper httpsUrls] containsObject:url]) {
//            url = [SERVER_URL stringByAppendingPathComponent:url];
//        }
//        else
            url = [BASE_URL stringByAppendingPathComponent:url];
    }
    NSLog(@"urlstring = %@",url);

    if (!_manager) {
        AFSecurityPolicy *security = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        security.allowInvalidCertificates = YES;
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"shwilling" ofType:@"cer"];
        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        [security setValidatesDomainName:YES];
        [security setValidatesCertificateChain:NO];
        [security setPinnedCertificates:@[certData]];
        
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _manager.requestSerializer.timeoutInterval = 60;
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//        [_manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"utf-8"];

        _manager.securityPolicy = security;
    }
    
//    NSMutableDictionary *Md5Param = [self MD5Parameters:parmeters];
    
    switch (type) {
        case HTTPRequestTypePost:
        {
            [_manager POST:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
//                [self deailWithretrieveJsonSuccessOperation:operation responsObject:responseObject];
                NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
                if (json && needCache)
                {
                    NSString*requestKey = [NetworkRequest generateRequestKey:url parameters:parmeters];
                    [[DataBase getDatabase] putToCache:requestKey jsonData:responseObject];
                }
                if (success)
                    success(json);
                if (finish) {
                    finish();
                }

            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
//                if ([self checkNetworkReachability])
//                {
//                    if (networkReachable && ![[CampusLifeHelper netNoAlertUrls] containsObject:url])
//                        [CampusLifeHelper alert:[[PlistManger instanceManger].theamPlist objectForKey:@"FailedToConnect"]];
//                }
                
                networkReachable = NO;
                
                if (failure)
                    failure(error);
                if (finish) {
                    finish();
                }

            }];
        }
            break;
        case HTTPRequestTypeGet:{
            [_manager GET:url parameters:parmeters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
//                [self deailWithretrieveJsonSuccessOperation:operation responsObject:responseObject];
                NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
                if (json && needCache)
                {
                    NSString*requestKey = [NetworkRequest generateRequestKey:url parameters:parmeters];
                    [[DataBase getDatabase] putToCache:requestKey jsonData:responseObject];
                }
                if (success)
                    success(json);
                if (finish) {
                    finish();
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                if ([self checkNetworkReachability])
//                {
//                    if (networkReachable && ![[CampusLifeHelper netNoAlertUrls] containsObject:url])
//                        [CampusLifeHelper alert:[[PlistManger instanceManger].theamPlist objectForKey:@"FailedToConnect"]];
//                }
                
                networkReachable = NO;
                
                if (failure)
                    failure(error);
                if (finish) {
                    finish();
                }
            }];
            
        }
            break;
        case HTTPRequestTypePut:
            break;
            
        default:
            break;
    }
    
    return json;
}

/**
 @method MD5Parameters:
 @param  OldParamters
 @return md5(PARAS+签名+时间戳)
 */
//-(NSMutableDictionary *)MD5Parameters:(NSMutableDictionary *)paramters
//{
//    NSMutableDictionary *new_paramters = [NSMutableDictionary dictionaryWithDictionary:paramters];
//    
//    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
//    long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
//    NSString *curTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
//    
//    NSMutableArray *valuesArray = [NSMutableArray array];
//    for(NSString *key in [paramters allKeys])
//    {
//        [valuesArray addObject:key];
//    }
//    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
//    [valuesArray sortUsingDescriptors:[NSArray arrayWithObject:sd]];
//    
//    NSString *PARAS = [[NSString alloc] init];
//    for (int i = 0; i<valuesArray.count; i++) {
//        if (![paramters[valuesArray[i]] isKindOfClass:[NSString class]]) {
//            if ([paramters[valuesArray[i]] isKindOfClass:[NSArray class]] || [paramters[valuesArray[i]] isKindOfClass:[NSDictionary class]]) {
//                [paramters removeObjectForKey:valuesArray[i]];
//            }
//            else
//                PARAS = [PARAS stringByAppendingString:[NSString stringWithFormat:@"%@",paramters[valuesArray[i]]]];
//        }
//        else
//            PARAS = [PARAS stringByAppendingString:paramters[valuesArray[i]]];
//    }
//    PARAS = [PARAS stringByAppendingString:kSIGNKEY];
//    PARAS = [PARAS stringByAppendingString:curTime];
//    
//    NSString *MD5Str = [[PARAS md5] lowercaseString];
//    [new_paramters setObject:MD5Str forKey:SIGN_ATURE];
//
//    [new_paramters setObject:curTime forKey:TIMESTAMP];
//    
//    return new_paramters;
//}



//-(void)deailWithretrieveJsonSuccessOperation:(AFHTTPRequestOperation *)operation responsObject:(id)responseObject
//{
//    networkReachable = YES;
//    NSDictionary *json = [DataBase jsonData2NSDictionary:responseObject];
//
//    if ([json isKindOfClass:[NSDictionary class]])
//    {
//        if ([json[@"error_code"] intValue] == 10003) {
//            [self requestAppToken:^(NSString *json)
//             {} failure:nil];
//        }
//        else if([json[@"error_code"] intValue] == 10004 || [json[@"error_code"] intValue] == 10006)
//        {
//            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"logInType"] intValue]==5) {
//                WXLoginHelper *wxlog = [WXLoginHelper getWXLogin];
//                [wxlog retriveLoginItemsuccess:^(NSMutableDictionary *json) {
//                } failure:^(NSError *error) {
//                    
//                }];
//            }
//            else
//            {
//                NSString * userName = [[NSUserDefaults standardUserDefaults] stringForKey:JSON_USER_NAME];
//                NSString * passwd = [[NSUserDefaults standardUserDefaults] stringForKey:JSON_USER_PASSWORD];
//                
//                if (userName == nil || passwd == nil)
//                    return;
//                [self requestUserToken:userName password:passwd success:nil failure:nil];
//            }
//        }
//    }
//}

@end
