//
//  AppDelegate.h
//  LifePlayer
//
//  Created by familymrfan on 2017/5/15.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Bulb.h>

@interface BulbWillResignActiveSignal : BulbBoolSignal

@end

@interface BulbDidBecomeActive : BulbBoolSignal

@end

@interface BulbWillEnterForeground : BulbBoolSignal

@end

@interface BulbDidEnterBackground : BulbBoolSignal

@end

@interface BulbOpenUrlSignal : BulbBoolSignal

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

