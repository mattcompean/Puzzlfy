//
//  ViewUtilities.h
//  Puzzlfy
//
//  Created by Adham Aboul Einein on 5/13/14.
//  Copyright (c) 2014 Radius 60. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  <AssetsLibrary/AssetsLibrary.h>
#import <TSMessage.h>
#import "NavigationBarView.h"

typedef void(^SaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;
-(void)saveVidio:(NSURL*)video toAlbum:(NSString*)albumName;

@end

@interface ViewUtilities : NSObject <UIAlertViewDelegate>

+ (ALAssetsLibrary *)defaultAssetsLibrary;
+(NSTimer*) idleTimer;
+(void)setIdleTimer:(NSTimer*)timer;

+(void)presentNotification:(NSString *)title withMessage:(NSString *)message withType:(int)type onAction:(void (^)())action;

+(void)presentError:(NSString *)message;
+(void)presentInformation:(NSString *)message;
+(void)presentWarning:(NSString *)message;
+(void)presentSuccess:(NSString *)message;
+(void)presentPushNotification:(NSString *)message onAction:(void (^)())action;
+(void)showAchievementsBadgeViewWithTitle:(NSString *)title;
+(void)saveImageToPhotoLibrary:(UIImage *)image;
+(void)setNavBar:(NavigationBarView *)nBar;
+(NavigationBarView *)getNavBar;
+(void)checkPhotoLibraryContent;
+(BOOL)isPhotoLibraryEmpty;
+ (ALAuthorizationStatus)checkLibraryAuthorizationStatus;
+ (BOOL)isPhotoLibraryPermissionSet;
+ (void)dismissAlertView;
@end
