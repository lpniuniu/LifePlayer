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

@implementation BulbOpenUrlSignal

@end

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];
    
    NSURL* url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (url) {
        [[Bulb bulbGlobal] hungUp:[BulbOpenUrlSignal signalDefault] data:url];
        return NO;
    }
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    [[Bulb bulbGlobal] fire:[BulbOpenUrlSignal signalDefault] data:url];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
