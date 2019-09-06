//
//  Constants.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/6/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#ifndef Puzzlfy_Constants_h
#define Puzzlfy_Constants_h

#pragma mark - Camera View
#define CAMERA_BTN                              @"cm-camera-btn.png"
#define VIDEO_BTN                               @"cm-video-btn.png"

#pragma mark - Settings
#define SOUND_ON_IMG                            @"st-sound-on-btn.png"
#define SOUND_OFF_IMG                           @"st-sound-off-btn.png"
#define MUSIC_ON_IMG                            @"st-music-on-btn.png"
#define MUSIC_OFF_IMG                           @"st-music-off-btn.png"
#define DIFFICULTY_SUPER_EASY_IMG                     @"st-diff-supereasy.png"
#define DIFFICULTY_EASY_IMG                     @"st-diff-easy.png"
#define DIFFICULTY_MEDIUM_IMG                   @"st-diff-medium.png"
#define DIFFICULTY_HARD_IMG                     @"st-diff-hard.png"
#define SILHOUETTE_ON_IMG                       @"st-checkbox-silhoutte-on.png"
#define SILHOUETTE_OFF_IMG                      @"st-checkbox-silhoutte-off.png"
#define OUTLINE_ON_IMG                          @"st-checkbox-outline-on.png"
#define OUTLINE_OFF_IMG                         @"st-checkbox-outline-off.png"
#define PAUSE_IMG                               @"video-pause.png"
#define PLAY_IMG                                @"video-play-stickers.png"
#define DIFFICULTY_SUPER_EASY_X                 2
#define DIFFICULTY_SUPER_EASY_Y                 2
#define DIFFICULTY_EASY_X                       4
#define DIFFICULTY_EASY_Y                       3
#define DIFFICULTY_MEDIUM_X                     5
#define DIFFICULTY_MEDIUM_Y                     4
#define DIFFICULTY_HARD_X                       8
#define DIFFICULTY_HARD_Y                       6
#define DIFFICULTY_EASY                         0
#define DIFFICULTY_MEDIUM                       1
#define DIFFICULTY_HARD                         2
#define DIFFICULTY_SUPER_EASY                   3
#define DIFFICULTY_EASY_SNAPPING                2
#define DIFFICULTY_MEDIUM_SNAPPING              5
#define DIFFICULTY_HARD_SNAPPING                9
#define DIFFICULTY_SUPER_EASY_SNAPPING          1
#define DIFFICULTY_SUPER_EASY_BACKGROUND_ALPHA  0.8f
#define PUZZLE_BACKGROUND_ALPHA                 0.9f

#pragma mark - Core Data
#define USER_MODEL                              @"User"

#pragma mark - Sound
#define WINNING_SOUND                           @"winning"
#define MOVE_SOUND                              @"move"
#define SOUND_TYPE_MP3                          @"mp3"
#define GENERIC_BUTTON_SOUND                    @"puzzlfy-button-others"
#define SOUND_ACHIEVEMENT                       @"puzzlfy-achievement"

#pragma mark - Stickers Placeholder origin
#define VIDEO_STICKERS_VIEW_X                   90
#define VIDEO_STICKERS_VIEW_Y                   100
#define PICTURE_STICKERS_VIEW_X                 68
#define PICTURE_STICKERS_VIEW_Y                 124

#pragma mark - Player Actions
#define PLAYER_PAUSE                            1
#define PLAYER_PLAY                             2
#define PLAYER_RESTART                          3

#pragma mark - Flurry app id
#define FLURRY_APP_ID                           @"FK93YHDGRSJYNBG58M2S"

#pragma mark - Puzzle Asset Types
#define PUZZLE_MEDIA_TYPE_IMAGE                 1
#define PUZZLE_MEDIA_TYPE_IMAGE_ASSET           2
#define PUZZLE_MEDIA_TYPE_IMAGE_CAMERA          5
#define PUZZLE_MEDIA_TYPE_VIDEO_ASSET           3
#define PUZZLE_MEDIA_TYPE_VIDEO_URL             4

#pragma mark - Info view
#define R60_URL                                 @"http://www.radius60.com"
#define CAMINANDES_URL                          @"http://www.caminandes.com"
#define KIDSSAFE_URL                            @"http://www.kidsafeseal.com/certifiedproducts/puzzlfy_app.html"
#define FEEDBACK_EMAIL                          @"puzzlfy@radius60.com"
#define EMAIL_SUBJECT                           @"Puzzlfy Feedback"
#define InAppPurchaseEnabled                    NO

#pragma mark - Notification
#define NOTIFICATION_DURATION                   3

#define PUZZLFY_NOTIFICATION_TYPE_WARNING       TSMessageNotificationTypeWarning
#define PUZZLFY_NOTIFICATION_TYPE_ERROR         TSMessageNotificationTypeError
#define PUZZLFY_NOTIFICATION_TYPE_MESSAGE       TSMessageNotificationTypeMessage
#define PUZZLFY_NOTIFICATION_TYPE_SUCCESS       TSMessageNotificationTypeSuccess

#pragma mark - View names

#define VIEW_WELCOME_ID                         1
#define VIEW_HOME_ID                            2
#define VIEW_GALLERY_ID                         3
#define VIEW_CAMERA_ID                          4
#define VIEW_STICKERS_ID                        5
#define VIEW_PUZZLE_ID                          6
#define VIEW_SETTINGS_ID                        7

#pragma mark - Xib names

#define NAVIGATION_BAR_VIEW                     @"NavigationBar_iPad"

#define EMPTY_THUMB_IMG                         @"emptyThumb"

#define NUMBER_OF_VIBRATIONS_FOR_PUZZLE_PIECE 14

#define MIC_PERMISSION_TXT                      @"We would like permission to access your microphone.\nThis will allow the app to capture videos with audio."
#define LIBRARY_PERMISSION_TXT                  @"We would like permission to access your photos and videos.\nThis will allow the app to feature your photos on the main page, as well as save and access the puzzles you create from your photo library and the app’s camera."

#define WATERMARK_IMG                           @"watermark.png"

#define FACEBOOK_APP_ID                         @"1453270068276534"
#endif
