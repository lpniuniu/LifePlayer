//
//  PlayerViewController.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "PlayerViewController.h"
#import "PlayerBarView.h"
#import <Masonry.h>
#import <MobileVLCKit/MobileVLCKit.h>
#import <Bulb.h>

@interface PlayerViewController () <VLCMediaPlayerDelegate>

@property (nonatomic, copy) NSString* path;
@property (nonatomic) VLCMediaPlayer* player;
@property (nonatomic) PlayerBarView* playerBarView;

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
    
    [self.view addSubview:self.playerBarView];
    [self.playerBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(@35);
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
    }];
    
    [[Bulb bulbGlobal] registerSignal:[BulbChangeTimeSignal signalDefault].on block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
        player.time = [VLCTime timeWithInt:[firstData intValue]];
        return YES;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.player play];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view bringSubviewToFront:self.playerBarView];
    [UIView animateWithDuration:0.5 animations:^{
        self.playerBarView.alpha = 1;
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
