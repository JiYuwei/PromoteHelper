//
//  DataBase.m
//  Campus Life
//
//  Created by xy on 14-7-10.
//  Copyright (c) 2014年 HP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBase.h"
//#import "CampusLifeConstants.h"

static DataBase *database;

@interface DataBase()
@property (assign, nonatomic) BOOL closed;
@end

@implementation DataBase

+ (DataBase *)getDatabase
{
    if (database)
        return database;
    
    static dispatch_once_t predict;
    
    dispatch_once(&predict,^{
        database = [[self alloc] init];
    });
    
    database.closed = true;
    
    return database;
}

- (NSString *)databaseFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *directory = [paths objectAtIndex:0];
    
    return [directory stringByAppendingPathComponent:@"cache.sqlite"];
}

- (void)open
{
    int ret = sqlite3_open([[self databaseFilePath] UTF8String], &database);
    
    if (ret != SQLITE_OK)
    {
        sqlite3_close(database);
        
//        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:[[PlistManger instanceManger].theamPlist objectForKey:@"Error"] message:[[[PlistManger instanceManger].theamPlist objectForKey:@"AlertItems"] objectForKey:@"databaseAlert"] delegate:self cancelButtonTitle:[[PlistManger instanceManger].theamPlist objectForKey:@"OK"] otherButtonTitles: nil];
//        
//        [alertView show];
        
        return;
    }
    
    char *cacheTable = "CREATE TABLE IF NOT EXISTS CACHE_TABLE(REQUEST_KEY TEXT PRIMARY KEY, REQUEST_RESULT TEXT NOT NULL, RESULT_TYPE TEXT NOT NULL, LAST_USE_TIME INTEGER NOT NULL);";
    
    char *errorMsg;
    if (sqlite3_exec(database, cacheTable, NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        
//        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:[[PlistManger instanceManger].theamPlist objectForKey:@"Error"] message:[NSString stringWithUTF8String:errorMsg] delegate:self cancelButtonTitle:[[PlistManger instanceManger].theamPlist objectForKey:@"OK"] otherButtonTitles: nil];
//        
//        [alertView show];
    }
    
    _closed = false;
}

- (void)close
{
    _closed = true;
    sqlite3_close(database);
}

- (NSDictionary *)getFromCache:(NSString *)requestKey
{
    if (_closed)
        [self open];
    
    NSDictionary *result = nil;
    char *sql = "SELECT REQUEST_RESULT FROM CACHE_TABLE WHERE REQUEST_KEY=?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [requestKey UTF8String], -1, NULL);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *ch = (char *)sqlite3_column_text(statement, 0);
            
            NSString *json = [NSString stringWithUTF8String:ch];
            
            result = [DataBase jsonStr2NSDictionary:json];
            
            [self refreshLastUseTime:requestKey];
        }
        sqlite3_finalize(statement);
    }
    
    return result;
}

- (void)putToCache:(NSString *)requestKey jsonData:(NSData *)jsonVal
{
    [self putToCache:requestKey cacheStr:[[NSString alloc] initWithData:jsonVal encoding:NSUTF8StringEncoding]cacheType:CACHE_JSON_TYPE];
}

- (void)putToCache:(NSString *)requestKey cacheStr:(NSString *)cacheStr  cacheType:(NSString *)cacheType
{
    if (_closed)
        [self open];
    
    char *sql = "INSERT OR REPLACE INTO CACHE_TABLE(REQUEST_KEY, REQUEST_RESULT, RESULT_TYPE, LAST_USE_TIME) VALUES(?, ?, ?, ?);";
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [requestKey UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 2, [cacheStr UTF8String], -1, NULL);
        sqlite3_bind_text(statement, 3, [cacheType UTF8String], -1, NULL);
        sqlite3_bind_int64(statement, 4, [[NSDate date] timeIntervalSince1970]);
    }
    
    if (sqlite3_step(statement) != SQLITE_DONE)
        NSLog(@"%@", @"Insert DB ERROR");
    
    sqlite3_finalize(statement);
}

- (void)refreshLastUseTime:(NSString *)requestKey
{
    if (_closed)
        [self open];
    
    @synchronized(self)
    {
        char *sql = "UPDATE CACHE_TABLE SET LAST_USE_TIME=? WHERE REQUEST_KEY=?;";
        sqlite3_stmt *statement;
    
        if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, [[NSDate date] timeIntervalSince1970]);
            sqlite3_bind_text(statement, 2, [requestKey UTF8String], -1, NULL);
        }
    
        int result = sqlite3_step(statement);
        if (result != SQLITE_DONE)
            NSLog(@"%@", @"UPDATE DB ERROR");
    
        sqlite3_finalize(statement);
    }
}

- (NSMutableArray *)queryOldestCacheItems:(int)limit cacheType:(NSString *)cacheType
{
    if (_closed)
        [self open];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    char *sql = "SELECT REQUEST_KEY, REQUEST_RESULT, LAST_USE_TIME FROM (SELECT * FROM CACHE_TABLE WHERE RESULT_TYPE = ? ORDER BY LAST_USE_TIME) LIMIT ?";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [cacheType UTF8String], -1, NULL);
        sqlite3_bind_int(statement, 2, limit);
        
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            NSString *requestKey = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            //NSString *requestResult = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
            NSNumber *lastUseTime = [NSNumber numberWithInt:sqlite3_column_int(statement, 2)];
            
            NSDictionary *row = [NSDictionary dictionaryWithObjectsAndKeys:requestKey, @"REQUEST_KEY", lastUseTime, @"LAST_USE_TIME", nil];
            
            [result addObject:row];
        }
        sqlite3_finalize(statement);
    }
    
    return result;
}

- (void)removeFromCache:(NSString *)requestKey
{
    if (_closed)
        [self open];
    
    char *sql = "DELETE FROM CACHE_TABLE WHERE REQUEST_KEY=?;";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(statement, 1, [requestKey UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(statement) != SQLITE_DONE)
        NSLog(@"%@", @"DELETE DB ERROR");
    
    sqlite3_finalize(statement);
}

- (void)constraintDBSize
{
    if (_closed)
        [self open];
    
    char *sql0 = "SELECT COUNT(*) AS 'RECORDS_COUNT' FROM CACHE_TABLE WHERE RESULT_TYPE=?";
    char *sql1 = "DELETE FROM CACHE_TABLE WHERE REQUEST_KEY IN (SELECT REQUEST_KEY FROM CACHE_TABLE WHERE RESULT_TYPE=? ORDER BY LAST_USE_TIME LIMIT ?);";
    
    sqlite3_stmt *statement;
    while (true)
    {
        int recordsCount = 0;
        
        if (sqlite3_prepare_v2(database, sql0, -1, &statement, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [CACHE_JSON_TYPE UTF8String], -1, NULL);
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                recordsCount = sqlite3_column_int(statement, 0);
            }
        }
        
        if (recordsCount < DB_JSON_MAX_RECORD * 2 / 3)
            break;
        
        if (sqlite3_prepare_v2(database, sql1, -1, &statement, nil) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [CACHE_JSON_TYPE UTF8String], -1, NULL);
            sqlite3_bind_int(statement, 2, CACHE_QUERY_LIMIT);
        }
        
        if (sqlite3_step(statement) != SQLITE_DONE)
            NSLog(@"%@", @"DELETE DB ERROR");
        
        sqlite3_finalize(statement);
    }
    
    sqlite3_finalize(statement);
}

+ (NSDictionary *)jsonData2NSDictionary:(NSData *)jsonData
{
    NSError *error = nil;
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error != nil)
    {
        if (jsonData == nil)
        {
            NSLog(@"%@", [error debugDescription]);
        }
        else
        {
            NSLog(@"%@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
        }
        return nil;
    }
    
    return jsonObject;
}

+ (NSDictionary *)jsonStr2NSDictionary:(NSString *)json
{
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    return [DataBase jsonData2NSDictionary:jsonData];
}

@end
