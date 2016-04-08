//
//  MainController.m
//  SoundsMix
//
//  Created by yang mu on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainController.h"
#import <QuartzCore/QuartzCore.h>
#import "AllSoundsController.h"
#import "ImageUtil.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation MainController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // 初始化sqlite
        sqlite = [[sqlService alloc]init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 首次打开判断
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    if (mainSelectOneId == nil) {
        // 设置初始音量
        float singleSoundValue = 1.0;
        [mainUserDefaults setFloat:singleSoundValue forKey:@"singleSoundValue"];
        
        // 初始化收藏数据
        NSMutableDictionary *favoritesSounds = [[NSMutableDictionary alloc] init];
        NSData *favoritesSoundsDateSave = [NSKeyedArchiver archivedDataWithRootObject:favoritesSounds];
        [mainUserDefaults setValue:favoritesSoundsDateSave forKey:@"favoritesSounds"];
    }
    
    // 画Navigation
    [self drawNavigation];
    // 画音量调节
    [self drawSoundSlider];
    // 画同类音效列表
    [self drawTypeScroll];
    // 单音效静音按钮初始化
    [self soundMuteInit];
    // 画单音效静音按钮
    [self drawSoundMute];
    // 收藏按钮初始化
    [self soundFavoritesInit];
}

-(void)viewWillAppear:(BOOL)animated 
{ 
    // 首次打开判断
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    // 获取是否选择了音效
    NSString *ifSelectOneSound = [mainUserDefaults stringForKey:@"mainIfSelectOneSound"];
    if (mainSelectOneId == nil) {
        // 首次打开跳入音效选择界面
        [self showAllSounds:nil];
    }else{
        // 如果选择了一个音效则刷新界面以及音效
        if ([ifSelectOneSound intValue] == 1) {
            // 画音效大图部分
            [self drawSoundBigImage];
            // 画音效小图部分
            [self drawTypeSoundSmallImageWithReX:YES];
        }else{
            // 设置是否选择判断标识为已经选择
            ifSelectOneSound = @"1";
            [mainUserDefaults setObject:ifSelectOneSound forKey:@"mainIfSelectOneSound"];
        }
    }
    
    // 双击Home下面的系统音乐控制
    [super viewWillAppear:animated];  
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];  
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated  
{  
    // 双击Home下面的系统音乐控制
    [super viewWillDisappear:animated];  
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];  
    [self resignFirstResponder];  
}

- (BOOL)canBecomeFirstResponder  
{  
    // 双击Home下面的系统音乐控制
    return YES;  
}

- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    // 双击Home下面的系统音乐控制
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        // 处理三个按钮的点击事件
        switch (receivedEvent.subtype) {  
            
            // 暂停播放按钮
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self singleSoundPlayPause];
                break;
            
            // 上一首
            case UIEventSubtypeRemoteControlPreviousTrack:
                break;
            
            // 下一首
            case UIEventSubtypeRemoteControlNextTrack:
                break;
                
            default:  
                break;
        }
    }
}

// 锁屏播放显示画面
- (void)setMediaInfo:(UIImage *)img andTitle:(NSString *)title
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        // 标题
        [dict setObject:title forKey:MPMediaItemPropertyAlbumTitle];
        // 海报
        // 背景图
        UIImage *soundBackImage;
        // 判断是否为Retina屏
        if (isRetina == 1) {
            soundBackImage = [UIImage imageNamed: @"锁屏@2x.png"];
        }else{
            soundBackImage = [UIImage imageNamed: @"锁屏.png"];
        }
        // 合成背景和音效大图
        UIImage *artImage = [self addImage:soundBackImage toImage:img];
        // 设置海报
        MPMediaItemArtwork * mArt = [[MPMediaItemArtwork alloc] initWithImage:artImage];
        [dict setObject:mArt forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

// 合成两张图片
- (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image1.size);
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    [image2 drawInRect:CGRectMake(0, (image1.size.height - image2.size.height), image2.size.width, image2.size.height)];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

// 播放单个音效
- (void)playSingleSound
{
    // 获取当前音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    // 获取一个音效
    NSMutableArray *oneSoundArray = [[NSMutableArray alloc]init];
    oneSoundArray = [sqlite getSoundWithId:mainSelectOneId];
    NSString *fileNamePre = [[NSString alloc] init];
    NSString *oneSoundCname = [[NSString alloc] init];
    NSString *oneSoundEname = [[NSString alloc] init];
    fileNamePre = @"%@/";
    oneSoundCname = [[oneSoundArray objectAtIndex:0] objectForKey:@"cname"];
    oneSoundEname = [[oneSoundArray objectAtIndex:0] objectForKey:@"ename"];
    // 音效文件名
    NSString *singleSoundFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@.caf", fileNamePre, oneSoundCname, oneSoundEname]];
    
    // 后台播放
    [[AVAudioSession sharedInstance] setDelegate: self];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    // 创建单个音效播放器
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:singleSoundFileName, [[NSBundle mainBundle] resourcePath]]];
    singleAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    singleAudioPlayer.numberOfLoops = -1;
    // 获取音量
    float singleSoundValue = [mainUserDefaults floatForKey:@"singleSoundValue"];
    // 静音限制
    NSString *singleSoundMute = [mainUserDefaults stringForKey:@"singleSoundMute"];
    if ([singleSoundMute intValue] != 1) {
        [singleAudioPlayer setVolume:singleSoundValue];
    }else{
        [singleAudioPlayer setVolume:0.0];
    }
    [singleAudioPlayer play];
    
    // 获取是否暂停标识
    NSString *ifSingleAudioPlayerPause = [mainUserDefaults stringForKey:@"ifSingleAudioPlayerPause"];
    // 判断是否暂停播放
    if ([ifSingleAudioPlayerPause intValue] == 1) {
        [singleAudioPlayer pause];
    }
}

// 画音效小图部分
- (void)drawTypeSoundSmallImageWithReX:(BOOL)rex
{
    // 清除同类音效列表
    [self cleanTypeScroll];
    
    // 获取选择音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    
    // 获取一个音效fid
    NSMutableArray *oneSoundArray = [[NSMutableArray alloc]init];
    oneSoundArray = [sqlite getSoundWithId:mainSelectOneId];
    NSString *oneSoundFid = [[NSString alloc] init];
    oneSoundFid = [[oneSoundArray objectAtIndex:0] objectForKey:@"fid"];
    
    // 获取同分类音效
    NSMutableArray *oneTypeSoundArray = [[NSMutableArray alloc]init];
    oneTypeSoundArray = [sqlite getSoundWithType:oneSoundFid];
    // 音效小图标
    // 布局X坐标
    float drawX = 0;
    // 滚动X坐标
    int scrollX = 0;
    
    // 读取收藏数据
    NSData *favoritesSoundsDate = [mainUserDefaults valueForKey:@"favoritesSounds"];
    NSMutableDictionary *favoritesSounds = [[NSKeyedUnarchiver unarchiveObjectWithData:favoritesSoundsDate] mutableCopy];
    // 读取是否从收藏选择标识
    NSString *mainSelectOneIdFromFavorites = [mainUserDefaults stringForKey:@"mainSelectOneIdFromFavorites"];
    // 判断显示分类图标还是收藏图标
    if ([mainSelectOneIdFromFavorites intValue] != 1) {
        // 分类小图标
        for (int i=0; i<[oneTypeSoundArray count]; i++) {
            NSString *soundId = [[NSString alloc] init];
            NSString *soundFid = [[NSString alloc] init];
            NSString *soundCname = [[NSString alloc] init];
            NSString *soundEname = [[NSString alloc] init];
            soundId = [[oneTypeSoundArray objectAtIndex:i] objectForKey:@"id"];
            soundFid = [[oneTypeSoundArray objectAtIndex:i] objectForKey:@"fid"];
            soundCname = [[oneTypeSoundArray objectAtIndex:i] objectForKey:@"cname"];
            soundEname = [[oneTypeSoundArray objectAtIndex:i] objectForKey:@"ename"];
            // 画一个音效
            [self drawOneSoundSmallImageWithX:(i * 80) andWithY:10 andId:soundId andFid:soundFid andCname:soundCname andEname:soundEname];
            drawX += 80;
            
            // 设置滚动位置
            if ([soundId intValue] == [mainSelectOneId intValue]) {
                scrollX = i * 80;
                // 最后一页滚动位置
                int lastPageN = [oneTypeSoundArray count] - 4;
                // 总数小于一屏情况
                if (lastPageN < 0) {
                    lastPageN = 0;
                }
                if (i > (lastPageN)) {
                    scrollX = lastPageN * 80;
                }
            }
        }
    }else{
        // 收藏小图标
        int iii = 0;
        for(NSString *tempKey in favoritesSounds) {
            NSString *soundId = [[NSString alloc] init];
            NSString *soundFid = [[NSString alloc] init];
            NSString *soundCname = [[NSString alloc] init];
            NSString *soundEname = [[NSString alloc] init];
            soundId = [[favoritesSounds objectForKey:tempKey] objectForKey:@"id"];
            soundFid = [[favoritesSounds objectForKey:tempKey] objectForKey:@"fid"];
            soundCname = [[favoritesSounds objectForKey:tempKey] objectForKey:@"cname"];
            soundEname = [[favoritesSounds objectForKey:tempKey] objectForKey:@"ename"];
            // 画一个音效
            [self drawOneSoundSmallImageWithX:(iii * 80) andWithY:10 andId:soundId andFid:soundFid andCname:soundCname andEname:soundEname];
            drawX += 80;
            
            // 设置滚动位置
            if ([soundId intValue] == [mainSelectOneId intValue]) {
                scrollX = iii * 80;
                // 最后一页滚动位置
                int lastPageN = [favoritesSounds count] - 4;
                // 总数小于一屏情况
                if (lastPageN < 0) {
                    lastPageN = 0;
                }
                if (iii > (lastPageN)) {
                    scrollX = lastPageN * 80;
                }
            }
            iii++;
        }
    }
    
    // 右部填充
    // 右部填充Y坐标
    float rightX = drawX;
    for (int i=0; i<4; i++) {
        // 背景
        UIImage *soundSmallBackImage = [UIImage imageNamed: @"首页滚动图片下背景.png"];
        UIImageView *soundSmallBackImageView = [[UIImageView alloc] initWithImage: soundSmallBackImage]; 
        [soundSmallBackImageView setFrame:CGRectMake((rightX + i * 80), 0, 80, 84)];
        [oneTypeSoundsScrollVIew addSubview:soundSmallBackImageView];
    }
    
    // 左部填充
    for (int i=1; i<5; i++) {
        // 背景
        UIImage *soundSmallBackImage = [UIImage imageNamed: @"首页滚动图片下背景.png"];
        UIImageView *soundSmallBackImageView = [[UIImageView alloc] initWithImage: soundSmallBackImage]; 
        [soundSmallBackImageView setFrame:CGRectMake(-(i * 80), 0, 80, 84)];
        [oneTypeSoundsScrollVIew addSubview:soundSmallBackImageView];
    }
    
    // 设置oneTypeSoundsScrollVIew的Content宽度
    [oneTypeSoundsScrollVIew setContentSize:CGSizeMake((drawX + 1), 84)];
    if (rex == YES) {
        //滚动到指定位置
        [oneTypeSoundsScrollVIew setContentOffset:CGPointMake(scrollX, 0)];
    }
    
    // 播放单个音效
    [self playSingleSound];
}

// 清除同类音效列表
- (void)cleanTypeScroll
{
    for (UIView *view in [oneTypeSoundsScrollVIew subviews])
    {
        [view removeFromSuperview];
    }
}

// 画一个音效小图
- (void)drawOneSoundSmallImageWithX:(float)x andWithY:(float)y andId:(NSString*)iid andFid:(NSString*)fid andCname:(NSString*)cname andEname:(NSString*)ename
{
    // 背景
    UIImage *soundSmallBackImage = [UIImage imageNamed: @"首页滚动图片下背景.png"];
    UIImageView *soundSmallBackImageView = [[UIImageView alloc] initWithImage: soundSmallBackImage]; 
    [soundSmallBackImageView setFrame:CGRectMake(x, 0, 80, 84)];
    [oneTypeSoundsScrollVIew addSubview:soundSmallBackImageView];
    
    // 获取选择音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    // 音效小图
    UIImageView *soundSmallImageView = [[UIImageView alloc] init];
    NSString *soundSmallImageFileName;
    // 判断选中
    if ([iid intValue] == [mainSelectOneId intValue]) {
        soundSmallImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@小图.png", cname]];
    }else{
        soundSmallImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@小图黑白.png", cname]];
    }
    [soundSmallImageView setImage:[UIImage imageNamed:soundSmallImageFileName]];
    [soundSmallImageView setFrame:CGRectMake((x + 2.5), (y + 2), 75, 63)];
    [soundSmallImageView setTag:[iid intValue]];
    // 设置允许触摸
    [soundSmallImageView setUserInteractionEnabled:YES];
    // 设置触摸事件
    UITapGestureRecognizer *onSoundSmallImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectOneSound:)];
    [soundSmallImageView addGestureRecognizer:onSoundSmallImageView];
    [oneTypeSoundsScrollVIew addSubview:soundSmallImageView];    
    
    // 音效小图标题背景
    UIImage *soundSmallTitleImage = [UIImage imageNamed: @"小标题背景.png"];
    UIImageView *soundSmallTitleImageView = [[UIImageView alloc] initWithImage: soundSmallTitleImage]; 
    [soundSmallTitleImageView setFrame:CGRectMake(0, 50, 75, 13)];
    [soundSmallImageView addSubview:soundSmallTitleImageView];
    
    // 音效小图标题
    UILabel *soundSmallTitleLabe = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 75, 16)];
    [soundSmallTitleLabe setText:ename];
    [soundSmallTitleLabe setBackgroundColor:[UIColor clearColor]];
    [soundSmallTitleLabe setTextColor:[UIColor whiteColor]];
    [soundSmallTitleLabe setFont:[UIFont fontWithName:@"Hiragino Kaku Gothic ProN" size:10]];
    soundSmallTitleLabe.textAlignment = UITextAlignmentCenter;
    [soundSmallImageView addSubview:soundSmallTitleLabe];
}

// 点击大图
- (void)pushBigImage:(UIGestureRecognizer *)sender
{
    // 获取当前音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    
    // 获取一个音效
    NSMutableArray *oneSoundArray = [[NSMutableArray alloc]init];
    oneSoundArray = [sqlite getSoundWithId:mainSelectOneId];
    NSString *oneSoundCname = [[NSString alloc] init];
    NSString *oneSoundEname = [[NSString alloc] init];
    oneSoundCname = [[oneSoundArray objectAtIndex:0] objectForKey:@"cname"];
    oneSoundEname = [[oneSoundArray objectAtIndex:0] objectForKey:@"ename"];
    
    // 设置音效大图
    NSString *soundBigImageFileName;
    // 判断是否为Retina屏
    if (isRetina == 1) {
        soundBigImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@大图@2x.png", oneSoundCname]];
    }else{
        soundBigImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@大图.png", oneSoundCname]];
    }
    // 获取是否暂停
    NSString *ifSingleAudioPlayerPause = [mainUserDefaults stringForKey:@"ifSingleAudioPlayerPause"];
    // 判断是否暂停改变图片颜色
    if ([ifSingleAudioPlayerPause intValue] == 0) {
        [singleAudioPlayer pause];
        ifSingleAudioPlayerPause = @"1";
        [soundBigImageView setImage:[ImageUtil blackWhite:[UIImage imageNamed:soundBigImageFileName]]];
    }else{
        // 获取音量
        float singleSoundValue = [mainUserDefaults floatForKey:@"singleSoundValue"];
        // 静音限制
        NSString *singleSoundMute = [mainUserDefaults stringForKey:@"singleSoundMute"];
        if ([singleSoundMute intValue] != 1) {
            [singleAudioPlayer setVolume:singleSoundValue];
        }
        [singleAudioPlayer play];
        ifSingleAudioPlayerPause = @"0";
        [soundBigImageView setImage:[UIImage imageNamed:soundBigImageFileName]];
        // 设置锁屏播放画面
        [self setMediaInfo:[UIImage imageNamed:soundBigImageFileName] andTitle:oneSoundEname];
    }
    // 存储单音效暂停标识
    [mainUserDefaults setObject:ifSingleAudioPlayerPause forKey:@"ifSingleAudioPlayerPause"];
}

// 单个音效播放暂停
- (void)singleSoundPlayPause
{
    // 实现点击大图效果
    [self pushBigImage:nil];
}

// 选择一个声音
- (void)selectOneSound:(UIGestureRecognizer *)sender
{
    // 获取选择id
    UIImageView *oneSoundImageView = (UIImageView *)[sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
    NSInteger iid = oneSoundImageView.tag;
    NSString *selectOneId = [NSString stringWithFormat: @"%d", iid];
    // 获取之前选择音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    // 判断选择
    if ([selectOneId intValue] != [mainSelectOneId intValue]) {
        // 暂停标识
        NSString *ifSingleAudioPlayerPause = [[NSString alloc] init];
        ifSingleAudioPlayerPause = @"0";
        // 存储单音效暂停标识
        [mainUserDefaults setObject:ifSingleAudioPlayerPause forKey:@"ifSingleAudioPlayerPause"];
        // 存储选择id
        [mainUserDefaults setObject:selectOneId forKey:@"mainSelectOneId"];
        // 画音效大图部分
        [self drawSoundBigImage];
        // 画音效小图部分
        [self drawTypeSoundSmallImageWithReX:NO];
    }
}

// 画音效大图部分
- (void)drawSoundBigImage;
{
    // 获取选择音效
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    
    // 获取一个音效
    NSMutableArray *oneSoundArray = [[NSMutableArray alloc]init];
    oneSoundArray = [sqlite getSoundWithId:mainSelectOneId];
    NSString *oneSoundId = [[NSString alloc] init];
    NSString *oneSoundFid = [[NSString alloc] init];
    NSString *oneSoundCname = [[NSString alloc] init];
    NSString *oneSoundEname = [[NSString alloc] init];
    oneSoundId = [[oneSoundArray objectAtIndex:0] objectForKey:@"id"];
    oneSoundFid = [[oneSoundArray objectAtIndex:0] objectForKey:@"fid"];
    oneSoundCname = [[oneSoundArray objectAtIndex:0] objectForKey:@"cname"];
    oneSoundEname = [[oneSoundArray objectAtIndex:0] objectForKey:@"ename"];
    
    // 设置音效大图
    NSString *soundBigImageFileName;
    // 判断是否为Retina屏
    if (isRetina == 1) {
        soundBigImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@大图@2x.png", oneSoundCname]];
    }else{
        soundBigImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@大图.png", oneSoundCname]];
    }
    // 获取是否暂停标识
    NSString *ifSingleAudioPlayerPause = [mainUserDefaults stringForKey:@"ifSingleAudioPlayerPause"];
    // 判断是否改变图片颜色
    if ([ifSingleAudioPlayerPause intValue] == 0) {
        [soundBigImageView setImage:[UIImage imageNamed:soundBigImageFileName]];
        // 设置锁屏画面
        [self setMediaInfo:[UIImage imageNamed:soundBigImageFileName] andTitle:oneSoundEname];
    }else{
        [soundBigImageView setImage:[ImageUtil blackWhite:[UIImage imageNamed:soundBigImageFileName]]];
    }
    // 设置允许触摸
    [soundBigImageView setUserInteractionEnabled:YES];
    // 设置触摸事件
    UITapGestureRecognizer *onSoundBigImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushBigImage:)];
    [soundBigImageView addGestureRecognizer:onSoundBigImageView];
    // 设置大图动画
    soundBigImageView.alpha = 0;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.5];
    soundBigImageView.alpha = 1.0;
    [UIView commitAnimations];
  
    // 设置音效名称
    [soundNameLabel setText:oneSoundEname];
    
    // 读取收藏数据
    NSData *favoritesSoundsDate = [mainUserDefaults valueForKey:@"favoritesSounds"];
    NSMutableDictionary *favoritesSounds = [[NSKeyedUnarchiver unarchiveObjectWithData:favoritesSoundsDate] mutableCopy];
    // 查找是否收藏
    NSString *favoritesOneSoundId = [[NSString alloc] init];
    favoritesOneSoundId = [favoritesSounds objectForKey:mainSelectOneId];
    // 判断显示收藏标志
    if (favoritesOneSoundId == nil) {
        [soundFavorites setImage:[UIImage imageNamed:@"加入收藏.png"]];
    }else{
        [soundFavorites setImage:[UIImage imageNamed:@"已加入收藏.png"]];
    }
}

// 画一类小图
- (void)drawTypeScroll
{
    // 同类音效小图
    [oneTypeSoundsScrollVIew setFrame:CGRectMake(0, 279, 320, 84)];
}

// 画音量调节
- (void)drawSoundSlider
{
    //左右轨的图片
    UIImage *stetchLeftTrack= [UIImage imageNamed:@"音量槽.png"];
    UIImage *stetchRightTrack = [UIImage imageNamed:@"音量槽.png"];
    //滑块图片
    UIImage *thumbImage = [UIImage imageNamed:@"音量滑块.png"];
    
    UISlider *soundSlider=[[UISlider alloc]initWithFrame:CGRectMake(24, 338, 218, 10)];
    soundSlider.backgroundColor = [UIColor clearColor];
    // 获取音量
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    float singleSoundValue = [mainUserDefaults floatForKey:@"singleSoundValue"];
    // 设置音量
    soundSlider.value=singleSoundValue;
    soundSlider.minimumValue=0.0;
    soundSlider.maximumValue=1.0;
    
    [soundSlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
    [soundSlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
    //注意这里要加UIControlStateHightlighted的状态，否则当拖动滑块时滑块将变成原生的控件
    [soundSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [soundSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    // 音量调节
    [soundSlider addTarget:self action:@selector(singleSoundValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:soundSlider];
}

// 单音效静音按钮初始化
- (void)soundMuteInit
{
    // 设置允许触摸
    [soundMute setUserInteractionEnabled:YES];
    // 设置触摸事件
    UITapGestureRecognizer *onsoundMute = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSoundMute:)];
    [soundMute addGestureRecognizer:onsoundMute];
}

// 收藏按钮初始化
- (void)soundFavoritesInit
{
    // 设置允许触摸
    [soundFavorites setUserInteractionEnabled:YES];
    // 设置触摸事件
    UITapGestureRecognizer *onSoundFavorites = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushSoundFavorites:)];
    [soundFavorites addGestureRecognizer:onSoundFavorites];
}

// 收藏操作
- (void)pushSoundFavorites:(UIGestureRecognizer *)sender
{
    // 读取收藏数据
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *favoritesSoundsDate = [mainUserDefaults valueForKey:@"favoritesSounds"];
    NSMutableDictionary *favoritesSounds = [[NSKeyedUnarchiver unarchiveObjectWithData:favoritesSoundsDate] mutableCopy];
    
    // 获取当前音效id
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    // 获取一个音效
    NSMutableArray *oneSoundArray = [[NSMutableArray alloc]init];
    oneSoundArray = [sqlite getSoundWithId:mainSelectOneId];
   
    // 查找是否收藏
    NSString *favoritesOneSoundId = [[NSString alloc] init];
    favoritesOneSoundId = [favoritesSounds objectForKey:mainSelectOneId];

    // 判断显示收藏标志
    if (favoritesOneSoundId == nil) {
        [favoritesSounds setObject:[oneSoundArray objectAtIndex:0] forKey:mainSelectOneId];
        [soundFavorites setImage:[UIImage imageNamed:@"已加入收藏.png"]];
    }else{
        [favoritesSounds removeObjectForKey:mainSelectOneId];
        [soundFavorites setImage:[UIImage imageNamed:@"加入收藏.png"]];
    }
    
    // 存储收藏数据
    NSData *favoritesSoundsDateSave = [NSKeyedArchiver archivedDataWithRootObject:favoritesSounds];
    [mainUserDefaults setValue:favoritesSoundsDateSave forKey:@"favoritesSounds"];
}

// 单音效静音操作
- (void)pushSoundMute:(UIGestureRecognizer *)sender
{
    // 获取当前静音标识
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *singleSoundMute = [mainUserDefaults stringForKey:@"singleSoundMute"];
    float singleSoundValue = [mainUserDefaults floatForKey:@"singleSoundValue"];
    
    // 单音效静音设置
    if ([singleSoundMute intValue] == 0) {
        singleSoundMute = @"1";
        [soundMute setImage:[UIImage imageNamed:@"静音状态.png"]];
        [singleAudioPlayer setVolume:0.0];
    }else{
        singleSoundMute = @"0";
        [soundMute setImage:[UIImage imageNamed:nil]];
        [singleAudioPlayer setVolume:singleSoundValue];
    }
    
    // 存储单音效静音标识
    [mainUserDefaults setObject:singleSoundMute forKey:@"singleSoundMute"];
}

// 画单音效静音按钮
- (void)drawSoundMute
{
    // 获取当前静音标识
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *singleSoundMute = [mainUserDefaults stringForKey:@"singleSoundMute"];
    
    // 设置单音效静音图片
    if ([singleSoundMute intValue] == 0) {
        [soundMute setImage:[UIImage imageNamed:nil]];
    }else{
        [soundMute setImage:[UIImage imageNamed:@"静音状态.png"]];
    }
}

// 单音效音量调节
- (void)singleSoundValueChanged:(id)sender
{
    // 设置音量
    UISlider *soundSlider = sender;
    
    // 静音限制
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *singleSoundMute = [mainUserDefaults stringForKey:@"singleSoundMute"];
    if ([singleSoundMute intValue] != 1) {
        [singleAudioPlayer setVolume:soundSlider.value];
    }
    
    // 存储单音效音量
    [mainUserDefaults setFloat:soundSlider.value forKey:@"singleSoundValue"];
}

// 显示所有声音列表
- (void)showAllSounds:(id)sender
{
    // 右侧推入
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    AllSoundsController *allSoundsController = [[AllSoundsController alloc] init];
    [self.navigationController pushViewController:allSoundsController animated:NO];
}

// 画Navigation
- (void)drawNavigation
{
    // Navigation背景
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title背景.png"] forBarMetrics:0];
    
    // Navigation中间logo
    UIImage *logoImage = [UIImage imageNamed: @"logo.png"];  
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage: logoImage]; 
    [logoImageView setFrame:CGRectMake(0, 0, 128, 23)];
    self.navigationItem.titleView = logoImageView;
    
    // mixButton创建
    // Button位置，Button图标，Button背景色，Button透明，View全局刷新关闭，追加Action事件
    //UIButton *mixButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    //[mixButton setImage:[UIImage imageNamed:@"title混音按钮.png"] forState:UIControlStateNormal];
    //[mixButton setBackgroundColor:[UIColor clearColor]];
    //mixButton.opaque = NO;
    //mixButton.clearsContextBeforeDrawing = NO;
    //[mixButton addTarget:self action:@selector(goTwoController:) forControlEvents:UIControlEventTouchUpInside];
    // 创建NavigationController的LeftbarButton的Item并赋值
    //UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:mixButton];   
    //self.navigationItem.leftBarButtonItem = leftBtn;
    
    // allSoundsButton创建
    // Button位置，Button图标，Button背景色，Button透明，View全局刷新关闭，追加Action事件
    UIButton *allSoundsButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 0, 50, 44)];
    [allSoundsButton setImage:[UIImage imageNamed:@"title列表按钮.png"] forState:UIControlStateNormal];
    [allSoundsButton setBackgroundColor:[UIColor clearColor]];
    allSoundsButton.opaque = NO;
    allSoundsButton.clearsContextBeforeDrawing = NO;
    [allSoundsButton addTarget:self action:@selector(showAllSounds:) forControlEvents:UIControlEventTouchUpInside];
    // 创建NavigationController的RightbarButton的Item并赋值
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:allSoundsButton];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

// 显示关于界面
- (IBAction)showAbout:(id)sender
{
    // 底部覆盖
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [aboutView setFrame:CGRectMake(0, 20, 320, 460)];
    [self.navigationController.view addSubview:aboutView];
}

// 关闭关于界面
- (IBAction)closeAbout:(id)sender
{
    // 顶部揭开
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [aboutView removeFromSuperview];
}

// 联系我们
- (IBAction)sendMail:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://yangmu373@gmail.com"]];
}

// 进入官网
- (IBAction)gotoWebsite:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.foul3.com"]];
}

// 给我评分
- (IBAction)doScoring:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=517183345"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
