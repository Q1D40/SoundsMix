//
//  AllSoundsController.h
//  SoundsMix
//
//  Created by yang mu on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlService.h"

@interface AllSoundsController : UIViewController {
    // sqlite
    sqlService *sqlite;
    // 所有音效总滚动列表
    IBOutlet UIScrollView *allSoundsScrollView;
}

// 画Navigation
- (void)drawNavigation;
// 返回主界面
- (void)backMain;
// 点击导航条返回主界面
- (void)backMainFromNav:(id)sender;
// 画一个分类标题
- (void)drawOneTypeWithTitle:(NSString*)title andWithX:(float)x andWithY:(float)y;
// 画所有音效列表
- (void)drawAllSoundsList;
// 画一行音效背景
- (void)drawOneRowSoundBackWithX:(float)x andWithY:(float)y;
// 画一个音效
- (void)drawOneSoundWithX:(float)x andWithY:(float)y andId:(NSString*)iid andFid:(NSString*)fid andCname:(NSString*)cname andEname:(NSString*)ename Favorites:(BOOL)ifFavorites;
// 选择一个音效
- (void)selectOneSound:(UIGestureRecognizer *)sender;
// 从收藏选择一个音效
- (void)selectOneSoundFromFavorites:(UIGestureRecognizer *)sender;

@end
