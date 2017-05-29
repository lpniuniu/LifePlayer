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
#import <Masonry.h>

@implementation BulbChangeTimeSignal

@end

@implementation BulbPlayOrPauseSignal


@end

@interface PlayerBarView ()

@property (nonatomic) PlayerSlider* slider;
@property (nonatomic) UILabel* startTimeLabel;
@property (nonatomic) UILabel* endTimeLabel;
@property (nonatomic) UIButton* playBtn;
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
            make.width.equalTo(@35);
        }];
        [self.playBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        
        self.startTimeLabel = [[UILabel alloc] init];
        [self.startTimeLabel setTextColor:[UIColor whiteColor]];
        [self.startTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.startTimeLabel];
        [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.left.equalTo(self.playBtn.mas_right).offset(5);
            make.width.equalTo(@50);
        }];
        
        self.endTimeLabel = [[UILabel alloc] init];
        [self.endTimeLabel setTextColor:[UIColor whiteColor]];
        [self.endTimeLabel setFont:[UIFont systemFontOfSize:11]];
        [self addSubview:self.endTimeLabel];
        [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self);
            make.right.equalTo(self);
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

-(void)setTotalMillisecondes:(NSInteger)milliseconds
{
    self.slider.maximumValue = milliseconds;
    [self.endTimeLabel setText:[self getMMSSFromSS:milliseconds/1000]];
}

-(NSString *)getMMSSFromSS:(NSInteger)seconds{
    NSString *format_time = @"";
    NSInteger millisecondes = [self totalMillisecondes];
    if (millisecondes/1000/3600 > 0) {
        //format of hour
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
        //format of minute
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
        //format of second
        NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
        //format of time
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    } else {
        //format of minute
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
        //format of second
        NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
        //format of time
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    return format_time;
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
