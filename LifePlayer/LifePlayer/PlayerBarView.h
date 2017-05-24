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

@interface PlayerBarView : UIView

- (void)setTotalSecondes:(NSInteger)secondes;
- (void)setSecondes:(NSInteger)secondes;
- (NSInteger)totalSecondes;

@end