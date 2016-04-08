//
//  AllSoundsController.m
//  SoundsMix
//
//  Created by yang mu on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AllSoundsController.h"
#import <QuartzCore/QuartzCore.h>

@implementation AllSoundsController

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
    
    // 画Navigation
    [self drawNavigation];
    // 画所有音效列表
    [self drawAllSoundsList];
}

// 画所有音效列表
- (void)drawAllSoundsList
{
    // 获取分类
    NSMutableArray *typeArray = [[NSMutableArray alloc]init];
    typeArray = [sqlite getSoundType];
    
    // 布局Y坐标
    float drawY = 0;
    
    // 读取收藏数据
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSData *favoritesSoundsDate = [mainUserDefaults valueForKey:@"favoritesSounds"];
    NSMutableDictionary *favoritesSounds = [[NSKeyedUnarchiver unarchiveObjectWithData:favoritesSoundsDate] mutableCopy];
    if ([favoritesSounds count] > 0) {
        // 收藏标题
        [self drawOneTypeWithTitle:@"Favorites" andWithX:0 andWithY:drawY];
        drawY += 33;
        
        // 收藏小图标
        int iii = 0;
        for(NSString *tempKey in favoritesSounds) {
            if (iii % 4 == 0) {
                [self drawOneRowSoundBackWithX:0 andWithY:drawY];
                drawY += 75;
            }
            NSString *soundId = [[NSString alloc] init];
            NSString *soundFid = [[NSString alloc] init];
            NSString *soundCname = [[NSString alloc] init];
            NSString *soundEname = [[NSString alloc] init];
            soundId = [[favoritesSounds objectForKey:tempKey] objectForKey:@"id"];
            soundFid = [[favoritesSounds objectForKey:tempKey] objectForKey:@"fid"];
            soundCname = [[favoritesSounds objectForKey:tempKey] objectForKey:@"cname"];
            soundEname = [[favoritesSounds objectForKey:tempKey] objectForKey:@"ename"];
            // 画一个音效
            [self drawOneSoundWithX:((iii % 4) * (75 + 4) + 4) andWithY:(drawY - 63 - 6) andId:soundId andFid:soundFid andCname:soundCname andEname:soundEname Favorites:YES];
            iii++;
        }
    }
    
    // 分类标题
    for (int i=0; i<[typeArray count]; i++) {
        NSString *typeTitle = [[NSString alloc] init];
        NSString *typeId = [[NSString alloc] init];
        typeTitle = [[typeArray objectAtIndex:i] objectForKey:@"ename"];
        typeId = [[typeArray objectAtIndex:i] objectForKey:@"id"];
        [self drawOneTypeWithTitle:typeTitle andWithX:0 andWithY:drawY];
        drawY += 33;
        
        // 获取分类音效
        NSMutableArray *soundArray = [[NSMutableArray alloc]init];
        soundArray = [sqlite getSoundWithType:typeId];
        // 音效图标
        for (int ii=0; ii<[soundArray count]; ii++) {
            if (ii % 4 == 0) {
                [self drawOneRowSoundBackWithX:0 andWithY:drawY];
                drawY += 75;
            }
            NSString *soundId = [[NSString alloc] init];
            NSString *soundFid = [[NSString alloc] init];
            NSString *soundCname = [[NSString alloc] init];
            NSString *soundEname = [[NSString alloc] init];
            soundId = [[soundArray objectAtIndex:ii] objectForKey:@"id"];
            soundFid = [[soundArray objectAtIndex:ii] objectForKey:@"fid"];
            soundCname = [[soundArray objectAtIndex:ii] objectForKey:@"cname"];
            soundEname = [[soundArray objectAtIndex:ii] objectForKey:@"ename"];
            // 画一个音效
            [self drawOneSoundWithX:((ii % 4) * (75 + 4) + 4) andWithY:(drawY - 63 - 6) andId:soundId andFid:soundFid andCname:soundCname andEname:soundEname Favorites:NO];
        }
    }
    
    // 顶部填充
    UIImage *topImage = [UIImage imageNamed: @"滚动超出背景.png"];
    UIImageView *topImageView = [[UIImageView alloc] initWithImage: topImage]; 
    [topImageView setFrame:CGRectMake(0, -250, 320, 250)];
    [allSoundsScrollView addSubview:topImageView];
    
    // 底部填充
    // 底部填充Y坐标
    float buttomY = drawY;
    for (int i=0; i<4; i++) {
        [self drawOneRowSoundBackWithX:0 andWithY:buttomY];
        buttomY += 75;
    }
    
    // 设置allSoundsScrollView的Content高度
    [allSoundsScrollView setContentSize:CGSizeMake(320, drawY)];
    
    // navigation下阴影
    UIImage *navigationShadowImage = [UIImage imageNamed: @"title下阴影.png"];
    UIImageView *navigationShadowImageView = [[UIImageView alloc] initWithImage: navigationShadowImage]; 
    [navigationShadowImageView setFrame:CGRectMake(0, 0, 320, 3)];
    [self.view addSubview:navigationShadowImageView];
}

// 画一个音效
- (void)drawOneSoundWithX:(float)x andWithY:(float)y andId:(NSString*)iid andFid:(NSString*)fid andCname:(NSString*)cname andEname:(NSString*)ename Favorites:(BOOL)ifFavorites
{
    // 音效小图
    NSString *soundSmallImageFileName = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@小图.png", cname]];
    UIImageView *soundSmallImageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:soundSmallImageFileName]];
    [soundSmallImageView setFrame:CGRectMake(x, y, 75, 63)];
    [soundSmallImageView setTag:[iid intValue]];
    // 设置允许触摸
    [soundSmallImageView setUserInteractionEnabled:YES];
    // 设置触摸事件
    UITapGestureRecognizer *onSoundSmallImageView;
    if (ifFavorites == YES) {
        onSoundSmallImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectOneSoundFromFavorites:)];
    }else{
        onSoundSmallImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectOneSound:)];
    }
    [soundSmallImageView addGestureRecognizer:onSoundSmallImageView];
    [allSoundsScrollView addSubview:soundSmallImageView];
    
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

// 从收藏选择一个音效
- (void)selectOneSoundFromFavorites:(UIGestureRecognizer *)sender
{
    // 获取选择id
    UIImageView *oneSoundImageView = (UIImageView *)[sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
    
    NSInteger iid = oneSoundImageView.tag;
    NSString *selectOneId = [NSString stringWithFormat: @"%d", iid];
    // 存储选择id
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    [mainUserDefaults setObject:selectOneId forKey:@"mainSelectOneId"];
    // 存储是否选择标识为已经选择
    NSString *ifSelectOneSound = [[NSString alloc] init];
    ifSelectOneSound = @"1";
    [mainUserDefaults setObject:ifSelectOneSound forKey:@"mainIfSelectOneSound"];
    // 暂停标识
    NSString *ifSingleAudioPlayerPause = [[NSString alloc] init];
    ifSingleAudioPlayerPause = @"0";
    // 存储单音效暂停标识
    [mainUserDefaults setObject:ifSingleAudioPlayerPause forKey:@"ifSingleAudioPlayerPause"];
    // 存储选择收藏标识
    [mainUserDefaults setObject:@"1" forKey:@"mainSelectOneIdFromFavorites"];
    // 返回主屏
    [self backMain];
}

// 选择一个音效
- (void)selectOneSound:(UIGestureRecognizer *)sender
{
    // 获取选择id
    UIImageView *oneSoundImageView = (UIImageView *)[sender.view hitTest:[sender locationInView:sender.view] withEvent:nil];
    
    NSInteger iid = oneSoundImageView.tag;
    NSString *selectOneId = [NSString stringWithFormat: @"%d", iid];
    // 存储选择id
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    [mainUserDefaults setObject:selectOneId forKey:@"mainSelectOneId"];
    // 存储是否选择标识为已经选择
    NSString *ifSelectOneSound = [[NSString alloc] init];
    ifSelectOneSound = @"1";
    [mainUserDefaults setObject:ifSelectOneSound forKey:@"mainIfSelectOneSound"];
    // 暂停标识
    NSString *ifSingleAudioPlayerPause = [[NSString alloc] init];
    ifSingleAudioPlayerPause = @"0";
    // 存储单音效暂停标识
    [mainUserDefaults setObject:ifSingleAudioPlayerPause forKey:@"ifSingleAudioPlayerPause"];
    // 存储选择收藏标识
    [mainUserDefaults setObject:@"0" forKey:@"mainSelectOneIdFromFavorites"];
    // 返回主屏
    [self backMain];
}

// 画一行音效背景
- (void)drawOneRowSoundBackWithX:(float)x andWithY:(float)y
{
    // 背景
    UIImage *oneRowSoundBackImage = [UIImage imageNamed: @"声音列表中的图片背景.png"];
    UIImageView *oneRowSoundBackImageView = [[UIImageView alloc] initWithImage: oneRowSoundBackImage]; 
    [oneRowSoundBackImageView setFrame:CGRectMake(x, y, 320, 75)];
    [allSoundsScrollView addSubview:oneRowSoundBackImageView];
}

// 画一个分类标题
- (void)drawOneTypeWithTitle:(NSString*)title andWithX:(float)x andWithY:(float)y;
{
    // 背景
    UIImage *typeTitleImage = [UIImage imageNamed: @"声音列表中的分类标题背景.png"];
    UIImageView *typeTitleImageView = [[UIImageView alloc] initWithImage: typeTitleImage]; 
    [typeTitleImageView setFrame:CGRectMake(x, y, 320, 33)];
    [allSoundsScrollView addSubview:typeTitleImageView];
    
    // 文字
    UILabel *typeTitleLabe = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 310, 24)];
    [typeTitleLabe setText:title];
    [typeTitleLabe setBackgroundColor:[UIColor clearColor]];
    [typeTitleLabe setTextColor:[UIColor whiteColor]];
    [typeTitleLabe setFont:[UIFont fontWithName:@"Hiragino Kaku Gothic ProN" size:16]];
    [typeTitleImageView addSubview:typeTitleLabe];
}

// 返回主界面
- (void)backMain
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

// 点击导航条返回主界面
- (void)backMainFromNav:(id)sender
{
    // 存储是否选择标识为没有选择
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ifSelectOneSound = [[NSString alloc] init];
    ifSelectOneSound = @"0";
    [mainUserDefaults setObject:ifSelectOneSound forKey:@"mainIfSelectOneSound"];
    
    // 返回主界面
    [self backMain];
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
    
    // backButton创建
    // Button位置，Button图标，Button背景色，Button透明，View全局刷新关闭，追加Action事件
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
    // 首次打开判断
    NSUserDefaults *mainUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mainSelectOneId = [mainUserDefaults stringForKey:@"mainSelectOneId"];
    if (mainSelectOneId != nil) {
        [backButton setImage:[UIImage imageNamed:@"title返回按钮.png"] forState:UIControlStateNormal];
    }
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.opaque = NO;
    backButton.clearsContextBeforeDrawing = NO;
    [backButton addTarget:self action:@selector(backMainFromNav:) forControlEvents:UIControlEventTouchUpInside];
    // 创建NavigationController的LeftbarButton的Item并赋值
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithCustomView:backButton];   
    self.navigationItem.leftBarButtonItem = leftBtn;
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
