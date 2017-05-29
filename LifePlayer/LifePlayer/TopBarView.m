//
//  TopBarView.m
//  LifePlayer
//
//  Created by FanFamily on 2017/5/24.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "TopBarView.h"
#import <Masonry.h>

@implementation BulbTopBarViewDissmissSignal

@end

@interface TopBarView ()

@property (nonatomic) UIButton* returnBtn;

@end

@implementation TopBarView

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
    }
    return self;
}

- (void)dissmiss:(id)sender
{
    [[Bulb bulbGlobal] fire:[BulbTopBarViewDissmissSignal signalDefault] data:nil];
}

@end
