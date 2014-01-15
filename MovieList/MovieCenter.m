//
//  MovieCenter.m
//  MovieList
//
//  Created by T on 2014. 1. 14..
//  Copyright (c) 2014년 T. All rights reserved.
//

#import "MovieCenter.h"
#import <sqlite3.h>

@implementation MovieCenter
{
    sqlite3 *db;
    NSMutableArray *_movieList;
}

static MovieCenter *_instance = nil;


+ (id)sharedMovieCenter
{
    if (nil == _instance) {
        _instance = [[MovieCenter alloc] init];
        [_instance openDB];
    }
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
- (BOOL)openDB {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbFilePath = [docPath stringByAppendingPathComponent:@"db.sqlite"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL existFile = [fm fileExistsAtPath:dbFilePath];
    
    int ret = sqlite3_open([dbFilePath UTF8String], &db);
    
    if (SQLITE_OK != ret) {
        return NO;
    }
    
    if (existFile == NO) {
        char *creatSQL = "CREATE TABLE IF NOT EXISTS MOVIE (TITLE TEXT)";
        char *errorMsg;
        ret = sqlite3_exec(db, creatSQL, NULL, NULL, &errorMsg);
        if (SQLITE_OK != ret) {
            [fm removeItemAtPath:dbFilePath error:nil];
            NSLog(@"creating table with ret : %d", ret);
            return NO;
        }
        
        creatSQL = "CREATE TABLE IF NOT EXISTS ACTOR (MOVIE_ID INT, NAME TEXT)";
        ret = sqlite3_exec(db, creatSQL, NULL, NULL, &errorMsg);
        if (SQLITE_OK != ret) {
            [fm removeItemAtPath:dbFilePath error:nil];
            NSLog(@"creating table with ret : %d", ret);
            return NO;
        }
    }
    return YES;
}

- (NSInteger)addMovieWithName:(NSString *)name {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO MOVIE (TITLE) VALUES ('%@')", name];
    NSLog(@"sql : %@", sql);
    
    char *errMsg;
    int ret = sqlite3_exec(db, [sql UTF8String], NULL, nil, &errMsg);
    
    if (SQLITE_OK != ret) {
        NSLog(@"Error on Insert New data : %s", errMsg);
    }
    NSInteger movieID = (NSInteger)sqlite3_last_insert_rowid(db);
    return movieID;
}

// DB 작업 모두 여기서 한다
- (NSInteger)getNumberOfMovies {
    return _movieList.count;
}

- (void)fetchMovies {
    _movieList = [[NSMutableArray alloc] init];
    NSString *queryStr = @"SELECT rowid, title FROM MOVIE";
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &stmt, NULL);
    
    NSAssert2(SQLITE_OK == ret, @"Error(%d) on resolving data : %s", ret,sqlite3_errmsg(db));
    NSString *titleString;
    while (SQLITE_ROW == sqlite3_step(stmt)) {
        char *title = (char *)sqlite3_column_text(stmt, 1);
        titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        [_movieList addObject:titleString];
    }
    sqlite3_finalize(stmt);
}

- (NSString *)getNameOfMovieAtIndex:(NSInteger)index {
    return _movieList[index];
}

- (NSInteger)getNumberOfActorsInMovie:(NSInteger)movieIndex {
    NSString *queryStr = [NSString stringWithFormat:@"SELECT count(rowid)  FROM ACTOR where MOVIE_ID=%d", movieIndex];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &stmt, NULL);
    
    NSAssert2(SQLITE_OK == ret, @"Error(%d) on resolving data : %s", ret,sqlite3_errmsg(db));
    
    NSInteger count;
    while (SQLITE_ROW == sqlite3_step(stmt)) {
        count = sqlite3_column_int(stmt, 0);
    }
    
    sqlite3_finalize(stmt);
    return count;
}

- (NSString *)getNameOfActorAtIndex:(NSInteger)index inMovie:(NSInteger)movieIndex {
    NSString *queryStr = [NSString stringWithFormat:@"SELECT rowid, name FROM ACTOR where MOVIE_ID=%d limit %d, 1", movieIndex, (int)index];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &stmt, NULL);
    
    NSAssert2(SQLITE_OK == ret, @"Error(%d) on resolving data : %s", ret,sqlite3_errmsg(db));
    
    NSString *titleString;
    while (SQLITE_ROW == sqlite3_step(stmt)) {
        char *title = (char *)sqlite3_column_text(stmt, 1);
        titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        
    }
    
    sqlite3_finalize(stmt);
    return titleString;
}

- (NSInteger)addActorWithName:(NSString *)name inMovie:(NSInteger)movieIndex{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO ACTOR (NAME, MOVIE_ID) VALUES ('%@', %d)", name, movieIndex];
    NSLog(@"sql : %@", sql);
    
    char *errMsg;
    int ret = sqlite3_exec(db, [sql UTF8String], NULL, nil, &errMsg);
    
    if (SQLITE_OK != ret) {
        NSLog(@"Error on Insert New data : %s", errMsg);
    }
    NSInteger movieID = (NSInteger)sqlite3_last_insert_rowid(db);
    return movieID;
}

- (NSString *)getNameOfMovieAtId:(NSInteger)rowId {
    NSString *queryStr = [NSString stringWithFormat:@"SELECT rowid, title FROM MOVIE where rowid=%d", (int)rowId];
    sqlite3_stmt *stmt;
    int ret = sqlite3_prepare_v2(db, [queryStr UTF8String], -1, &stmt, NULL);
    
    NSAssert2(SQLITE_OK == ret, @"Error(%d) on resolving data : %s", ret,sqlite3_errmsg(db));
    NSString *titleString;
    while (SQLITE_ROW == sqlite3_step(stmt)) {
        char *title = (char *)sqlite3_column_text(stmt, 1);
        titleString = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
    }
    
    sqlite3_finalize(stmt);
    return titleString;
}

@end
