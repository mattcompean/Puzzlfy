//
//  EventsManager.m
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 6/2/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import "EventsManager.h"
#import "DBManager.h"
#import "GameCenterManager.h"
#import "AnalyticsManager.h"
#import "AchievementsNames.h"
#import "Constants.h"
#import "ViewUtilities.h"

@implementation EventsManager

static NSDate *startTime;

+ (void)reportEventWithType:(id)eventType withParameters:(NSMutableDictionary *)eventParams
{
    if ([eventType isEqualToString:EVENT_PUZZLE_SOLVED]) {
        [self eventPuzzleSolved];
    }
    else if ([eventType isEqualToString:EVENT_ACHIEVEMENTS_CLICKED]) {
        [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENTS_CLICKED timed:NO];
    }
    else if ([eventType isEqualToString:EVENT_MORE_STICKERS_CLICKED]) {
        [[AnalyticsManager sharedSingleton]logEvent:EVT_MORE_STICKERS_CLICKED timed:NO];
    }
    else if ([eventType isEqualToString:EVENT_ORDER_PRINT_CLICKED]) {
        [[AnalyticsManager sharedSingleton]logEvent:EVT_ORDER_PRINT_CLICKED timed:NO];
    }
    else if ([eventType isEqualToString:EVENT_FEATURED_IMAGE_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_HOME withType:PARAM_EVT_IMAGE_SELECTED];
    }
    else if ([eventType isEqualToString:EVENT_FEATURED_VIDEO_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_HOME withType:PARAM_EVT_VIDEO_SELECTED];
    }
    else if ([eventType isEqualToString:EVENT_GALLERY_IMAGE_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_GALLERY withType:PARAM_EVT_IMAGE_SELECTED];
    }
    else if ([eventType isEqualToString:EVENT_GALLERY_VIDEO_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_GALLERY withType:PARAM_EVT_VIDEO_SELECTED];
    }
    else if ([eventType isEqualToString:EVENT_CAMERA_IMAGE_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_CAMERA withType:PARAM_EVT_IMAGE_SELECTED];
        if (![[DBManager getInstance]isTakePhotoAchievementUnlocked]) {
            [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_SNAPPY_SPILSBERRY, ACHIEVEMENT_SNAPPY_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_SNAPPY_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_CAMERA withParameters:params timed:NO];
            [[DBManager getInstance]setTakePhotoAchievement:YES];
            NSError *error;
            [[DBManager getInstance] saveObjectContext:&error];
        }
    }
    else if ([eventType isEqualToString:EVENT_CAMERA_VIDEO_SELECTED]) {
        [self reportMediaSelectionFromView:VIEW_CAMERA withType:PARAM_EVT_VIDEO_SELECTED];
        if (![[DBManager getInstance]isTakeVideoAchievementUnlocked]) {
            [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_ACTION_SPILSBERRY, ACHIEVEMENT_ACTION_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_ACTION_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_CAMERA withParameters:params timed:NO];
            [[DBManager getInstance]setTakeVideoAchievement:YES];
            NSError *error;
            [[DBManager getInstance] saveObjectContext:&error];
        }
    }
    else if ([eventType isEqualToString:EVENT_STICKERS_USED]) {
        [[AnalyticsManager sharedSingleton]logEvent:EVT_STICKER_USED withParameters:(NSMutableDictionary*)eventParams timed:NO];
        if ([[NSNumber numberWithInteger:[[[DBManager getInstance]getUsedStickers] count]] isEqualToNumber:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NUMBER_STICKERS"]] && ![[DBManager getInstance]isStickersAchievementUnlocked]) {
            [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_STICKY_SPILSBERRY, ACHIEVEMENT_STICKY_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_STICKY_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_STICKERS withParameters:params timed:NO];
            [[DBManager getInstance]setStickersAchievement:YES];
            NSError *error;
            [[DBManager getInstance] saveObjectContext:&error];
        }
    }
    else if ([eventType isEqualToString:EVENT_GALLERY_PERMISSION_DENIED]) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Gallery",PARAM_EVT_KEY_PERMISSION, nil];
        [[AnalyticsManager sharedSingleton]logEvent:EVT_PERMISSION_REJECTED withParameters:params timed:NO];
    }
    else if ([eventType isEqualToString:EVENT_GAME_STARTED]) {
        [eventParams setObject:[[DBManager getInstance]getDifficultyName] forKey:PARAM_EVT_KEY_DIFFICUTLY];
        [[AnalyticsManager sharedSingleton]logEvent:EVT_GAME_STARTED withParameters:eventParams timed:NO];
    }
}

+ (void)reportEventFromView:(int)viewID withParameters:(NSDictionary *)params
{
    switch (viewID) {
        case VIEW_WELCOME_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_WELCOME timed:NO];
            break;
        }
        case VIEW_HOME_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_HOME timed:NO];
            break;
        }
        case VIEW_STICKERS_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_STICKERS timed:NO];
            break;
        }
        case VIEW_GALLERY_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_GALLERY timed:NO];
            break;
        }
        case VIEW_CAMERA_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_CAMERA timed:NO];
            break;
        }
        case VIEW_PUZZLE_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_PUZZLE timed:NO];
            break;
        }
        case VIEW_SETTINGS_ID: {
            [[AnalyticsManager sharedSingleton]logEvent:EVT_OPEN_VIEW fromView:VIEW_SETTINGS timed:NO];
            break;
        }
        default:
            break;
    }
}

+ (void)reportMediaSelectionFromView:(NSString *)viewName withType:(NSString *)type
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:type,PARAM_EVT_KEY_MEDIA_TYPE, nil];
    [[AnalyticsManager sharedSingleton]logEvent:EVT_MEDIA_SELECTED fromView:viewName withParameters:params timed:NO];
}

+ (void)eventPuzzleSolved
{
    int solvedPuzzles = [[DBManager getInstance]getNumberOfSolvedPuzzles];

    if (solvedPuzzles == 0) {
        [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_YOUNG_SPILSBERRY, ACHIEVEMENT_YOUNG_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_YOUNG_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
        [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_PUZZLE withParameters:params timed:NO];
    }
    if (solvedPuzzles >= 10) {
        [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_SUPER_SPILSBERRY, ACHIEVEMENT_SUPER_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_SUPER_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
        [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_PUZZLE withParameters:params timed:NO];
    }
    switch ([[DBManager getInstance]getDifficulty]) {
        case DIFFICULTY_EASY: {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:PARAM_EVT_DIFFICULTY_EASY,PARAM_EVT_KEY_DIFFICUTLY, [NSNumber numberWithDouble:[self getTimeInterval]], PARAM_EVT_KEY_DURATION, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_GAME_COMPLETED withParameters:params timed:NO];
            break;
        }
        case DIFFICULTY_MEDIUM: {
            if (![[DBManager getInstance]isMediumPuzzleAchievementUnlocked]) {
                [[DBManager getInstance]setMediumPuzzleAchievement:YES];
                [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_MASTER_SPILSBERRY, ACHIEVEMENT_MASTER_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
                
                NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_MASTER_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
                [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_PUZZLE withParameters:params timed:NO];
            }
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:PARAM_EVT_DIFFICULTY_MEDIUM,PARAM_EVT_KEY_DIFFICUTLY, [NSNumber numberWithDouble:[self getTimeInterval]], PARAM_EVT_KEY_DURATION, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_GAME_COMPLETED withParameters:params timed:NO];
            break;
        }
        case DIFFICULTY_HARD: {
            if (![[DBManager getInstance]isHardPuzzleAchievementUnlocked]) {
                [[DBManager getInstance]setHardPuzzleAchievement:YES];
                [[GameCenterManager getInstance]updateAchievementWithIdentifier:[NSArray arrayWithObjects:ACHIEVEMENT_PROFESSOR_SPILSBERRY, ACHIEVEMENT_PROFESSOR_SPILSBERRY_TITLE, nil] percentComplete:100 showBanner:YES];
                
                NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ACHIEVEMENT_PROFESSOR_SPILSBERRY,PARAM_EVT_KEY_ACHIEVEMENT_ID, nil];
                [[AnalyticsManager sharedSingleton]logEvent:EVT_ACHIEVEMENT_UNLOCKED fromView:VIEW_PUZZLE withParameters:params timed:NO];
            }
            NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:PARAM_EVT_DIFFICULTY_HARD,PARAM_EVT_KEY_DIFFICUTLY, [NSNumber numberWithDouble:[self getTimeInterval]], PARAM_EVT_KEY_DURATION, nil];
            [[AnalyticsManager sharedSingleton]logEvent:EVT_GAME_COMPLETED withParameters:params timed:NO];
            break;
        }
    }
    
    [[DBManager getInstance]setNumberOfSolvedPuzzles:solvedPuzzles+1];
    NSError *error;
    [[DBManager getInstance] saveObjectContext:&error];
}

+ (void)resetStartDate
{
    startTime = [NSDate new];
}

+ (double)getTimeInterval
{
    if (startTime) {
        return [[NSDate new]timeIntervalSinceDate:startTime];
    }
    else {
        return 0;
    }
}

@end
