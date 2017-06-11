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
#import <MediaPlayer/MediaPlayer.h>
#import <PINCache.h>

static NSString* kLastMovieCahce = @"kLastMovieCahce";

@implementation BulbVideoOverSignal

@end

@interface PlayerViewController () <VLCMediaPlayerDelegate>

@property (nonatomic, copy) NSString* path;
@property (nonatomic) VLCMediaPlayer* player;
@property (nonatomic) PlayerBarView* playerBarView;
@property (nonatomic) TopBarView* topBarView;
@property (nonatomic) BOOL toolBarIsVisible;
@property (nonatomic) NSTimer* timer;
@property (nonatomic) UISlider* volSlider;
@property (nonatomic, assign) BOOL landscapeRight;

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
    
    UITapGestureRecognizer* doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleGesture.numberOfTapsRequired = 2;
    [player.drawable addGestureRecognizer:doubleGesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolBarShortTime)];
    [tapGesture requireGestureRecognizerToFail:doubleGesture];
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
        make.top.equalTo(self.view).offset(15);
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
            [weakSelf dismissViewControllerAnimated:YES completion:firstData];
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
    
    [[Bulb bulbGlobal] registerSignal:[BulbTopBarViewRotateSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if (weakSelf) {
            [weakSelf rotate];
            return YES;
        } else {
            return NO;
        }
    }];
    
    // 快进与快退
    // 亮度与音量调节
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(vol:)];
    [self.player.drawable addGestureRecognizer:pan];
}

- (void)fast:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.player shortJumpBackward];
    } else {
        [self.player shortJumpForward];
    }
}

- (void)vol:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:pan.view];
    if (point.y > self.view.frame.size.height - 40) {
        return ;
    }
    
    CGPoint translation = [pan translationInView:self.view];
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    if (MAX(absX, absY) < 10)
        return;
    if (absX > absY ) {
        if (translation.x<0) {
            [self.player extraShortJumpBackward];
        }else{
            [self.player extraShortJumpForward];
        }
    } else if (absY > absX) {
        if (!self.volSlider) {
            MPVolumeView* volview = [[MPVolumeView alloc] init];
            for (UIView *view in [volview subviews]) {
                if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
                    self.volSlider = (UISlider *)view;
                    break;
                }
            }
        }
        if (self.volSlider) {
            
            if (point.x > self.view.center.x) {
                CGPoint velocity = [pan velocityInView:pan.view];
                CGFloat ratio = 13000.f;
                CGFloat nowVolumeValue = self.volSlider.value;
                float changeValue = (nowVolumeValue - velocity.y/ratio);
                [self.volSlider setValue:changeValue];
            } else {
                double currentLight = [[UIScreen mainScreen] brightness];
                CGPoint velocity = [pan velocityInView:pan.view];
                CGFloat ratio = 13000.f;
                float changeValue = (currentLight - velocity.y/ratio);
                [[UIScreen mainScreen] setBrightness:changeValue];
            }
        }
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)rotate
{
    if (self.landscapeRight) {
        [self forcePortrait];
    } else {
        [self forceLandscapeRight];
    }
}

- (void)forcePortrait
{
    self.landscapeRight = NO;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
}

- (void)forceLandscapeRight
{
    self.landscapeRight = YES;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.landscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.timer invalidate];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)showToolBarShortTime
{
    if (self.toolBarIsVisible) {
        [self hideToolBar];
        return ;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
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

- (void)doubleTap:(id)gesture
{
    [self.playerBarView playOrPause:nil];
}

- (void)hideToolBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
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

#pragma marks VLC delegate
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    if (self.playerBarView.totalMillisecondes <= 1) {
        [self.playerBarView setTotalMillisecondes:-self.player.remainingTime.value.integerValue + self.player.time.value.integerValue];
    } else {
        [self.playerBarView setMillisecondes:self.player.time.value.integerValue];
        
        // 记录播放
        [[[PINCache sharedCache] diskCache] setObject:@{@"path":self.path,
                                                        @"time":self.player.time.value} forKey:kLastMovieCahce];
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.toolBarIsVisible) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    }
}

@end
