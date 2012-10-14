//
//  ASMAppDelegate.m
//  LilJukeBox
//
//  Created by Andy Molloy on 5/21/12.
//  Copyright (c) 2012 Andy Molloy. All rights reserved.
//

#import "ASMAppDelegate.h"

#import "ASMMainViewController.h"
#import "UIDevice+SafeUserInterfaceIdiom.h"
#import "BWHockeyManager.h"
#import "BWQuincyManager.h"

@implementation ASMAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;

- (void)dealloc
{
    [_window release];
    [_mainViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if !defined (CONFIGURATION_AppStore)
	[BWHockeyManager sharedHockeyManager].updateURL = @"https://rink.hockeyapp.net/";
	[BWHockeyManager sharedHockeyManager].appIdentifier = @"e9a8878814a9f377f152e04d2d7b9032";
	
	[BWQuincyManager sharedQuincyManager].appIdentifier = @"e9a8878814a9f377f152e04d2d7b9032";
#endif
	
    NSMutableDictionary* appDefaults = [NSMutableDictionary dictionaryWithCapacity:1];
    [appDefaults setObject:[NSNumber numberWithBool:NO] forKey:kHideConfigUserDefaultsKey];
	[appDefaults setObject:[NSNumber numberWithBool:YES] forKey:kShowAlbumArtworkKey];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    if (UISafeUserInterfaceIdiomPhone == [[UIDevice currentDevice] safeUserInterfaceIdiom])
    {
        self.mainViewController = [[[ASMMainViewController alloc] initWithNibName:@"ASMMainViewController_iPhone" bundle:nil] autorelease];
    }
    else
    {
        self.mainViewController = [[[ASMMainViewController alloc] initWithNibName:@"ASMMainViewController_iPad" bundle:nil] autorelease];
    }

    if ([self.window respondsToSelector:@selector(setRootViewController:)])
    {
        self.window.rootViewController = self.mainViewController;
    }
    else
    {
        UIView* theView = self.mainViewController.view;
        [self.window addSubview:theView];
        [self.mainViewController.view setFrame:[[UIScreen mainScreen] applicationFrame]];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
