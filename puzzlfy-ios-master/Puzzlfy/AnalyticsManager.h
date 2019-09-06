//
//  AnalyticsManager.h
//  Puzzlfy
//
//  Created by Youmna on 5/5/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsManager : NSObject

-(void) startSession:(NSString *)apiKey;
+ (AnalyticsManager *)sharedSingleton;
- (void)logEvent:(NSString *)eventName timed:(BOOL)isTimed;
- (void)logEvent:(NSString *)eventName fromView:view timed:(BOOL)isTimed;
- (void)logEvent:(NSString *)eventName fromView:view withParameters:(NSMutableDictionary *)parameters timed:(BOOL)isTimed;
- (void)endTimeEvent:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters;
- (void)logEvent:(NSString *)eventName withParameters:(NSMutableDictionary *)parameters timed:(BOOL)isTimed;
- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;
- (void)logError:(NSString *)errorID message:(NSString *)message error:(NSError *)error;


#ifndef Puzzlfy_AnaylticsEvents_h
#define Puzzlfy_AnaylticsEvents_h


#define PARAM_EVT_SOURCE_MENU                           @"VIEW"

#define STATUS_FAILED                                   @"Failed"
#define STATUS_SUCCEEDED                                @"Succeeded"

#endif
@end
