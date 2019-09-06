//
//  PuzzlfyUIApplication.m
//  Puzzlfy
//
//  Created by Youmna on 5/22/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "PuzzlfyUIApplication.h"
#import "SoundUtilities.h"
#import "Notifications.h"

@implementation PuzzlfyUIApplication

-(void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if (!idleTimer)
    {
        [self resetIdleTimer];
    }
    
    if (puzzlfyBtnTimer) {
        [self resetPuzzlfyBtnTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0) {
        [self resetTimerFactor];
        [self resetIdleTimer];
    }
}

-(void)resetIdleTimer
{
    [SoundUtilities restorePlayingMainSound];
    if (idleTimer)
    {
        [idleTimer invalidate];
    }
    //convert the wait period into minutes rather than seconds
    int timeout = kApplicationTimeoutInMinutes * timerFactor;
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
    
}

-(void)resetPuzzlfyBtnTimer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:STOP_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    if (puzzlfyBtnTimer) {
        [puzzlfyBtnTimer invalidate];
    }
    puzzlfyBtnTimer = [NSTimer scheduledTimerWithTimeInterval:PUZZLFY_BTN_TIMEOUT target:self selector:@selector(puzzlfyBtnTimerExceeded) userInfo:nil repeats:NO];
}

-(void)multiplyTimerFactor
{
    timerFactor = timerFactor * 2;
}

-(void)resetTimerFactor
{
    timerFactor = 1;
}

-(void)stopIdleTime
{
    [idleTimer invalidate];
    timerFactor = 1;
}

-(void)stopPuzzlfyBtnTimer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:STOP_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
    [puzzlfyBtnTimer invalidate];
    puzzlfyBtnTimer = nil;
}

-(void)idleTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
}

-(void)puzzlfyBtnTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:START_PUZZLFY_ANIMATION_NOTIFICATION object:nil];
}
@end
