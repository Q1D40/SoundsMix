//
//  sqlService.m
//  SQLite3Test
//
//  Created by fengxiao on 11-11-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "sqlService.h"


@implementation sqlService

@synthesize _database;

- (id)init
{
	return self;
}

//获取document目录并返回数据库目录
- (NSString *)dataFilePath{	
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *sectionsInfoPath = [bundle pathForResource:@"SounDB" ofType:@"s3"];

	return sectionsInfoPath;
}

//创建，打开数据库
- (BOOL)openDB {
	//获取数据库路径
	NSString *path = [self dataFilePath];
	//文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断数据库是否存在
	BOOL find = [fileManager fileExistsAtPath:path];
	
	//如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
	if (find) {
		
		NSLog(@"Database file have already existed.");
		
		//打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
		//Objective-C)编写的，它不知道什么是NSString.
		if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
			
			//如果打开数据库失败则关闭数据库
			sqlite3_close(self._database);
			NSLog(@"Error: open database file.");
			return NO;
		}
		
		//创建一个新表
		//[self createTestList:self._database];
		
		return YES;
	}
	//如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
	if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
		
		//创建一个新表
		//[self createTestList:self._database];
		return YES;
    } else {
		//如果创建并打开数据库失败则关闭数据库
		sqlite3_close(self._database);
		NSLog(@"Error: open database file.");
		return NO;
    }
	return NO;
}

// 获取一个音效
- (NSMutableArray*)getSoundWithId:(NSString*)iid
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //判断数据库是否打开
	if ([self openDB]) {
		sqlite3_stmt *statement = nil;
		//sql语句
		char *sql = "SELECT id, fid, cname, ename FROM Sound  WHERE id = ?";
		
		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSLog(@"Error");
		}
		else {
	    	sqlite3_bind_text(statement, 1, [iid UTF8String], -1, SQLITE_TRANSIENT);
			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
			while (sqlite3_step(statement) == SQLITE_ROW) {
				char* strText1   = (char*)sqlite3_column_text(statement, 0);
                char* strText2   = (char*)sqlite3_column_text(statement, 1);
                char* strText3   = (char*)sqlite3_column_text(statement, 2);
                char* strText4   = (char*)sqlite3_column_text(statement, 3);
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setObject: [NSString stringWithUTF8String:strText1] forKey:@"id"];
                [dic setObject: [NSString stringWithUTF8String:strText2] forKey:@"fid"];
                [dic setObject: [NSString stringWithUTF8String:strText3] forKey:@"cname"];
                [dic setObject: [NSString stringWithUTF8String:strText4] forKey:@"ename"];
                [array addObject:dic];
			}
		}
		sqlite3_finalize(statement);
		sqlite3_close(_database);
	}
    return array;
}

// 获取音效分类
- (NSMutableArray*)getSoundType
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //判断数据库是否打开
	if ([self openDB]) {
		sqlite3_stmt *statement = nil;
		//sql语句
		char *sql = "SELECT id, ename FROM Sound  WHERE fid = 0";
		
		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSLog(@"Error");
		}
		else {
	    	sqlite3_bind_text(statement, 1, [@"" UTF8String], -1, SQLITE_TRANSIENT);
			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
			while (sqlite3_step(statement) == SQLITE_ROW) {
				char* strText1   = (char*)sqlite3_column_text(statement, 0);
                char* strText2   = (char*)sqlite3_column_text(statement, 1);
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setObject: [NSString stringWithUTF8String:strText1] forKey:@"id"];
                [dic setObject: [NSString stringWithUTF8String:strText2] forKey:@"ename"];
                [array addObject:dic];
			}
		}
		sqlite3_finalize(statement);
		sqlite3_close(_database);
	}
    return array;
}

// 按分类获取音效
- (NSMutableArray*)getSoundWithType:(NSString*)type
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //判断数据库是否打开
	if ([self openDB]) {
		sqlite3_stmt *statement = nil;
		//sql语句
		char *sql = "SELECT id, fid, cname, ename FROM Sound  WHERE fid = ?";
		
		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSLog(@"Error");
		}
		else {
	    	sqlite3_bind_text(statement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
			while (sqlite3_step(statement) == SQLITE_ROW) {
				char* strText1   = (char*)sqlite3_column_text(statement, 0);
                char* strText2   = (char*)sqlite3_column_text(statement, 1);
                char* strText3   = (char*)sqlite3_column_text(statement, 2);
                char* strText4   = (char*)sqlite3_column_text(statement, 3);
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                [dic setObject: [NSString stringWithUTF8String:strText1] forKey:@"id"];
                [dic setObject: [NSString stringWithUTF8String:strText2] forKey:@"fid"];
                [dic setObject: [NSString stringWithUTF8String:strText3] forKey:@"cname"];
                [dic setObject: [NSString stringWithUTF8String:strText4] forKey:@"ename"];
                [array addObject:dic];
			}
		}
		sqlite3_finalize(statement);
		sqlite3_close(_database);
	}
    return array;
}

@end

