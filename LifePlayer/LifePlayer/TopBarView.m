//
//  TopBarView.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/24.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "TopBarView.h"
#import "ViewController.h"
#import <Masonry.h>

@implementation BulbTopBarViewDissmissSignal

@end

@interface TopBarView ()

@property (nonatomic) UIButton* returnBtn;
@property (nonatomic) UILabel* fileNameLabel;
@property (nonatomic) UILabel* deviceLabel;

@end

@implementation TopBarView

- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

- (NSString *)deviceInfoString
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    NSString* battery = [NSString stringWithFormat:@"%ld%%", (NSInteger)(deviceLevel * 100)];
    NSString* time = [self getCurrentTimes];
    NSString* deviceInfo = [NSString stringWithFormat:@"当前时间%@ 电量%@", time, battery];
    return deviceInfo;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.returnBtn = [[UIButton alloc] init];
        [self.returnBtn setTitle:@"＜" forState:UIControlStateNormal];
        [self addSubview:self.returnBtn];
        [self.returnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(@40);
            make.width.equalTo(@40);
        }];
        [self.returnBtn addTarget:self action:@selector(dissmiss:) forControlEvents:UIControlEventTouchUpInside];
        
        self.fileNameLabel = [[UILabel alloc] init];
        [self.fileNameLabel setTextColor:[UIColor whiteColor]];
        BulbFileNameSignal* signal = (BulbFileNameSignal *)[[Bulb bulbGlobal] getSignalFromHungUpList:[BulbFileNameSignal identifier]];
        [self.fileNameLabel setText:signal.data];
        [self addSubview:self.fileNameLabel];
        [self.fileNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.returnBtn.mas_right);
            make.centerY.equalTo(self);
            make.height.equalTo(@40);
            make.width.equalTo(@249);
        }];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dissmiss:)];
        self.fileNameLabel.userInteractionEnabled = YES;
        [self.fileNameLabel addGestureRecognizer:tap];
        
        self.deviceLabel = [[UILabel alloc] init];
        [self.deviceLabel setTextColor:[UIColor whiteColor]];
        [self.deviceLabel setText:[self deviceInfoString]];
        self.deviceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.deviceLabel];
        [self.deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-15);
            make.centerY.equalTo(self);
            make.height.equalTo(@40);
            make.width.equalTo(@249);
        }];
        
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)refresh:(id)timer
{
    if (self.alpha > 0) {
        [self.deviceLabel setText:[self deviceInfoString]];
    }
}

- (void)dissmiss:(id)sender
{
    [[Bulb bulbGlobal] fire:[BulbTopBarViewDissmissSignal signalDefault] data:nil];
}

@end
