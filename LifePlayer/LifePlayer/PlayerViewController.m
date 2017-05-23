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
#import <Masonry.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <Bulb.h>

@interface PlayerViewController () <VLCMediaPlayerDelegate>

@property (nonatomic, copy) NSString* path;
@property (nonatomic) VLCMediaPlayer* player;
@property (nonatomic) PlayerBarView* playerBarView;
@property (nonatomic) TopBarView* topBarView;

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
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showplayerBarView:)];
    [player.drawable addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.playerBarView];
    [self.playerBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@35);
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    self.topBarView = [[TopBarView alloc] init];
    self.topBarView.alpha = 0;
    
    [self.view addSubview:self.topBarView];
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@35);
        make.top.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    __weak typeof(self) weakSelf = self;
    [[Bulb bulbGlobal] registerSignal:[BulbChangeTimeSignal signalDefault].on block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        if (weakSelf) {
            weakSelf.player.time = [VLCTime timeWithInt:[firstData intValue]];
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
}

- (void)showplayerBarView:(UITapGestureRecognizer *)gesture
{
    [self.view bringSubviewToFront:self.playerBarView];
    [self.view bringSubviewToFront:self.topBarView];
    [UIView animateWithDuration:0.5 animations:^{
        self.playerBarView.alpha = 1;
        self.topBarView.alpha = 1;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.playerBarView.alpha = 0;
            self.topBarView.alpha = 0;
        }];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.player play];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.playerBarView.alpha = 0;
            self.topBarView.alpha = 0;
        }];
    });
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:self.playerBarView];
    [self.view bringSubviewToFront:self.topBarView];
    [UIView animateWithDuration:0.5 animations:^{
        self.playerBarView.alpha = 1;
        self.topBarView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma marks VLC delegate
- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification
{
    if (self.playerBarView.totalSecondes <= 1) {
        [self.playerBarView setTotalSecondes:-self.player.remainingTime.value.integerValue];
    } else {
        [self.playerBarView setSecondes:self.player.time.value.integerValue];
    }
}

@end
