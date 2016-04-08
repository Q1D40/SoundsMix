//
//  MainController.h
//  SoundsMix
//
//  Created by yang mu on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlService.h"
#import <AVFoundation/AVFoundation.h>

@interface MainController : UIViewController {
    // 音效大图
    IBOutlet UIImageView *soundBigImageView;
    // 收藏按钮
    IBOutlet UIImageView *soundFavorites;
    // 静音按钮
    IBOutlet UIImageView *soundMute;
    // 音效名称
    IBOutlet UILabel *soundNameLabel;
    // 同类音效列表
    IBOutlet UIScrollView *oneTypeSoundsScrollVIew;
    // sqlite
    sqlService *sqlite;
    // 单个音效播放器
    AVAudioPlayer *singleAudioPlayer;
    // 关于界面
    IBOutlet UIView *aboutView;
}

// 画Navigation
- (void)drawNavigation;
// 画音量调节
- (void)drawSoundSlider;
// 显示所有声音列表
- (void)showAllSounds:(id)sender;
// 画一类小图
- (void)drawTypeScroll;
// 画音效大图部分
- (void)drawSoundBigImage;
// 画音效小图部分
- (void)drawTypeSoundSmallImageWithReX:(BOOL)rex;
// 画一个音效小图
- (void)drawOneSoundSmallImageWithX:(float)x andWithY:(float)y andId:(NSString*)iid andFid:(NSString*)fid andCname:(NSString*)cname andEname:(NSString*)ename;
// 清除同类音效列表
- (void)cleanTypeScroll;
// 选择一个声音
- (void)selectOneSound:(UIGestureRecognizer *)sender;
// 点击大图
- (void)pushBigImage:(UIGestureRecognizer *)sender;
// 播放单个音效
- (void)playSingleSound;
// 单个音效播放暂停
- (void)singleSoundPlayPause;
// 锁屏播放显示画面
- (void)setMediaInfo:(UIImage *)img andTitle:(NSString *)title;
// 合成两张图片
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2;
// 单音效音量调节
- (void)singleSoundValueChanged:(id)sender;
// 单音效静音按钮初始化
- (void)soundMuteInit;
// 单音效静音操作
- (void)pushSoundMute:(UIGestureRecognizer *)sender;
// 画单音效静音按钮
- (void)drawSoundMute;
// 收藏按钮初始化
- (void)soundFavoritesInit;
// 收藏操作
- (void)pushSoundFavorites:(UIGestureRecognizer *)sender;
// 显示关于界面
- (IBAction)showAbout:(id)sender;
// 关闭关于界面
- (IBAction)closeAbout:(id)sender;
// 联系我们
- (IBAction)sendMail:(id)sender;
// 进入官网
- (IBAction)gotoWebsite:(id)sender;
// 给我评分
- (IBAction)doScoring:(id)sender;

@end
