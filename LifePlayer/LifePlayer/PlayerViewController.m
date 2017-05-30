//
//  PlayerViewController.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerBarView.h"
#import "TopBarView.h"
#import "AppDelegate.h"
#import <Masonry.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <Bulb.h>

@implementation BulbVideoOverSignal

@end

@interface PlayerViewController () <VLCMediaPlayerDelegate>

@property (nonatomic, copy) NSString* path;
@property (nonatomic) VLCMediaPlayer* player;
@property (nonatomic) PlayerBarView* playerBarView;
@property (nonatomic) TopBarView* topBarView;
@property (nonatomic) BOOL toolBarIsVisible;
@property (nonatomic) NSTimer* timer;

@end

@implementation PlayerViewController

- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.path = path;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    VLCMediaPlayer *player = [[VLCMediaPlayer alloc] initWithOptions:nil];
    self.player = player;
    player.drawable = self.view;
    player.media = [VLCMedia mediaWithPath:self.path];
    player.delegate = self;
    self.playerBarView = [[PlayerBarView alloc] init];
    self.playerBarView.alpha = 0;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolBarShortTime)];
    [player.drawable addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.playerBarView];
    [self.playerBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    self.topBarView = [[TopBarView alloc] init];
    self.topBarView.alpha = 0;
    
    [self.view addSubview:self.topBarView];
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@40);
        make.top.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    __weak typeof(self) weakSelf = self;
    [[Bulb bulbGlobal] registerSignal:[BulbChangeTimeSignal signalDefault].on block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if (weakSelf) {
            weakSelf.player.time = [VLCTime timeWithInt:[firstData intValue]];
            
            [weakSelf.timer invalidate];
            weakSelf.timer = nil;
            
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [weakSelf hideToolBar];
            }];
            
            return YES;
        } else {
            return NO;
        }
    }];
    
    [[Bulb bulbGlobal] registerSignal:[BulbTopBarViewDissmissSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if (weakSelf) {
            [weakSelf.player stop];
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            return YES;
        } else {
            return NO;
        }
    }];
    
    [[Bulb bulbGlobal] registerSignal:[BulbPlayOrPauseSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if (weakSelf) {
            NSNumber* isPlay = firstData;
            if ([isPlay boolValue]) {
                [weakSelf play];
            } else {
                [weakSelf pause];
            }
            
            [weakSelf.timer invalidate];
            weakSelf.timer = nil;
            
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [weakSelf hideToolBar];
            }];
            
            return YES;
        } else {
            return NO;
        }
    }];
    
    // 快进与快退
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fast:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(fast:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.player.drawable addGestureRecognizer:rightSwipe];
    [self.player.drawable addGestureRecognizer:leftSwipe];
}

- (void)fast:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.player shortJumpBackward];
    } else {
        [self.player shortJumpForward];
    }
}

- (void)play
{
    if ([self.player isPlaying]) {
        return ;
    }
    [self.player play];
}

- (void)pause
{
    if (![self.player isPlaying]) {
        return ;
    }
    [self.player pause];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self play];
}

- (void)showToolBarShortTime
{
    if (self.toolBarIsVisible) {
        [self hideToolBar];
        return ;
    }
    
    [self.view bringSubviewToFront:self.playerBarView];
    [self.view bringSubviewToFront:self.topBarView];
    [UIView animateWithDuration:0.5 animations:^{
        self.playerBarView.alpha = 1;
        self.topBarView.alpha = 1;
        self.toolBarIsVisible = YES;
    }];
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self hideToolBar];
    }];
}

- (void)hideToolBar
{
    [UIView animateWithDuration:0.5 animations:^{
        self.playerBarView.alpha = 0;
        self.topBarView.alpha = 0;
        self.toolBarIsVisible = NO;
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showToolBarShortTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma marks VLC delegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    if (self.player.state == VLCMediaPlayerStateStopped) {
        [[Bulb bulbGlobal] fire:[BulbVideoOverSignal signalDefault] data:nil];
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    if (self.playerBarView.totalMillisecondes <= 1) {
        [self.playerBarView setTotalMillisecondes:-self.player.remainingTime.value.integerValue + self.player.time.value.integerValue];
    } else {
        [self.playerBarView setMillisecondes:self.player.time.value.integerValue];
    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end
