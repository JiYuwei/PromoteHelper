//
//  DataBase.h
//  Campus Life
//
//  Created by xy on 14-7-10.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DataBase : NSObject
{
    sqlite3 *database;
}

- (void)open;
- (void)close;

+ (DataBase *)getDatabase;
+ (NSDictionary *)jsonData2NSDictionary:(NSData *)jsonData;
+ (NSDictionary *)jsonStr2NSDictionary:(NSString *)json;

- (id)getFromCache:(NSString *)requestKey;
- (void)putToCache:(NSString *)requestKey jsonData:(NSData *)jsonData;
- (void)putToCache:(NSString *)requestKey cacheStr:(NSString *)cacheStr cacheType:(NSString *)cacheType;

- (void)refreshLastUseTime:(NSString *)requestKey;
- (void)removeFromCache:(NSString *)requestKey;
- (NSMutableArray *)queryOldestCacheItems:(int)limit cacheType:(NSString *)cacheType;
- (void)constraintDBSize;

@end
