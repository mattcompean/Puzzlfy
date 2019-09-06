//
//  EventsManager.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 6/2/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventsManager : NSObject


+ (void)reportEventWithType:(id)eventType withParameters:(NSMutableDictionary *)params;
+ (void)reportEventFromView:(int)viewID withParameters:(NSDictionary *)params;
+ (void)resetStartDate;
+ (double)getTimeInterval;


#ifndef Puzzlfy_EventTypes_h
#define Puzzlfy_EventTypes_h

#define EVENT_PUZZLE_SOLVED                         @"Puzzle Solved"
#define EVENT_ACHIEVEMENTS_CLICKED                  @"Achievements Clicked"
#define EVENT_MORE_STICKERS_CLICKED                 @"More Stickers Clicked"
#define EVENT_ORDER_PRINT_CLICKED                   @"Order Print Clicked"
#define EVENT_FEATURED_IMAGE_SELECTED               @"Featured Image Selected"
#define EVENT_FEATURED_USER_IMAGE_SELECTED          @"Featured User Image Selected"
#define EVENT_FEATURED_VIDEO_SELECTED               @"Featured Video Selected"
#define EVENT_GALLERY_VIDEO_SELECTED                @"Gallery Video Selected"
#define EVENT_GALLERY_IMAGE_SELECTED                @"Gallery Image Selected"
#define EVENT_CAMERA_IMAGE_SELECTED                 @"Camera Image Selected"
#define EVENT_CAMERA_VIDEO_SELECTED                 @"Camera Video Selected"
#define EVENT_STICKERS_USED                         @"Stickers Used"
#define EVENT_GALLERY_PERMISSION_DENIED             @"Gallery Permission Denied"
#define EVENT_GAME_STARTED                          @"GAME_STARTED"


/*
 * Define Events
 */

#define EVT_MEDIA_SELECTED                              @"MEDIA_SELECTED"
#define EVT_GAME_COMPLETED                              @"GAME_COMPLETED"
#define EVT_ACHIEVEMENT_UNLOCKED                        @"ACHIEVEMENT_UNLOCKED"
#define EVT_OPEN_VIEW                                   @"OPEN_VIEW"
#define EVT_ACHIEVEMENTS_CLICKED                        @"ACHIEVEMENTS_CLICKED"
#define EVT_MORE_STICKERS_CLICKED                       @"MORE_STICKERS_CLICKED"
#define EVT_ORDER_PRINT_CLICKED                         @"ORDER_PRINT_CLICKED"
#define EVT_STICKER_USED                                @"STICKER_USED"
#define EVT_PERMISSION_REJECTED                         @"PERMISSION_REJECTED"
#define EVT_GAME_STARTED                                @"GAME_STARTED"

/*
 * Define Event Parameters
 */
//#define PARAM_EVT_SEARCH_SEARCHTERM                     @"Search Term"


/*
 * Common Params
 */
#define PARAM_EVT_IMAGE_SELECTED                        @"Image"
#define PARAM_EVT_VIDEO_SELECTED                        @"Video"
#define PARAM_EVT_DIFFICULTY_EASY                       @"Easy"
#define PARAM_EVT_DIFFICULTY_MEDIUM                     @"Medium"
#define PARAM_EVT_DIFFICULTY_HARD                       @"Hard"

/*
 * Params Keys
 */
#define PARAM_EVT_KEY_MEDIA_TYPE                        @"MEDIA_TYPE"
#define PARAM_EVT_KEY_DIFFICUTLY                        @"DIFFICULTY"
#define PARAM_EVT_KEY_ACHIEVEMENT_ID                    @"ACHIEVEMENT_ID"
#define PARAM_EVT_KEY_STICKER_ID                        @"STICKER_ID"
#define PARAM_EVT_KEY_PERMISSION                        @"PERMISSION"
#define PARAM_EVT_KEY_DURATION                          @"DURATION"
#define PARAM_EVT_KEY_STICKERS_USED                     @"NUMBER_OF_STICKERS_USED"

/*
 * Views:
 */
#define VIEW_WELCOME                                    @"Welcome View"
#define VIEW_HOME                                       @"Home View"
#define VIEW_GALLERY                                    @"Gallery View"
#define VIEW_CAMERA                                     @"Camera View"
#define VIEW_STICKERS                                   @"Stickers View"
#define VIEW_PUZZLE                                     @"Puzzle View"
#define VIEW_SETTINGS                                   @"Settings View"

#endif
@end
