//
//  AppDelegate.m
//  LifePlayer
//
//  Created by familymrfan on 2017/5/15.
//  Copyright © 2017年 niuniu. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation BulbWillResignActiveSignal

@end

@implementation BulbDidBecomeActive

@end

@implementation BulbWillEnterForeground

@end

@implementation BulbDidEnterBackground

@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[Bulb bulbGlobal] fire:[BulbWillResignActiveSignal signalDefault] data:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Bulb bulbGlobal] fire:[BulbDidEnterBackground signalDefault] data:nil];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[Bulb bulbGlobal] fire:[BulbWillEnterForeground signalDefault] data:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Bulb bulbGlobal] fire:[BulbDidBecomeActive signalDefault] data:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
