//
//  AppDelegate.m
//  Puzzlfy
//
//  Created by Bahaa Zaid on 3/16/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "AppDelegate.h"
#import "Notifications.h"
#import "PuzzlfyIAPHelper.h"
#import "GameCenterManager.h"
#import "AnalyticsManager.h"
#import "Constants.h"
#import "SoundUtilities.h"
#import "PuzzlfyUIApplication.h"
#import "Appirater.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ACTReporter.h"


@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(void)applicationDidTimeout:(NSNotification *) notif
{
    if (!self.stopIdleSound) {
        [SoundUtilities playIdleSound];
        [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] multiplyTimerFactor];
        [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] resetIdleTimer];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    [[GameCenterManager getInstance] authenticateLocalPlayer];
    if(InAppPurchaseEnabled)
        [PuzzlfyIAPHelper sharedInstance];
    
    [[AnalyticsManager sharedSingleton] startSession:FLURRY_APP_ID];
    [ACTConversionReporter reportWithConversionID:@"964644329" label:@"-uyaCPrSm1YQ6Zv9ywM" value:@"1.00" isRepeatable:NO];
    
    //app rating
    NSString* appID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"iTunesId"];
    [Appirater setAppId:appID];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:3];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_WILL_ENTER_BACKGROUND_NOTIFICATION object:nil];
    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] stopIdleTime];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:APP_WILL_ENTER_FOREGROUND_NOTIFICATION object:nil];
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSettings setDefaultAppID:FACEBOOK_APP_ID];
    [FBAppEvents activateApp];
    
    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] resetTimerFactor];
    [(PuzzlfyUIApplication*)[PuzzlfyUIApplication sharedApplication] resetIdleTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Puzzlfy.sqlite"]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
    {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


@end
