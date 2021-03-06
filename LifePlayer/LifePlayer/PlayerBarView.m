//
//  PlayerBarView.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "PlayerBarView.h"
#import "PlayerSlider.h"
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import <Masonry.h>

@implementation BulbChangeTimeSignal

@end

@implementation BulbPlayOrPauseSignal

@end

@implementation BulbNextSignal

@end

@interface PlayerBarView ()

@property (nonatomic) PlayerSlider* slider;
@property (nonatomic) UILabel* startTimeLabel;
@property (nonatomic) UILabel* endTimeLabel;
@property (nonatomic) UIButton* playBtn;
@property (nonatomic) UIButton* nextBtn;
@property (nonatomic) BOOL isPlay;

@end

@implementation PlayerBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isPlay = YES;
        
        self.playBtn = [[UIButton alloc] init];
        [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
        [self.playBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 5, 5)];
        [self addSubview:self.playBtn];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self).offset(5);
            make.width.equalTo(@40);
        }];
        [self.playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        
        self.startTimeLabel = [[UILabel alloc] init];
        self.startTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.startTimeLabel setTextColor:[UIColor whiteColor]];
        [self.startTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.startTimeLabel];
        [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.playBtn.mas_right).offset(5);
            make.width.equalTo(@50);
        }];
        
        self.nextBtn = [[UIButton alloc] init];
        [self.nextBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [self.nextBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [self addSubview:self.nextBtn];
        [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self).offset(-5);
            make.width.equalTo(@40);
        }];
        [self.nextBtn addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
        
        self.endTimeLabel = [[UILabel alloc] init];
        self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.endTimeLabel setTextColor:[UIColor whiteColor]];
        [self.endTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.endTimeLabel];
        [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self.nextBtn.mas_left).offset(-5);
            make.width.equalTo(@50);
        }];
        
        self.slider = [[PlayerSlider alloc] init];
        [self addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.startTimeLabel.mas_right).offset(5);
            make.right.equalTo(self.endTimeLabel.mas_left).offset(-5);
        }];
        self.slider.minimumTrackTintColor = [UIColor whiteColor];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        __weak typeof(self) weakSelf = self;
        
        [[Bulb bulbGlobal] registerSignal:[BulbWillEnterForeground signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
            
            if (weakSelf) {
                if (!weakSelf.isPlay) {
                    [weakSelf playOrPause:nil];
                }
            } else {
                return NO;
            }
            
            return YES;
        }];
        
        [[Bulb bulbGlobal] registerSignal:[BulbDidBecomeActive signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
            
            if (weakSelf) {
                if (!weakSelf.isPlay) {
                    [weakSelf playOrPause:nil];
                }
            } else {
                return NO;
            }
            
            return YES;
        }];
        
        [[Bulb bulbGlobal] registerSignal:[BulbDidEnterBackground signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
            
            if (weakSelf) {
                if (weakSelf.isPlay) {
                    [weakSelf playOrPause:nil];
                }
            } else {
                return NO;
            }
            
            return YES;
        }];
        
        [[Bulb bulbGlobal] registerSignal:[BulbWillResignActiveSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
            
            if (weakSelf) {
                if (weakSelf.isPlay) {
                    [weakSelf playOrPause:nil];
                }
            } else {
                return NO;
            }
            
            return YES;
        }];
        
        [[Bulb bulbGlobal] registerSignal:[BulbVideoOverSignal signalDefault] block:^BOOL(id firstData, NSDictionary<NSString *,BulbSignal *> *signalIdentifier2Signal) {
            if (weakSelf) {
                if (weakSelf.isPlay) {
                    [weakSelf playOrPause:nil];
                }
            } else {
                return NO;
            }
            
            return YES;
        }];
    }
    return self;
}

- (void)playOrPause:(id)sender
{
    if (self.isPlay) {
        [self.playBtn setImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
        [self.playBtn setImageEdgeInsets:UIEdgeInsetsZero];
        self.isPlay = NO;
    } else {
        [self.playBtn setImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
        [self.playBtn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 5, 5)];
        self.isPlay = YES;
    }
    [[Bulb bulbGlobal] fire:[BulbPlayOrPauseSignal signalDefault] data:@(self.isPlay)];
}

- (void)next:(id)sender
{
    [[Bulb bulbGlobal] fire:[BulbNextSignal signalDefault] data:nil];
}

-(void)setTotalMillisecondes:(NSInteger)milliseconds
{
    self.slider.maximumValue = milliseconds;
    [self.endTimeLabel setText:[self getMMSSFromSS:milliseconds/1000]];
}

-(NSString *)getMMSSFromSS:(NSInteger)seconds{
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    return [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
}

- (void)setMillisecondes:(NSInteger)milliseconds
{
    self.slider.value = milliseconds;
    [self.startTimeLabel setText:[self getMMSSFromSS:milliseconds/1000]];
}

- (NSInteger)totalMillisecondes
{
    return self.slider.maximumValue;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [[Bulb bulbGlobal] fire:[BulbChangeTimeSignal signalDefault] data:@(slider.value)];
}

@end
