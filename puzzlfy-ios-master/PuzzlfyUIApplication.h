//
//  PuzzlfyUIApplication.h
//  Puzzlfy
//
//  Created by Youmna on 5/22/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <UIKit/UIKit.h>

//the length of time before your application "times out". This number actually represents seconds
#define kApplicationTimeoutInMinutes 30
#define PUZZLFY_BTN_TIMEOUT 5
//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface PuzzlfyUIApplication : UIApplication
{
    NSTimer *idleTimer;
    NSTimer *puzzlfyBtnTimer;
    long timerFactor;
}
-(void)resetIdleTimer;
-(void)stopIdleTime;
-(void)resetTimerFactor;
-(void)multiplyTimerFactor;
-(void)resetPuzzlfyBtnTimer;
-(void)stopPuzzlfyBtnTimer;
@end
