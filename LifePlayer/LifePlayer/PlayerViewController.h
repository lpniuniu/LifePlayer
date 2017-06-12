//
//  PlayerViewController.h
//  LifePlayer
//
//  Created by FanFamily on 2017/5/22.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bulb.h>

@interface BulbVideoOverSignal : BulbBoolSignal

@end

@interface PlayerViewController : UIViewController

- (instancetype)initWithPath:(NSString *)path;

@end
