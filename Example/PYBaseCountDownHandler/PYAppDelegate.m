//
//  PYAppDelegate.m
//  PYBaseCountDownHandler
//
//  Created by LiPengYue on 08/13/2019.
//  Copyright (c) 2019 LiPengYue. All rights reserved.
//

#import "PYAppDelegate.h"
#import <PYCountDownHandler.h>
@implementation PYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [PYCountDownHandler applicationDidEnterBackgroundWithCurrentDate: [NSDate new]];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [PYCountDownHandler applicationWillEnterForegroundWithCurrentDate:[NSDate new]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
