//
//  PlayerBarView.h
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bulb.h>

@interface BulbChangeTimeSignal : BulbBoolSignal

@end

@interface BulbPlayOrPauseSignal : BulbBoolSignal

@end

@interface BulbNextSignal : BulbBoolSignal

@end

@interface PlayerBarView : UIView

- (void)setTotalMillisecondes:(NSInteger)secondes;
- (void)setMillisecondes:(NSInteger)secondes;
- (NSInteger)totalMillisecondes;

- (void)playOrPause:(id)sender;

@end
