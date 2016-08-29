//
//  AppDelegate.m
//  Example
//
//  Created by Don Yang on 8/28/16.
//  Copyright © 2016 dy. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <IFXRefresher/IFXRefresher.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [ViewController new];
    [self.window makeKeyAndVisible];
    
    [IFXMonitor startMonitor];
    return YES;
}

@end
