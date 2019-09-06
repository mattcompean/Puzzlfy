//
//  AnalyticsManager.m
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "AnalyticsManager.h"
#import "Flurry.h"

@implementation AnalyticsManager {
    BOOL _isSessionStarted;
}



-(void) startSession:(NSString *)apiKey
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"pref_flurry"]){
        if(!_isSessionStarted){
#if DEBUG
//            [Flurry setDebugLogEnabled:YES];
//            [Flurry setEventLoggingEnabled:YES];
#endif
            [Flurry setCrashReportingEnabled:YES];
            [Flurry startSession:apiKey];
            [Flurry setSessionReportsOnPauseEnabled:YES];
            [Flurry setSessionReportsOnCloseEnabled:YES];
            
            //NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"YES", @"Session Start", nil];
            //[[AnalyticsManager sharedSingleton] logEvent:@"Analytics Manager" withParameters:dictionary];
            _isSessionStarted = true;
        }
    }
}

- (void)logEvent:(NSString *)eventName timed:(BOOL)isTimed
{
    [Flurry logEvent:eventName];
}
- (void)logEvent:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters timed:(BOOL)isTimed
{
    [Flurry logEvent:eventName withParameters:parameters];
}

- (void)logEvent:(NSString *)eventName fromView:view timed:(BOOL)isTimed
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:view, PARAM_EVT_SOURCE_MENU, nil];
    [[AnalyticsManager sharedSingleton] logEvent:eventName withParameters:dictionary timed:isTimed];
}

- (void)logEvent:(NSString *)eventName fromView:view withParameters:(NSMutableDictionary *)parameters timed:(BOOL)isTimed
{
    [parameters setObject:view forKey:PARAM_EVT_SOURCE_MENU];
    [[AnalyticsManager sharedSingleton] logEvent:eventName withParameters:parameters timed:isTimed];
}

- (void)endTimeEvent:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters
{
    [Flurry endTimedEvent:eventName withParameters:parameters];
}

- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception
{
    [Flurry logError:errorID message:message exception:exception];
}

- (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error
{
    [Flurry logError:errorID message:message error:error];
}

+ (AnalyticsManager *)sharedSingleton
{
    static AnalyticsManager *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
            sharedSingleton = [[AnalyticsManager alloc] init];
        
        return sharedSingleton;
    }
}


@end
