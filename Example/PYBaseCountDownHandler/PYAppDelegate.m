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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [PYCountDownHandler applicationDidEnterBackgroundWithCurrentDate: [NSDate new]];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [PYCountDownHandler applicationWillEnterForegroundWithCurrentDate:[NSDate new]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
