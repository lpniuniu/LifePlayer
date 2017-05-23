//
//  PlayerBarView.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "PlayerBarView.h"
#import <Masonry.h>

@implementation BulbChangeTimeSignal

@end

@interface PlayerBarView ()

@property (nonatomic) UISlider* slider;

@end

@implementation PlayerBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.slider = [[UISlider alloc] init];
        [self addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

-(void)setTotalSecondes:(NSInteger)secondes
{
    self.slider.maximumValue = secondes;
}

- (void)setSecondes:(NSInteger)secondes
{
    self.slider.value = secondes;
}

- (NSInteger)totalSecondes
{
    return self.slider.maximumValue;
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [[Bulb bulbGlobal] fire:[BulbChangeTimeSignal signalDefault] data:@(slider.value)];
}

@end
