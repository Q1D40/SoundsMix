//
//  sqlService.h
//  SQLite3Test
//
//  Created by fengxiao on 11-11-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kFilename  @"SounDB.s3"
@class sqlTestList;
@interface sqlService : NSObject {
	sqlite3 *_database;

}

@property (nonatomic) sqlite3 *_database;

// 获取音效分类
- (NSMutableArray*)getSoundType;
// 按分类获取音效
- (NSMutableArray*)getSoundWithType:(NSString*)type;
// 获取一个音效
- (NSMutableArray*)getSoundWithId:(NSString*)iid;

@end

